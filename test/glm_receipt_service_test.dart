import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:receipt_record/services/glm_receipt_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('GlmReceiptService Configuration and Key Management', () {
    test('Default endpoint and model values are configured correctly', () async {
      final service = GlmReceiptService.createForTesting();
      expect(await service.getEndpoint(), GlmReceiptService.defaultEndpoint);
      expect(await service.getModelName(), 'glm-5.3-flash');
      expect(await service.isAiEnabled(), isTrue);
      expect(await service.hasApiKey(), isFalse);
    });

    test('Saves, retrieves, and clears API key securely', () async {
      final service = GlmReceiptService.createForTesting();

      await service.saveApiKey('test-key-12345');
      expect(await service.hasApiKey(), isTrue);
      expect(await service.getApiKey(), 'test-key-12345');

      await service.clearApiKey();
      expect(await service.hasApiKey(), isFalse);
      expect(await service.getApiKey(), isNull);
    });

    test('Updates model, endpoint, and enabled preferences', () async {
      final service = GlmReceiptService.createForTesting();

      await service.setModelName('glm-5.3-flashx');
      expect(await service.getModelName(), 'glm-5.3-flashx');

      await service.setEndpoint(GlmReceiptService.internationalEndpoint);
      expect(await service.getEndpoint(), GlmReceiptService.internationalEndpoint);

      await service.setAiEnabled(false);
      expect(await service.isAiEnabled(), isFalse);
    });
  });

  group('GlmReceiptService Connection Testing', () {
    test('Returns failure when no key is configured', () async {
      final service = GlmReceiptService.createForTesting();
      final result = await service.testConnection();
      expect(result.success, isFalse);
      expect(result.message, contains('No API key provided'));
    });

    test('Returns success on HTTP 200 response', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer mock-key');
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': 'ok'}
              }
            ]
          }),
          200,
        );
      });

      final service = GlmReceiptService.createForTesting(client: mockClient);
      final result = await service.testConnection(apiKeyOverride: 'mock-key');
      expect(result.success, isTrue);
      expect(result.message, contains('Connection successful'));
    });

    test('Returns authentication error on HTTP 401', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error":{"message":"Invalid API key"}}', 401);
      });

      final service = GlmReceiptService.createForTesting(client: mockClient);
      final result = await service.testConnection(apiKeyOverride: 'bad-key');
      expect(result.success, isFalse);
      expect(result.message, contains('401'));
    });

    test('Returns rate limit error on HTTP 429', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error":{"message":"Rate limit exceeded"}}', 429);
      });

      final service = GlmReceiptService.createForTesting(client: mockClient);
      final result = await service.testConnection(apiKeyOverride: 'valid-key');
      expect(result.success, isFalse);
      expect(result.message, contains('429'));
    });
  });

  group('GlmReceiptService Multimodal Receipt Extraction', () {
    test('Throws GlmApiException if API key is missing', () async {
      final service = GlmReceiptService.createForTesting();
      expect(
        () => service.extractReceipt(base64Image: 'dummyBase64Data'),
        throwsA(isA<GlmApiException>()),
      );
    });

    test('Successfully parses valid structured JSON receipt from model response', () async {
      final mockResponse = {
        'choices': [
          {
            'finish_reason': 'stop',
            'message': {
              'content': jsonEncode({
                'merchant': 'Blue Bottle Coffee',
                'totalAmount': 14.50,
                'taxAmount': 1.25,
                'tipAmount': 2.00,
                'date': '2026-11-01',
                'category': 'dining',
                'items': [
                  {
                    'name': 'Cold Brew Coffee',
                    'quantity': 2,
                    'unitPrice': 5.50,
                  },
                  {
                    'name': 'Almond Croissant',
                    'quantity': 1,
                    'unitPrice': 3.50,
                  }
                ]
              }),
              'reasoning_content': 'Extracted coffee receipt details.',
              'role': 'assistant',
            }
          }
        ]
      };

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['model'], 'glm-5.3-flash');
        expect(body['reasoning_effort'], 'low');
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final service = GlmReceiptService.createForTesting(client: mockClient);
      await service.saveApiKey('test-key');

      final extracted = await service.extractReceipt(base64Image: 'validBase64==');

      expect(extracted.merchant, 'Blue Bottle Coffee');
      expect(extracted.totalAmount, 14.50);
      expect(extracted.taxAmount, 1.25);
      expect(extracted.tipAmount, 2.00);
      expect(extracted.date, DateTime(2026, 11, 1));
      expect(extracted.category, 'dining');
      expect(extracted.items.length, 2);
      expect(extracted.items[0].name, 'Cold Brew Coffee');
      expect(extracted.items[0].quantity, 2);
      expect(extracted.items[0].unitPrice, 5.50);
      expect(extracted.items[0].totalPrice, 11.00);
      expect(extracted.items[1].name, 'Almond Croissant');
      expect(extracted.hasExtractedInfo, isTrue);
    });

    test('Robustly handles markdown-wrapped JSON code fences from model', () async {
      const wrappedContent = '''```json
{
  "merchant": "Whole Foods Market",
  "totalAmount": 42.18,
  "taxAmount": 3.10,
  "tipAmount": 0.0,
  "date": "2026-10-15",
  "category": "groceries",
  "items": [
    {"name": "Organic Milk", "quantity": 1, "unitPrice": 4.99}
  ]
}
```''';

      final mockResponse = {
        'choices': [
          {
            'finish_reason': 'stop',
            'message': {
              'content': wrappedContent,
              'role': 'assistant',
            }
          }
        ]
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final service = GlmReceiptService.createForTesting(client: mockClient);
      await service.saveApiKey('test-key');

      final extracted = await service.extractReceipt(base64Image: 'imageBytes');

      expect(extracted.merchant, 'Whole Foods Market');
      expect(extracted.totalAmount, 42.18);
      expect(extracted.taxAmount, 3.10);
      expect(extracted.category, 'groceries');
      expect(extracted.items.length, 1);
      expect(extracted.items[0].name, 'Organic Milk');
    });

    test('Handles HTTP 401 unauthorized gracefully during extraction', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error":{"code":"1001","message":"Invalid API token"}}', 401);
      });

      final service = GlmReceiptService.createForTesting(client: mockClient);
      await service.saveApiKey('invalid-token');

      expect(
        () => service.extractReceipt(base64Image: 'testBytes'),
        throwsA(isA<GlmApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
    });
  });

  group('Live GLM API Integration (if GLM_API_KEY environment set)', () {
    final liveKey = Platform.environment['GLM_API_KEY'];
    if (liveKey != null && liveKey.isNotEmpty) {
      test('Live testConnection to BigModel GLM-5.3-Flash endpoint', () async {
        HttpOverrides.global = null;
        final service = GlmReceiptService.instance;
        final result = await service.testConnection(apiKeyOverride: liveKey);
        expect(result.success, isTrue, reason: result.message);
      });

      test('Live extractReceipt with GLM-5.3-Flash multimodal vision', () async {
        HttpOverrides.global = null;
        final service = GlmReceiptService.instance;
        await service.saveApiKey(liveKey);

        const fixturePath = 'test/fixtures/sample_receipt.png';
        expect(File(fixturePath).existsSync(), isTrue);

        final extracted = await service.extractReceipt(imagePath: fixturePath);
        expect(extracted.merchant?.toLowerCase(), contains('target'));
        expect(extracted.totalAmount, isNotNull);
        expect(extracted.hasExtractedInfo, isTrue);
      });
    }
  });
}

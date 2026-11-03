import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/extracted_receipt_data.dart';
import '../models/receipt_category.dart';
import '../models/receipt_item.dart';

class GlmApiException implements Exception {
  final String message;
  final int? statusCode;

  const GlmApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'GlmApiException: $message${statusCode != null ? ' (Status $statusCode)' : ''}';
}

class GlmTestResult {
  final bool success;
  final String message;

  const GlmTestResult({required this.success, required this.message});
}

class GlmReceiptService {
  static final GlmReceiptService instance = GlmReceiptService._internal();

  final FlutterSecureStorage _secureStorage;
  final http.Client _client;

  // In-memory fallback if secure storage is unavailable on certain platforms/tests
  String? _cachedApiKey;

  static const String _keyApiKey = 'glm_api_key';
  static const String _prefAiEnabled = 'glm_ai_enabled';
  static const String _prefEndpoint = 'glm_api_endpoint';
  static const String _prefModel = 'glm_model_name';

  static const String defaultEndpoint = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  static const String internationalEndpoint = 'https://api.z.ai/api/paas/v4/chat/completions';
  static const String defaultModel = 'glm-5.3-flash';

  GlmReceiptService._internal({
    FlutterSecureStorage? secureStorage,
    http.Client? client,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _client = client ?? http.Client();

  @visibleForTesting
  factory GlmReceiptService.createForTesting({
    FlutterSecureStorage? secureStorage,
    http.Client? client,
  }) {
    return GlmReceiptService._internal(
      secureStorage: secureStorage,
      client: client,
    );
  }

  // ==========================================
  // BYOK & Configuration Management
  // ==========================================

  /// Gets the stored API key from secure storage (or memory fallback)
  Future<String?> getApiKey() async {
    if (_cachedApiKey != null && _cachedApiKey!.isNotEmpty) {
      return _cachedApiKey;
    }
    try {
      final key = await _secureStorage.read(key: _keyApiKey);
      if (key != null && key.isNotEmpty) {
        _cachedApiKey = key;
        return key;
      }
    } catch (e) {
      debugPrint('GlmReceiptService: Secure storage read warning: $e');
    }
    return _cachedApiKey;
  }

  /// Securely saves the user's API key
  Future<void> saveApiKey(String key) async {
    final trimmed = key.trim();
    _cachedApiKey = trimmed;
    try {
      if (trimmed.isEmpty) {
        await _secureStorage.delete(key: _keyApiKey);
      } else {
        await _secureStorage.write(key: _keyApiKey, value: trimmed);
      }
    } catch (e) {
      debugPrint('GlmReceiptService: Secure storage write warning: $e');
    }
  }

  /// Clears the stored API key
  Future<void> clearApiKey() async {
    _cachedApiKey = null;
    try {
      await _secureStorage.delete(key: _keyApiKey);
    } catch (e) {
      debugPrint('GlmReceiptService: Secure storage delete warning: $e');
    }
  }

  /// Checks if an API key is currently configured
  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Whether Cloud AI receipt extraction is enabled by the user
  Future<bool> isAiEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefAiEnabled) ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Sets whether Cloud AI is enabled
  Future<void> setAiEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefAiEnabled, enabled);
    } catch (e) {
      debugPrint('GlmReceiptService: Error saving AI enabled pref: $e');
    }
  }

  /// Gets configured API endpoint
  Future<String> getEndpoint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefEndpoint) ?? defaultEndpoint;
    } catch (_) {
      return defaultEndpoint;
    }
  }

  /// Sets configured API endpoint
  Future<void> setEndpoint(String endpoint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefEndpoint, endpoint.trim());
    } catch (e) {
      debugPrint('GlmReceiptService: Error saving endpoint: $e');
    }
  }

  /// Gets configured model name
  Future<String> getModelName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefModel) ?? defaultModel;
    } catch (_) {
      return defaultModel;
    }
  }

  /// Sets configured model name
  Future<void> setModelName(String model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefModel, model.trim());
    } catch (e) {
      debugPrint('GlmReceiptService: Error saving model name: $e');
    }
  }

  // ==========================================
  // Connection Testing
  // ==========================================

  /// Tests connectivity and API key validity against the GLM endpoint
  Future<GlmTestResult> testConnection({
    String? apiKeyOverride,
    String? endpointOverride,
    String? modelOverride,
  }) async {
    final key = apiKeyOverride?.trim() ?? await getApiKey();
    if (key == null || key.isEmpty) {
      return const GlmTestResult(
        success: false,
        message: 'No API key provided. Please enter your GLM API key.',
      );
    }

    final endpoint = endpointOverride?.trim() ?? await getEndpoint();
    final model = modelOverride?.trim() ?? await getModelName();

    try {
      final uri = Uri.parse(endpoint);
      final response = await _client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $key',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': 'Ping. Reply with ok.'}
          ],
          'reasoning_effort': 'low',
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        return GlmTestResult(
          success: true,
          message: 'Connection successful! Connected to $model.',
        );
      } else if (response.statusCode == 401) {
        return const GlmTestResult(
          success: false,
          message: 'Authentication failed (401). Invalid or expired API key.',
        );
      } else if (response.statusCode == 429) {
        return const GlmTestResult(
          success: false,
          message: 'Rate limit or quota exceeded (429). Check your BigModel account balance.',
        );
      } else {
        String detail = response.body;
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson is Map && errorJson['error'] != null) {
            detail = errorJson['error']['message'] ?? detail;
          }
        } catch (_) {}
        return GlmTestResult(
          success: false,
          message: 'Error ${response.statusCode}: $detail',
        );
      }
    } catch (e) {
      return GlmTestResult(
        success: false,
        message: 'Network error connecting to GLM API: $e',
      );
    }
  }

  // ==========================================
  // Receipt Extraction via GLM-5.3-Flash
  // ==========================================

  /// Extracts structured receipt details using GLM-5.3-Flash multimodal vision API
  Future<ExtractedReceiptData> extractReceipt({
    String? imagePath,
    String? base64Image,
    String? apiKeyOverride,
  }) async {
    final key = apiKeyOverride?.trim() ?? await getApiKey();
    if (key == null || key.isEmpty) {
      throw const GlmApiException('API key not configured. Please add your GLM API key in Settings.');
    }

    // Prepare image URL with proper MIME type
    String imageUrl;

    if (base64Image != null && base64Image.isNotEmpty) {
      if (base64Image.startsWith('data:image/')) {
        imageUrl = base64Image;
      } else {
        String mime = 'image/jpeg';
        if (base64Image.startsWith('iVBORw0KGgo')) {
          mime = 'image/png';
        } else if (base64Image.startsWith('UklGR')) {
          mime = 'image/webp';
        }
        imageUrl = 'data:$mime;base64,$base64Image';
      }
    } else if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw GlmApiException('Receipt image file not found at $imagePath');
      }
      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);

      String mime = 'image/jpeg';
      final lower = imagePath.toLowerCase();
      if (lower.endsWith('.png')) {
        mime = 'image/png';
      } else if (lower.endsWith('.webp')) {
        mime = 'image/webp';
      }
      imageUrl = 'data:$mime;base64,$base64Data';
    } else {
      throw const GlmApiException('No image provided for receipt extraction.');
    }

    final endpoint = await getEndpoint();
    final model = await getModelName();

    const systemPrompt = '''You are an expert receipt parser AI. Analyze the provided receipt image and extract structured information.
Respond with ONLY a single valid JSON object, without any markdown fences, backticks, or additional commentary.
Follow this schema exactly:
{
  "merchant": string or null,
  "totalAmount": number or null,
  "taxAmount": number or null,
  "tipAmount": number or null,
  "date": "YYYY-MM-DD" or null,
  "category": "groceries" | "dining" | "shopping" | "transport" | "utilities" | "entertainment" | "healthcare" | "travel" | "office" | "other",
  "items": [
    {
      "name": "Item description",
      "quantity": 1,
      "unitPrice": 0.00
    }
  ]
}''';

    final payload = {
      'model': model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'Extract all structured fields and line items from this receipt image.'},
            {
              'type': 'image_url',
              'image_url': {
                'url': imageUrl,
              },
            },
          ],
        },
      ],
      'reasoning_effort': 'low',
      'max_tokens': 4096,
      'temperature': 0.1,
    };

    final uri = Uri.parse(endpoint);
    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 401) {
      throw const GlmApiException('Invalid or unauthorized API key (401).', 401);
    } else if (response.statusCode == 429) {
      throw const GlmApiException('BigModel rate limit or balance quota exceeded (429).', 429);
    } else if (response.statusCode != 200) {
      String detail = response.body;
      try {
        final errJson = jsonDecode(response.body);
        if (errJson is Map && errJson['error'] != null) {
          detail = errJson['error']['message'] ?? detail;
        }
      } catch (_) {}
      throw GlmApiException('API returned error ($detail)', response.statusCode);
    }

    final Map<String, dynamic> responseJson;
    try {
      responseJson = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (e) {
      throw GlmApiException('Failed to decode GLM API response: $e');
    }

    final choices = responseJson['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw const GlmApiException('GLM API returned empty choices.');
    }

    final firstChoice = choices[0] as Map<String, dynamic>;
    final message = firstChoice['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String? ?? '';
    final reasoningContent = message?['reasoning_content'] as String?;

    return _parseModelJsonResponse(
      content: content,
      reasoningContent: reasoningContent,
      rawBody: response.body,
    );
  }

  /// Parses the model text content into ExtractedReceiptData
  static ExtractedReceiptData _parseModelJsonResponse({
    required String content,
    String? reasoningContent,
    required String rawBody,
  }) {
    String jsonString = content.trim();

    // Strip markdown formatting if present (```json ... ```)
    if (jsonString.startsWith('```json')) {
      jsonString = jsonString.substring(7);
    } else if (jsonString.startsWith('```')) {
      jsonString = jsonString.substring(3);
    }
    if (jsonString.endsWith('```')) {
      jsonString = jsonString.substring(0, jsonString.length - 3);
    }
    jsonString = jsonString.trim();

    // If still not clean JSON, attempt to locate the outermost {...} block
    if (!jsonString.startsWith('{') || !jsonString.endsWith('}')) {
      final startIndex = jsonString.indexOf('{');
      final endIndex = jsonString.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        jsonString = jsonString.substring(startIndex, endIndex + 1);
      }
    }

    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (e) {
      debugPrint('Failed to parse JSON string: "$jsonString". Error: $e');
    }

    if (data == null) {
      // Return raw content if JSON could not be parsed
      return ExtractedReceiptData(
        rawText: content.isNotEmpty ? content : (reasoningContent ?? rawBody),
      );
    }

    final merchant = data['merchant'] as String?;
    final totalAmount = (data['totalAmount'] as num?)?.toDouble();
    final taxAmount = (data['taxAmount'] as num?)?.toDouble();
    final tipAmount = (data['tipAmount'] as num?)?.toDouble();

    // Parse date safely
    DateTime? parsedDate;
    final rawDate = data['date'];
    if (rawDate is String && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate);
      if (parsedDate == null) {
        // Try mm/dd/yyyy or dd/mm/yyyy
        final parts = rawDate.split(RegExp(r'[-/.]'));
        if (parts.length == 3) {
          final p1 = int.tryParse(parts[0]);
          final p2 = int.tryParse(parts[1]);
          final p3 = int.tryParse(parts[2]);
          if (p1 != null && p2 != null && p3 != null) {
            if (p1 > 1000) {
              parsedDate = DateTime(p1, p2, p3);
            } else if (p3 > 1000) {
              parsedDate = DateTime(p3, p1, p2);
            }
          }
        }
      }
    }

    // Match category
    String? category = data['category'] as String?;
    if (category != null) {
      category = category.trim().toLowerCase();
      final valid = ReceiptCategory.defaults.any((c) => c.id == category);
      if (!valid) {
        category = 'other';
      }
    }

    // Parse items
    final List<ReceiptItem> items = [];
    final rawItems = data['items'];
    if (rawItems is List) {
      const uuid = Uuid();
      for (final item in rawItems) {
        if (item is Map) {
          final name = (item['name'] ?? item['description'] ?? '').toString().trim();
          if (name.isNotEmpty) {
            final qty = (item['quantity'] as num?)?.toInt() ?? 1;
            final price = (item['unitPrice'] as num?)?.toDouble() ??
                (item['price'] as num?)?.toDouble() ??
                0.0;
            items.add(ReceiptItem(
              id: uuid.v4(),
              name: name,
              quantity: qty > 0 ? qty : 1,
              unitPrice: price >= 0 ? price : 0.0,
            ));
          }
        }
      }
    }

    return ExtractedReceiptData(
      merchant: (merchant != null && merchant.isNotEmpty) ? merchant : null,
      totalAmount: totalAmount,
      taxAmount: taxAmount,
      tipAmount: tipAmount,
      date: parsedDate,
      category: category,
      items: items,
      rawText: content.isNotEmpty ? content : (reasoningContent ?? ''),
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:receipt_record/models/receipt.dart';
import 'package:receipt_record/models/summary_data.dart';
import 'package:receipt_record/services/currency_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CurrencyService.instance.init();
  });

  group('CurrencyService Multi-Currency & Conversion Tests', () {
    test('CurrencyService distinguishes JPY and CNY into separate ISO currencies', () {
      final jpy = CurrencyService.instance.getCurrency('JPY');
      final cny = CurrencyService.instance.getCurrency('CNY');

      expect(jpy.code, 'JPY');
      expect(cny.code, 'CNY');
      expect(jpy.symbol, '¥');
      expect(cny.symbol, '¥');
      expect(jpy.name, 'Japanese Yen');
      expect(cny.name, 'Chinese Yuan');
      expect(jpy.flag, '🇯🇵');
      expect(cny.flag, '🇨🇳');
    });

    test('Persists and loads default home base currency', () async {
      expect(CurrencyService.instance.defaultCurrencyNotifier.value, 'USD');

      await CurrencyService.instance.setDefaultCurrency('EUR');
      expect(CurrencyService.instance.defaultCurrencyNotifier.value, 'EUR');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_default_currency'), 'EUR');

      // Re-initialize to verify persistence
      await CurrencyService.instance.init();
      expect(CurrencyService.instance.defaultCurrencyNotifier.value, 'EUR');
    });

    test('getExchangeRate returns 1.0 for same currency', () async {
      final rate = await CurrencyService.instance.getExchangeRate(from: 'USD', to: 'USD');
      expect(rate, 1.0);
    });

    test('getExchangeRate uses online API and caches rates', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString() == 'https://open.er-api.com/v6/latest/USD') {
          return http.Response(
            '{"result":"success","base_code":"USD","rates":{"JPY":155.0,"EUR":0.92}}',
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      CurrencyService.instance.client = mockClient;

      final rate = await CurrencyService.instance.getExchangeRate(from: 'USD', to: 'JPY');
      expect(rate, 155.0);

      // Verify cached in SharedPreferences
      final cached = await CurrencyService.instance.getExchangeRate(from: 'USD', to: 'EUR');
      expect(cached, 0.92);
    });

    test('Receipt model calculates effectiveAmount and isForeignCurrency accurately', () {
      final now = DateTime(2026, 11, 2);

      // Standard home currency receipt
      final homeReceipt = Receipt(
        id: 'r_home',
        merchant: 'Costco',
        amount: 100.0,
        currency: 'USD',
        baseCurrency: 'USD',
        date: now,
        category: 'groceries',
        createdAt: now,
        updatedAt: now,
      );
      expect(homeReceipt.effectiveAmount, 100.0);
      expect(homeReceipt.isForeignCurrency, false);

      // Foreign currency receipt (15,000 JPY converted to 96.75 USD)
      final foreignReceipt = Receipt(
        id: 'r_foreign',
        merchant: 'Tokyo Ramen',
        amount: 15000.0,
        currency: 'JPY',
        baseCurrency: 'USD',
        exchangeRate: 0.00645,
        convertedAmount: 96.75,
        date: now,
        category: 'dining',
        createdAt: now,
        updatedAt: now,
      );
      expect(foreignReceipt.effectiveAmount, 96.75);
      expect(foreignReceipt.isForeignCurrency, true);
    });

    test('SummaryData aggregates foreign receipts using effectiveAmount in home currency', () {
      final now = DateTime(2026, 11, 2);
      final receipts = [
        Receipt(
          id: 'r1',
          merchant: 'Local Supermarket',
          amount: 50.0,
          currency: 'USD',
          date: now,
          category: 'groceries',
          createdAt: now,
          updatedAt: now,
        ),
        Receipt(
          id: 'r2',
          merchant: 'Tokyo Electronics',
          amount: 15000.0,
          currency: 'JPY',
          baseCurrency: 'USD',
          exchangeRate: 0.00645,
          convertedAmount: 96.75,
          date: now,
          category: 'electronics',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final summary = SummaryData.fromReceipts(receipts);

      // Total should be 50.0 + 96.75 = 146.75 USD (not 15,050!)
      expect(summary.totalSpending, closeTo(146.75, 0.01));
      expect(summary.categorySpending['electronics'], closeTo(96.75, 0.01));
      expect(summary.categorySpending['groceries'], closeTo(50.0, 0.01));
    });
  });
}

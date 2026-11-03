import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final String flag;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });

  String get displayName => '$flag $code ($symbol)';
}

class CurrencyService {
  static final CurrencyService instance = CurrencyService._internal();
  http.Client _client = http.Client();

  CurrencyService._internal();

  @visibleForTesting
  set client(http.Client client) => _client = client;

  static const String _defaultCurrencyKey = 'app_default_currency';
  static const String _ratesCachePrefix = 'app_rates_cache_';
  static const String _ratesCacheTimePrefix = 'app_rates_time_';

  final ValueNotifier<String> defaultCurrencyNotifier = ValueNotifier<String>('USD');

  static const List<CurrencyInfo> supportedCurrencies = [
    CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar', flag: '🇺🇸'),
    CurrencyInfo(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', flag: '🇨🇳'),
    CurrencyInfo(code: 'JPY', symbol: '¥', name: 'Japanese Yen', flag: '🇯🇵'),
    CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro', flag: '🇪🇺'),
    CurrencyInfo(code: 'GBP', symbol: '£', name: 'British Pound', flag: '🇬🇧'),
    CurrencyInfo(code: 'TWD', symbol: 'NT\$', name: 'New Taiwan Dollar', flag: '🇹🇼'),
    CurrencyInfo(code: 'HKD', symbol: 'HK\$', name: 'Hong Kong Dollar', flag: '🇭🇰'),
    CurrencyInfo(code: 'CAD', symbol: 'CA\$', name: 'Canadian Dollar', flag: '🇨🇦'),
    CurrencyInfo(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar', flag: '🇦🇺'),
    CurrencyInfo(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar', flag: '🇸🇬'),
    CurrencyInfo(code: 'KRW', symbol: '₩', name: 'South Korean Won', flag: '🇰🇷'),
    CurrencyInfo(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc', flag: '🇨🇭'),
  ];

  static const Map<String, double> _fallbackUsdRates = {
    'USD': 1.0,
    'CNY': 7.23,
    'JPY': 154.5,
    'EUR': 0.92,
    'GBP': 0.79,
    'TWD': 32.2,
    'HKD': 7.82,
    'CAD': 1.38,
    'AUD': 1.52,
    'SGD': 1.35,
    'KRW': 1380.0,
    'CHF': 0.88,
  };

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_defaultCurrencyKey);
      if (saved != null && supportedCurrencies.any((c) => c.code == saved)) {
        defaultCurrencyNotifier.value = saved;
      }
    } catch (e) {
      debugPrint('CurrencyService init warning: $e');
    }
  }

  Future<void> setDefaultCurrency(String code) async {
    defaultCurrencyNotifier.value = code;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_defaultCurrencyKey, code);
    } catch (e) {
      debugPrint('Error saving default currency: $e');
    }
  }

  CurrencyInfo getCurrency(String code) {
    return supportedCurrencies.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => CurrencyInfo(code: code, symbol: code, name: code, flag: '🌐'),
    );
  }

  String getSymbol(String code) {
    return getCurrency(code).symbol;
  }

  /// Fetches real-time exchange rate from -> to using open.er-api.com
  /// Includes offline SharedPreferences caching and baked-in fallback rates
  Future<double> getExchangeRate({
    required String from,
    required String to,
  }) async {
    final fromCode = from.toUpperCase();
    final toCode = to.toUpperCase();

    if (fromCode == toCode) return 1.0;

    // Try online API
    try {
      final uri = Uri.parse('https://open.er-api.com/v6/latest/$fromCode');
      final response = await _client.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['result'] == 'success' && data['rates'] is Map) {
          final rates = Map<String, dynamic>.from(data['rates'] as Map);
          if (rates.containsKey(toCode)) {
            final rateVal = (rates[toCode] as num).toDouble();
            // Cache in background
            _cacheRates(fromCode, rates);
            return rateVal;
          }
        }
      }
    } catch (e) {
      debugPrint('CurrencyService online fetch failed ($e). Using cached/fallback rate.');
    }

    // Try offline cache
    final cachedRate = await _getCachedRate(fromCode, toCode);
    if (cachedRate != null) return cachedRate;

    // Fallback static matrix
    return _calculateFallbackRate(fromCode, toCode);
  }

  Future<void> _cacheRates(String base, Map<String, dynamic> rates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_ratesCachePrefix$base', json.encode(rates));
      await prefs.setInt('$_ratesCacheTimePrefix$base', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  Future<double?> _getCachedRate(String from, String to) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_ratesCachePrefix$from');
      if (raw != null) {
        final data = json.decode(raw);
        if (data is Map && data.containsKey(to)) {
          return (data[to] as num).toDouble();
        }
      }
    } catch (_) {}
    return null;
  }

  double _calculateFallbackRate(String from, String to) {
    final fromRateToUsd = _fallbackUsdRates[from] ?? 1.0;
    final toRateToUsd = _fallbackUsdRates[to] ?? 1.0;
    // from -> USD -> to
    return toRateToUsd / fromRateToUsd;
  }
}

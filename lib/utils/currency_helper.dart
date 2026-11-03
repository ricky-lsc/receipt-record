import 'package:intl/intl.dart';
import '../services/currency_service.dart';

class CurrencyHelper {
  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static String format(double amount, {String symbol = '\$'}) {
    if (symbol == '\$') {
      return _formatter.format(amount);
    }
    final customFormatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return customFormatter.format(amount);
  }

  static String formatWithCode(double amount, String code) {
    final symbol = CurrencyService.instance.getSymbol(code);
    return format(amount, symbol: symbol);
  }

  static String formatCompact(double amount, {String symbol = '\$'}) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}k';
    }
    return format(amount, symbol: symbol);
  }
}

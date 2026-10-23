import 'package:intl/intl.dart';

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

  static String formatCompact(double amount, {String symbol = '\$'}) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}k';
    }
    return format(amount, symbol: symbol);
  }
}

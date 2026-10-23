import 'package:intl/intl.dart';

class DateHelper {
  static String formatReceiptDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (itemDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else if (itemDate.year == today.year) {
      return DateFormat('MMM d, h:mm a').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatDateIso(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTimeIso(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}

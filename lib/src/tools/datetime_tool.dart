import 'package:intl/intl.dart';

class DateTimeTool {
  static String formatyyyyMMdd(DateTime datetime) {
    final formatter = DateFormat('yyyy-MM-dd');

    return formatter.format(datetime);
  }

  static String formatddMMyy(DateTime datetime) {
    final formatter = DateFormat('dd-MM-yy');
    return formatter.format(datetime);
  }

  static String formatHHmm(DateTime datetime) {
    final formatter = DateFormat('hh:mm a');
    return formatter.format(datetime);
  }

  static DateTime getTodayMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

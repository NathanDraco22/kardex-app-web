import 'package:intl/intl.dart';

class DateTimeTool {
  static String formatyyyyMMdd(DateTime datetime) {
    final formatter = DateFormat('yyyy-MM-dd');

    return formatter.format(datetime);
  }

  static String formatddMMyyyy(DateTime datetime) {
    final formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(datetime);
  }
}

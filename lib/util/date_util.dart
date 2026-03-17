import 'package:intl/intl.dart';

class DateUtil {
  static String timestamp2Date(String value) {
    if (value.isEmpty) {
      return '-';
    }
    int timestamp = int.parse(value);
    if (timestamp < 10000000000) {
      timestamp *= 1000;
    }
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }
}

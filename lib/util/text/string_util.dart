import 'package:intl/intl.dart';

class StringUtil {
  static String amountFormat(String value) {
    if (value.isEmpty) {
      return '-';
    }
    double amount = double.parse(value);
    NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: 'R\$',
    );
    String result = currencyFormat.format(amount);
    return result;
  }

  /// 获取整数部分
  static String getIntegerPart(String num) {
    if (num.isEmpty) {
      return '-';
    }
    double amount = double.parse(num);
    var int = amount.toInt();
    return "R\$${int.toString()}";
  }
}

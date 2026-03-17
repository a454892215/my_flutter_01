import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_comm/util/toast_util.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Log.dart';

class AppUtil {
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

  static String amountFormat(String value) {
    if (value.isEmpty) {
      return '-';
    }
    double amount = double.parse(value);
    NumberFormat currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: 'R\$');
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

  static void copy(String value) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      Toast.show('复制成功！');
    } catch (e) {
      Toast.show('复制失败!');
      Log.d('复制失败!');
    }
  }

  static Future<void> launch(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Toast.show('无法打开链接！');
    }
  }

  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// 比较当前 App 版本与目标版本 [targetVersion]
  /// 如果 [targetVersion] 高于当前版本，返回 true (需要更新)
  static Future<bool> isUpdateRequired(String targetVersion) async {
    // 获取当前版本，例如 "1.0.0" 或 "1.2"
    final String currentVersion = await getAppVersion();

    // 使用 split 分割版本号层级
    final List<String> currentList = currentVersion.split('.');
    final List<String> targetList = targetVersion.split('.');

    // 1. 确定最大循环长度，避免 IndexOutOfBoundsException
    // 例如比较 "1.1" 和 "1.1.2" 时，应循环 3 次
    final int maxLength = currentList.length > targetList.length
        ? currentList.length
        : targetList.length;

    for (int i = 0; i < maxLength; i++) {
      // 2. 补位逻辑：如果索引超出当前数组长度，则补 0
      // 使用 int.tryParse 替代 int.parse，防止非数字字符串导致 crash
      final int currentNum = i < currentList.length
          ? int.tryParse(currentList[i]) ?? 0
          : 0;

      final int targetNum = i < targetList.length
          ? int.tryParse(targetList[i]) ?? 0
          : 0;

      // 3. 逐位比较
      if (targetNum > currentNum) {
        return true; // 目标版本更高
      } else if (targetNum < currentNum) {
        return false; // 当前版本更高或已是最新
      }
      // 如果相等，则继续循环比较下一位（如 1.x.x）
    }

    // 循环结束仍相等（如 "1.2.0" 与 "1.2"），无需更新
    return false;
  }
}

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_comm/util/toast_util.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
      Toast.show('Copied!');
    } catch (e) {
      Toast.show('replicação falhou');
      print(e);
    }
  }

  static launch(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Toast.show('Não foi possível abrir o link');
    }
  }

  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  // 对比版本号
  static Future<bool> compareVersion(String version) async {
    String currentVersion = await getAppVersion();
    List<String> currentVersionList = currentVersion.split('.');
    List<String> versionList = version.split('.');
    for (int i = 0; i < versionList.length; i++) {
      int currentVersionNum = int.parse(currentVersionList[i]);
      int versionNum = int.parse(versionList[i]);
      if (currentVersionNum < versionNum) {
        return true;
      } else if (currentVersionNum > versionNum) {
        return false;
      }
    }
    return false;
  }
}

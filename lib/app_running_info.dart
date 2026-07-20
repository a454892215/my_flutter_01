import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppRunningInfo {
  static int appStartTs = 0;
  static bool isHomeHasInitState = false;
  static PackageInfo? info;
  static Future<void> init() async {
    appStartTs = DateTime.now().millisecondsSinceEpoch;
    info = await PackageInfo.fromPlatform();
  }

  /// 返回秒：从 App 启动到当前
  static double getDurationFromAppStartTsToCurTs() {
    return ((DateTime.now().millisecondsSinceEpoch - appStartTs) / 1000.0);
  }

  /// 返回秒：从目标时间戳到当前
  static double getDurationFromTarTsToCurTs(int ts) {
    return ((DateTime.now().millisecondsSinceEpoch - ts) / 1000.0);
  }

  static String platform() {
    if (kIsWeb) return "WEB";
    if (Platform.isAndroid) return "ANDROID";
    if (Platform.isIOS) return "IOS";
    return "UNKNOWN";
  }
}

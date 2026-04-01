import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_comm/widget/toast_util.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtil {

  static String _appVersion = "";
  static String _platform = "";

  // 暴露只读 getter，外部通过 SysUtil.deviceId 直接同步访问
  static String get appVersion => _appVersion;
  static String get platform => _platform;

  static void init() async{
    _appVersion = await getAppVersion();
    _platform = platformName;
  }

  // 是否是 H5
  static bool get isH5 => kIsWeb;

  // 是否是 Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  // 是否是 iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  // 获取平台名称字符串
  static String get platformName {
    if (kIsWeb) return "H5";
    if (Platform.isAndroid) return "Android";
    if (Platform.isIOS) return "iOS";
    return "Unknown";
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

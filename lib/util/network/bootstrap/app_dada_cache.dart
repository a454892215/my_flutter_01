import 'dart:convert';

import 'package:flutter_comm/util/Log.dart';


/// 冷启动域名探测若命中 [app-version/check]，缓存响应供 [RequestCheckAppVersion] 复用，避免二次请求。
class AppDataCache {
  AppDataCache._();

  static final Map<String, dynamic> _byBaseUrl = {};

  static void clear() => _byBaseUrl.clear();

  static const String appVersionCheckKey = "key_app_version_check";


  /// 探测成功且 [probePath] 为版本检查接口时写入。
  static void save(String key,  dynamic responseBody) {
    try {
      final dynamic json = responseBody is String ? jsonDecode(responseBody) : responseBody;
      _byBaseUrl[key] = json;
      Log.d('$key 接口-数据缓存成功：$key');
    } catch (e, st) {
      Log.d('接口数据缓存失败：$e  $st');
    }
  }

  /// 取出与 [baseUrl] 匹配的缓存（一次性消费）。
  static dynamic take(String key) {
    if (key.isEmpty) return null;
    return _byBaseUrl.remove(key);
  }
}

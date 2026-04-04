import 'dart:async';

import 'package:dio/dio.dart';

import '../util/Log.dart';
import 'base_api_service.dart';

/// 统一处理 APP 级别的 Token、公共请求参数， 请求头 和 响应信息
class AppApiService extends BaseApiService {
  AppApiService._internal() : super("https://www.huadc878.com/api/");

  static final AppApiService _instance = AppApiService._internal();

  factory AppApiService() => _instance;

  Future<bool> setFastestBaseUrl(List<String> baseUrlList, String path) async {
    if (baseUrlList.isEmpty) {
      Log.e("baseUrlList isEmpty");
      return false;
    }
    final completer = Completer<String>();
    final List<CancelToken> tokens = [];
    for (var baseUrl in baseUrlList) {
      final token = CancelToken();
      tokens.add(token);
      final String fullUrl = baseUrl + path;
      get<Map<String, dynamic>>(fullUrl, cancelToken: token)
          .then((_) {
            if (!completer.isCompleted) {
              completer.complete(baseUrl);
            }
          })
          .catchError((e) {
            if (!CancelToken.isCancel(e)) {
              Log.e("setFastestBaseUrl: $e");
            }
          });
    }
    try {
      String fastest = await completer.future.timeout(Duration(seconds: 10));
      setBaseUrl(fastest);
      return true;
    } catch (e) {
      return false;
    } finally {
      for (var t in tokens) {
        if (!t.isCancelled) t.cancel("setFastestBaseUrl finished");
      }
    }
  }

  dynamic login(dynamic data) {
    return post('api/login', data: data);
  }

  dynamic register(dynamic data) {
    return post('api/register', data: data);
  }

  dynamic getActivityList(dynamic data) {
    return post('api/activity/list', data: data);
  }
}

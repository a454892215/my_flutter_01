import 'package:dio/dio.dart';

import '../util/Log.dart';
import '../util/app_util.dart';
import '../util/sp/sp_util.dart';
import '../util/system_util.dart';


class AuthInterceptor extends Interceptor {
  static const String spKeyToken = "sp_key_token";
  static String _token = "";

  // 外部注入失效回调
  final Function()? onTokenExpired;

  AuthInterceptor({this.onTokenExpired});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1. 获取并注入 Token
    final token = _getAppToken();
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 2. 注入公共参数
    options.headers['Platform'] = AppUtil.platform;
    options.headers['App-Version'] = AppUtil.appVersion;
    options.headers['Device-ID'] = SysUtil.deviceId;

    // 3. 注入 Query 参数 (ts, device_id)
    options.queryParameters.addAll({
      'device_id': SysUtil.deviceId,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 1. 自动从 Header 更新 Token
    _autoUpdateTokenFromHeaders(response.headers.map);

    // 2. 拦截业务状态码 (4001)
    // 假设你的接口结构是 {code: 4001, data: ...}
    final responseData = response.data;
    if (responseData is Map && responseData['code'] == 4001) {
      _handleTokenExpired();
      // 可以选择 reject 一个 DioException 或者直接返回 response
    }

    return handler.next(response);
  }

  // --- 逻辑私有化 ---

  String _getAppToken() {
    if (_token.isNotEmpty) return _token;
    _token = spUtil.getString(spKeyToken, def: "");
    return _token;
  }

  void _autoUpdateTokenFromHeaders(Map<String, List<String>> headers) {
    final authValues = headers['Authorization'] ?? headers['authorization'] ?? headers['token'];
    if (authValues != null && authValues.isNotEmpty) {
      String rawToken = authValues.first;
      String newToken = rawToken.toLowerCase().startsWith("bearer ")
          ? rawToken.substring(7).trim()
          : rawToken;

      if (newToken.isNotEmpty && newToken != _token) {
        _token = newToken;
        spUtil.setString(spKeyToken, newToken);
        Log.d("AUTH: Token auto-updated.");
      }
    }
  }

  void _handleTokenExpired() {
    _token = "";
    spUtil.setString(spKeyToken, "");
    onTokenExpired?.call();
  }
}
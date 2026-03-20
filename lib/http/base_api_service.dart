import 'package:dio/dio.dart';
import 'package:flutter_comm/util/sp/sp_util.dart';
import '../util/Log.dart';
import '../util/app_util.dart';
import '../util/system_util.dart';
import 'core/base_abs_api_service.dart';
import 'core/response.dart';

/// 登录失效的回调定义
typedef OnTokenExpired = void Function();

/// 统一处理 APP 级别的 Token、公共请求参数， 请求头 和 响应信息
class BaseApiService extends BaseAbsApiService {

  // 允许外部注入失效回调（如在 App 启动时注入跳转登录页的逻辑）
  static OnTokenExpired? onTokenExpired;

  BaseApiService(super.baseUrl) : super(isCborEnabled: false);

  static const spKeyToken = "sp_key_token";

  // 使用静态变量，确保全局只有一份内存缓存
  static String _token = "";

  /// 更新 Token：同步内存和本地存储
  void updateToken(String newToken) {
    if (newToken.isEmpty || newToken == _token) return;
    _token = newToken;
    // 异步写入 SP，不阻塞后续逻辑
    spUtil.setString(spKeyToken, newToken);
    Log.d("API_SERVICE: Token updated and persisted.");
  }

  /// 清除 Token
  void clearToken() {
    _token = "";
    spUtil.setString(spKeyToken, "");
  }

  /// 核心逻辑：从响应头中自动提取 Token 并更新
  void _autoUpdateTokenFromHeaders(Map<String, List<String>>? headers) {
    if (headers == null) return;

    // 兼容处理：有些后端可能放在 'x-auth-token' 或自定义字段
    final authValues = headers['Authorization'] ??
        headers['authorization'] ??
        headers['token'];

    if (authValues != null && authValues.isNotEmpty) {
      String rawToken = authValues.first;
      String newToken = rawToken;

      // 剔除 "Bearer " 前缀 (忽略大小写)
      if (rawToken.toLowerCase().startsWith("bearer ")) {
        newToken = rawToken.substring(7).trim();
      }

      if (newToken.isNotEmpty && newToken != _token) {
        Log.d("API_SERVICE: New Token detected in headers.");
        updateToken(newToken);
      }
    }
  }

  Future<T?> requestData<T>(
      String path, {
        String method = 'GET',
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Options? options,
        CancelToken? cancelToken,
        T Function(dynamic json)? decoder,
      }) async {
    // 1. 获取当前可用 Token
    final currentToken = _getAppToken();

    // 2. 构造公共 Headers
    final Map<String, dynamic> commonHeaders = {
      if (currentToken.isNotEmpty) 'Authorization': 'Bearer $currentToken',
      'Platform': AppUtil.platform,
      'App-Version': AppUtil.appVersion,
      'Device-ID': SysUtil.deviceId,
    };

    final Map<String, dynamic> mergedHeaders = {
      ...commonHeaders,
      ...?headers,
    };

    // 3. 构造公共 Query 参数
    final Map<String, dynamic> mergedQueryParameters = {
      'device_id': SysUtil.deviceId,
      'ts': DateTime.now().millisecondsSinceEpoch,
      ...?queryParameters,
    };

    try {
      // 4. 执行请求
      // 注意：NetworkResponse<T> 必须能访问到原始 response.headers
      NetworkResponse<T> response = await super.request<T>(
        path,
        method: method,
        data: data,
        queryParameters: mergedQueryParameters,
        headers: mergedHeaders,
        cancelToken: cancelToken,
        options: options,
        decoder: decoder,
      );

      // 5. 自动更新 Token (续期逻辑)
      _autoUpdateTokenFromHeaders(response.headers);

      // 6. 统一业务状态码拦截
      if (response.statusCode == 4001) {
        _handleTokenExpired();
        return null;
      }

      return response.data;

    } on DioException catch (e) {
      // 在这里可以增加通用的网络错误处理日志
      Log.e("API_SERVICE_ERROR: [${e.type}] ${e.message}");
      rethrow;
    }
  }

  /// 获取本地存储或内存中的 Token
  String _getAppToken() {
    if (_token.isNotEmpty) return _token;
    // 如果 spUtil 未初始化完成，这里可能会报错，确保 main 中已 await
    _token = spUtil.getString(spKeyToken, def: "");
    return _token;
  }

  /// 处理 Token 失效
  void _handleTokenExpired() {
    if (_token.isEmpty) return; // 避免重复触发
    clearToken();
    Log.e("API_SERVICE: Token Expired (4001).");

    // 执行外部注入的跳转登录逻辑
    onTokenExpired?.call();
  }

  // --- 快速调用封装 ---

  Future<T?> get<T>(String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic json)? decoder,
  }) => requestData(path, method: 'GET', queryParameters: queryParameters, headers: headers, decoder: decoder);

  Future<T?> post<T>(String path, {
    dynamic data,
    Map<String, dynamic>? headers,
    T Function(dynamic json)? decoder,
  }) => requestData(path, method: 'POST', data: data, headers: headers, decoder: decoder);
}
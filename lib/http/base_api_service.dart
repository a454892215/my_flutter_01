import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // 用于 @nonVirtual
import '../util/app_util.dart';
import '../util/system_util.dart';
import 'core/base_abs_api_service.dart';
import 'core/response.dart';

/// 统一处理 APP 级别的 Token、公共请求参数， 请求头 和 响应信息
class BaseApiService extends BaseAbsApiService {
  BaseApiService(super.baseUrl) : super(isCborEnabled: false);

  /// 重写父类 request 方法，在这里注入 APP 业务逻辑
  @nonVirtual
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

    // --- 1. 处理公共 Headers (如 Token) ---
    final Map<String, dynamic> commonHeaders = {
      'Authorization': 'Bearer ${_getAppToken()}',
      'Platform': AppUtil.platform,
      'Version': AppUtil.appVersion, // 实际开发中通过 package_info_plus 获取
    };
    // 合并 Headers (外部传入的 headers 优先级更高)
    final Map<String, dynamic> mergedHeaders = {
      ...commonHeaders,
      ...?headers,
    };

    // --- 2. 处理 URL 公共 Query 参数 (如 DeviceId, Timestamp) ---
    final Map<String, dynamic> commonQueryParams = {
      'device_id': SysUtil.deviceId,
      'ts': DateTime.now().millisecondsSinceEpoch,
    };

    // 合并 QueryParameters
    final Map<String, dynamic> mergedQueryParameters = {
      ...commonQueryParams,
      ...?queryParameters,
    };

    // --- 3. 处理 POST Body 的公共注入 (可选) ---
    dynamic finalData = data;
    if (method == 'POST' && data is Map<String, dynamic>) {
      // 如果业务要求 Body 里也带公共字段，可以在这里 addAll
      // finalData = {...data, 'common_field': 'value'};
    }

    // --- 4. 调用父类 BaseAbsApiService 的原始 request 执行请求与解析 ---
    NetworkResponse<T> response = await super.request<T>(
      path,
      method: method,
      data: finalData,
      queryParameters: mergedQueryParameters,
      headers: mergedHeaders,
      cancelToken: cancelToken,
      options: options,
      decoder: decoder,
    );

    // --- 5. 统一业务拦截 (例如处理 401 或特定的业务错误码) ---
    if (response.statusCode == 401) {
      _handleTokenExpired();
    }
    return response.data;
  }

  /// 模拟获取本地存储的 Token
  String _getAppToken() {
    // 实际逻辑：从 SharedPreferences 或全局变量读取
    return "your_app_token_here";
  }

  /// 模拟处理 Token 失效
  void _handleTokenExpired() {
    // 实际逻辑：跳转登录页或弹出通知
  }


  Future<T?> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Options? options,
        CancelToken? cancelToken,
        T Function(dynamic json)? decoder,
      }) async {
    return requestData(
      path,
      method: 'GET',
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      options: options,
      decoder: decoder,
    );
  }

  Future<T?> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? headers,
        Options? options,
        CancelToken? cancelToken,
        T Function(dynamic json)? decoder,
      }) async {
    return requestData(
      path,
      method: 'POST',
      data: data,
      headers: headers,
      cancelToken: cancelToken,
      options: options,
      decoder: decoder,
    );
  }
}
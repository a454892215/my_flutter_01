import 'package:dio/dio.dart';


import 'core/base_abs_api_service.dart';
import 'core/response.dart';


/// 统一处理 处理token 和 请求参数和 响应信息
class BaseApiService extends BaseAbsApiService {
  BaseApiService(super.baseUrl): super(isCborEnabled: false);

  Future<NetworkResponse<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Options? options,
        CancelToken? cancelToken,
        T Function(dynamic json)? decoder,
      }) async {
     return request(
       path,
       method: 'GET',
       queryParameters: queryParameters,
       headers: headers,
       cancelToken: cancelToken,
       options: options,
     );
  }

  Future<NetworkResponse<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? headers,
        Options? options,
        CancelToken? cancelToken,
        T Function(dynamic json)? decoder,
      }) async {
    return request(
      path,
      method: 'POST',
      data: data,
      headers: headers,
      cancelToken: cancelToken,
      options: options,
    );
  }
}

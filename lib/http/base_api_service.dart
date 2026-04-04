import 'package:dio/dio.dart';
import '../util/Log.dart';
import 'core/base_abs_api_service.dart';
import 'core/response.dart';

/// 登录失效的回调定义
typedef OnTokenExpired = void Function();

/// 统一处理 APP 级别的 Token、公共请求参数， 请求头 和 响应信息
class BaseApiService extends BaseAbsApiService {


  BaseApiService(super.baseUrl) : super(isCborEnabled: false);

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

    // 3. 构造公共 Query 参数
    // final Map<String, dynamic> mergedQueryParameters = {
    //   'device_id': SysUtil.deviceId,
    //   'ts': DateTime.now().millisecondsSinceEpoch,
    //   ...?queryParameters,
    // };

    try {
      // 4. 执行请求
      // 注意：NetworkResponse<T> 必须能访问到原始 response.headers
      NetworkResponse<T> response = await super.request<T>(
        path,
        method: method,
        data: data,
        queryParameters: queryParameters,
        headers: headers,
        cancelToken: cancelToken,
        options: options,
        decoder: decoder,
      );
      // // 6. 统一业务状态码拦截
      // if (response.statusCode == 4001) {
      // }
      return response.data;
    } on DioException catch (e) {
      // 在这里可以增加通用的网络错误处理日志
      Log.e("API_SERVICE_ERROR: [${e.type}] ${e.message}");
      rethrow;
    }
  }

  // --- 快速调用封装 ---

  Future<T?> get<T>(String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic json)? decoder,
    CancelToken? cancelToken,
  }) => requestData(path, method: 'GET', queryParameters: queryParameters, headers: headers, decoder: decoder, cancelToken: cancelToken);

  Future<T?> post<T>(String path, {
    dynamic data,
    Map<String, dynamic>? headers,
    T Function(dynamic json)? decoder,
    CancelToken? cancelToken,
  }) => requestData(path, method: 'POST', data: data, headers: headers, decoder: decoder, cancelToken: cancelToken);
}
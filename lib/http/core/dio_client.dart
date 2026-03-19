import 'dart:typed_data';
import 'package:cbor/cbor.dart';
import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import '../../util/Log.dart';
import 'response.dart';

class DioClient {
  static final Map<String, DioClient> _instanceMap = {};
  late final Dio _dio;
  final String baseUrl;
  final bool isCborEnabled;

  DioClient._internal(this.baseUrl, this.isCborEnabled) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.bytes,
        // 强制字节流，确保底层一致性
        contentType: isCborEnabled ? 'application/cbor' : 'application/json',
        validateStatus: (status) => true, // 允许所有状态码，由业务层 NetworkResponse 处理
      ),
    );

    _dio.httpClientAdapter = Http2Adapter(
      ConnectionManager(
        idleTimeout: const Duration(seconds: 15),
        onClientCreate: (_, config) => config.onBadCertificate = (_) => true,
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false,
        logPrint: (obj) => Log.d(obj.toString()),
      ),
    );
  }

  factory DioClient({required String baseUrl, bool isCborEnabled = false}) {
    return _instanceMap.putIfAbsent(
      baseUrl,
      () => DioClient._internal(baseUrl, isCborEnabled),
    );
  }

  /// 纯粹的网络请求方法
  Future<NetworkResponse<Uint8List>> request(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    Response<Uint8List>? response;

    try {
      dynamic requestData = data;
      // 处理发送端的 CBOR 编码
      if (isCborEnabled && data is Map<String, dynamic>) {
        requestData = Uint8List.fromList(cbor.encode(CborValue(data)));
      }

      response = await _dio.request<Uint8List>(
        path,
        data: requestData,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: (options ?? Options()).copyWith(
          method: method,
          headers: headers,
        ),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        Log.d("[Network] 请求手动取消: ${e.requestOptions.path}");
        return NetworkResponse<Uint8List>(
          isCancelled: true,
          statusMessage: "Request cancelled by user",
          headers: {},
        );
      }

      _logError(e);

      // 即使发生异常（如 500），如果服务端有返回二进制 Body，依然尝试保留以供业务分析
      if (e.response != null && e.response!.data is Uint8List) {
        response = e.response as Response<Uint8List>;
      } else {
        // 构造一个包含错误信息的空响应
        return NetworkResponse<Uint8List>(
          statusCode: e.response?.statusCode,
          statusMessage: e.message,
          headers: e.response?.headers.map ?? {},
        );
      }
    } catch (e) {
      Log.e("[Network] 底层未知异常: $e");
      return NetworkResponse<Uint8List>(statusMessage: e.toString());
    }

    // 正常返回或带 Body 的错误返回
    return NetworkResponse<Uint8List>(
      data: response.data,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      headers: response.headers.map,
      isCancelled: false,
    );
  }

  void _logError(DioException e) {
    final url = e.requestOptions.uri.toString();
    final code = e.response?.statusCode ?? "N/A";
    Log.e(
      "[Network Error] URL: $url, Code: $code, Type: ${e.type}, Msg: ${e.message}",
    );
  }
}

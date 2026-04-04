import 'dart:typed_data';
import 'package:cbor/cbor.dart';
import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import '../../util/Log.dart';
import '../auth_interceptor.dart';
import 'log_interceptor.dart';
import 'response.dart';

class DioClient {
  static final Map<String, DioClient> _instanceMap = {};
  late final Dio _dio;
 // final String baseUrl;
  final bool isCborEnabled;

  DioClient._internal(this.isCborEnabled) {
    _dio = Dio(
      BaseOptions(
       // baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        responseType: ResponseType.bytes,
        contentType: isCborEnabled ? 'application/cbor' : 'application/json',
        validateStatus: (status) => true,
      ),
    );

    _dio.httpClientAdapter = Http2Adapter(
      ConnectionManager(
        idleTimeout: const Duration(seconds: 15),
        onClientCreate: (_, config) => config.onBadCertificate = (_) => true,
      ),
    );

    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(SingleLogInterceptor());
  }

  factory DioClient({String key = "default", bool isCborEnabled = false}) {
    return _instanceMap.putIfAbsent(key, () => DioClient._internal(isCborEnabled),
    );
  }

  Future<NetworkResponse<Uint8List>> request(
      String url, {
        String method = 'GET',
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Options? options,
      }) async {
    Response<Uint8List>? dioResponse;
    bool isCancelled = false;
    String? errorMsg;
    try {
      dynamic requestData = data;
      if (isCborEnabled && data is Map<String, dynamic>) {
        requestData = Uint8List.fromList(cbor.encode(CborValue(data)));
      }
      dioResponse = await _dio.request<Uint8List>(
        url,
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
        isCancelled = true;
        errorMsg = "Request cancelled by user";
        Log.d("[Network] 请求手动取消: ${e.requestOptions.path}");
      } else {
        _logError(e);
        errorMsg = e.error?.toString() ?? e.message ?? "Unknown Dio Error";
        // 如果有响应体（如 500 错误带的 JSON），赋值给 dioResponse 以便后续返回
        if (e.response != null && e.response!.data is Uint8List) {
          dioResponse = e.response as Response<Uint8List>;
        }
      }
    } catch (e) {
      Log.e("[Network] 底层未知异常: $e");
      errorMsg = e.toString();
    }

    // 统一出口
    return NetworkResponse<Uint8List>(
      data: dioResponse?.data,
      statusCode: dioResponse?.statusCode,
      statusMessage: dioResponse?.statusMessage ?? errorMsg,
      headers: dioResponse?.headers.map ?? {},
      isCancelled: isCancelled,
    );
  }

  void _logError(DioException e) {
    final url = e.requestOptions.uri.toString();
    final code = e.response?.statusCode ?? "N/A";

    // --- 修改处：确保日志输出包含具体错误对象 ---
    final detail = e.message ?? e.error?.toString() ?? "N/A";
    Log.e(
      "[Network Error] URL: $url, Code: $code, Type: ${e.type}, Msg: $detail",
    );
    // --------------------------------------
  }
}
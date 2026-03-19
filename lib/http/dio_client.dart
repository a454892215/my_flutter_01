
import 'dart:typed_data';
import 'package:cbor/cbor.dart';
import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import '../util/Log.dart';
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
        responseType: ResponseType.bytes, // 统一保持字节流，由外部决定如何解析
        contentType: isCborEnabled ? 'application/cbor' : 'application/json',
        validateStatus: (status) => true, // 允许所有状态码，不抛出异常
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
  /// 返回 NetworkResponse<Uint8List>，包含原始字节流和元数据
  Future<NetworkResponse<Uint8List>> request(
      String path, {
        String method = 'GET',
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Options? options,
      }) async {
    Response<Uint8List>? response;

    try {
      dynamic requestData = data;
      // 处理发送端的 CBOR 编码逻辑（如果传入的是 Map）
      if (isCborEnabled && data is Map<String, dynamic>) {
        requestData = Uint8List.fromList(cbor.encode(CborValue(data)));
      }

      response = await _dio.request<Uint8List>(
        path,
        data: requestData,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(
          method: method,
          headers: headers,
        ),
      );
    } on DioException catch (e) {
      _logError(e);
      response = e.response as Response<Uint8List>?;
    } catch (e) {
      Log.e("底层网络模块未知异常: $e");
    }

    // 封装并返回结果
    return NetworkResponse<Uint8List>(
      data: response?.data,
      statusCode: response?.statusCode,
      statusMessage: response?.statusMessage,
      headers: response?.headers.map ?? {},
    );
  }

  void _logError(DioException e) {
    final url = e.requestOptions.uri.toString();
    Log.e("[Network Error] URL: $url, Type: ${e.type}, Msg: ${e.message}");
  }
}
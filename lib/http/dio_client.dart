import 'dart:convert';
import 'dart:typed_data';
import 'package:cbor/cbor.dart';
import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import '../util/Log.dart';

class DioClient {
  static final Map<String, DioClient> _instanceMap = {};
  late final Dio _dio;
  final String baseUrl;
  final bool isCborEnabled;

  DioClient._internal(this.baseUrl, this.isCborEnabled) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      // 始终以字节流接收，由内部 _decodeResponse 统一处理解码
      responseType: ResponseType.bytes,
    ));

    // 配置支持自签名证书的 HTTP/2 适配器
    _dio.httpClientAdapter = Http2Adapter(
      ConnectionManager(
        idleTimeout: const Duration(seconds: 15),
        onClientCreate: (_, config) => config.onBadCertificate = (_) => true,
      ),
    );

    // 仅保留基础日志记录，不干涉业务逻辑
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: false, // 响应体很大时建议关闭，避免日志卡顿
      logPrint: (obj) => Log.d(obj.toString()),
    ));
  }

  factory DioClient({required String baseUrl, bool isCborEnabled = false}) {
    return _instanceMap.putIfAbsent(
      baseUrl,
          () => DioClient._internal(baseUrl, isCborEnabled),
    );
  }

  /// 基础请求方法：外部通过这个方法获取完整的 Response 对象
  Future<Response<T>> request<T>(
      String path, {
        String method = 'GET',
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers, // 允许外部注入不同的 Header
        Options? options,
      }) async {
    try {
      dynamic requestData = data;

      // 发送端：CBOR 编码逻辑（如果开启）
      if (isCborEnabled && data is Map<String, dynamic>) {
        final cborValue = CborValue(data);
        requestData = base64Encode(cbor.encode(cborValue));
      }

      final response = await _dio.request<Uint8List>(
        path,
        data: requestData,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(
          method: method,
          headers: headers, // 合并传入的 headers
        ),
      );

      // 返回解码后的完整 Response，包含 headers
      return _decodeResponse<T>(response);
    } on DioException catch (e) {
      // 原样抛出，由调用者处理 401、403 或网络错误
      rethrow;
    }
  }

  /// 内部解码逻辑：处理字节流到业务对象的转换
  Response<T> _decodeResponse<T>(Response<Uint8List> response) {
    final bytes = response.data;

    if (bytes == null || bytes.isEmpty) {
      return Response<T>(
        data: null,
        headers: response.headers,
        requestOptions: response.requestOptions,
        statusCode: response.statusCode,
      );
    }

    dynamic decoded;
    try {
      if (isCborEnabled) {
        decoded = cbor.decode(bytes).toJson();
      } else {
        // UTF-8 解码 + JSON 解析
        decoded = jsonDecode(utf8.decode(bytes));
      }
    } catch (e) {
      Log.e("解码异常: $e");
      // 容错处理：如果解析失败，尝试返回原始字符串
      decoded = utf8.decode(bytes);
    }

    return Response<T>(
      data: decoded as T?,
      headers: response.headers,
      requestOptions: response.requestOptions,
      statusCode: response.statusCode,
    );
  }
}
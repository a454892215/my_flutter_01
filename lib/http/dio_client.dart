import 'dart:convert';
import 'dart:typed_data';
import 'package:cbor/cbor.dart';
import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import '../util/Log.dart';

/// 定义转换函数类型，方便 Model 转换
typedef NetworkDecoder<T> = T Function(dynamic json);

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
        // 关键：全量接收字节流，手动控制解码逻辑
        responseType: ResponseType.bytes,
        // 如果开启 CBOR，Content-Type 应当声明为 application/cbor
        contentType: isCborEnabled ? 'application/cbor' : 'application/json',

        /// 【核心修改】允许所有状态码通过，不抛出 DioException
        /// 这样即使是 401, 403, 500，也会正常返回 Response 对象
        validateStatus: (status) => true,
      ),
    );

    // HTTP/2 适配器配置
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

  /// 封装后的请求方法
  /// [decoder] 传入如 (json) => User.fromJson(json)
  /// 封装后的请求方法
  Future<T?> request<T>(
      String path, {
        String method = 'GET',
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Options? options,
        NetworkDecoder<T>? decoder,
      }) async {
    Response<Uint8List>? response; // 提升作用域

    try {
      dynamic requestData = data;
      if (isCborEnabled && data is Map<String, dynamic>) {
        final cborValue = CborValue(data);
        requestData = Uint8List.fromList(cbor.encode(cborValue));
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
      // 如果有响应（比如 401/500），将其赋值给 response 继续走后面的解码逻辑
      if (e.response != null && e.response!.data is Uint8List) {
        response = e.response as Response<Uint8List>;
      } else {
        // 如果完全没有响应（如断网、超时），则只能返回 null
        return null;
      }
    } catch (e) {
      // 处理非 Dio 的异常（如代码逻辑错误）
      Log.e("未知请求异常: $e");
      return null;
    }

    // 统一在这里解码，保证所有路径都有 return
    return _decodeResponse<T>(response, decoder);
  }

  /// 内部解码逻辑
  T? _decodeResponse<T>(
    Response<Uint8List> response,
    NetworkDecoder<T>? decoder,
  ) {
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) return null;

    dynamic decodedJson;
    try {
      if (isCborEnabled) {
        // CBOR 直接转为 Map/List
        decodedJson = cbor.decode(bytes).toJson();
      } else {
        // UTF-8 解码，allowMalformed 防止异常字符导致崩溃
        final decodedStr = utf8.decode(bytes, allowMalformed: true);
        decodedJson = jsonDecode(decodedStr);
      }
    } catch (e) {
      Log.e("数据解析异常: $e");
      return null;
    }

    // 如果提供了 decoder，则执行 Model 转换，否则返回原始 Map/List
    if (decoder != null && decodedJson != null) {
      return decoder(decodedJson);
    }
    /// 如果没传 decoder，这里的 as T? 只能应付 Map<String, dynamic>、List 或 String
    return decodedJson as T?;
  }

  /// 封装错误日志打印
  void _logError(DioException e) {
    // 1. 获取完整请求路径 (BaseUrl + Path + QueryParameters)
    final url = e.requestOptions.uri.toString();
    // 2. 获取错误描述 (优先取 Dio 包装后的 Message，其次是自定义类型)
    final reason = e.message ?? e.type.toString();
    // 3. 尝试读取服务器返回的错误 Body (由于 ResponseType 是 bytes，需转换)
    String? responseBody;
    if (e.response?.data is Uint8List) {
      try {
        responseBody = utf8.decode(
          e.response!.data as Uint8List,
          allowMalformed: true,
        );
      } catch (_) {}
    }
    // 4. 聚合打印
    Log.e("""
    [Network Error] ---------------->>>>
    URL: $url
    Method: ${e.requestOptions.method}
    Reason: $reason
    Status: ${e.response?.statusCode ?? 'N/A'}
    Response: ${responseBody ?? 'Empty'}
    <<<<--------------------------------
    """);
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:cbor/cbor.dart';
import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart'; // 需添加此库
import '../util/Log.dart';
import '../util/sp/sp_util.dart';
import '../util/sp/sp_util_key.dart';

class DioUtil {
  // 1. 静态实例池：根据 baseUrl 缓存不同的 DioUtil
  static final Map<String, DioUtil> _instanceMap = {};

  late final Dio _dio;
  final String baseUrl;
  final bool isCborEnabled;

  // 2. 私有构造函数
  DioUtil._internal(this.baseUrl, this.isCborEnabled) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      // 注意：HTTP/2 模式下 responseType 建议保持默认，底层由 Adapter 处理
      responseType: ResponseType.bytes,
    ));

    // 3. 启用 HTTP/2 适配器以支持多路复用
    _dio.httpClientAdapter = Http2Adapter(
      ConnectionManager(
        idleTimeout: const Duration(seconds: 15),
        // 如果有自签名证书需求在这里配置
        onClientCreate: (_, config) => config.onBadCertificate = (_) => true,
      ),
    );

    // 4. 拦截器配置
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        String token = spUtil.getString(keyLoginToken) ?? "";
        options.headers.addAll({'d': 35, 't': token});
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final ids = response.headers['id'];
        if (ids != null && ids.isNotEmpty) {
          spUtil.setString(keyLoginToken, ids.first);
        }
        return handler.next(response);
      },
      onError: (e, handler) {
        Log.e("Dio Error: ${e.type} | Path: ${e.requestOptions.path} | Msg: ${e.message}");
        return handler.next(e);
      },
    ));
  }

  // 5. 工厂构造函数：确保相同 baseUrl 全局共享一个连接池
  factory DioUtil({required String baseUrl, bool isCborEnabled = false}) {
    return _instanceMap.putIfAbsent(
      baseUrl,
          () => DioUtil._internal(baseUrl, isCborEnabled),
    );
  }

  /// GET 请求
  Future<T> get<T>(String path, {Map<String, dynamic>? params}) async {
    final response = await _dio.get(
      path,
      queryParameters: params,
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );
    return _handleResponse<T>(response);
  }

  /// POST 请求
  Future<T> post<T>(String path, Map<String, dynamic> data) async {
    final payload = _encodePayload(data);
    final response = await _dio.post(
      path,
      data: payload,
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );
    return _handleResponse<T>(response);
  }

  /// CBOR 编码逻辑
  dynamic _encodePayload(Map<String, dynamic> data) {
    if (!isCborEnabled) return data;
    final cborValue = CborValue(data);
    return base64Encode(cbor.encode(cborValue));
  }

  /// 统一响应处理与泛型转换
  T _handleResponse<T>(Response response) {
    final Uint8List bytes = response.data;
    dynamic decodedData;

    if (isCborEnabled) {
      final cborDecoded = cbor.decode(bytes);
      // 直接转为 Map/List，避免转 String 再转 Map
      decodedData = cborDecoded.toJson();
    } else {
      final utf8String = utf8.decode(bytes);
      decodedData = jsonDecode(utf8String);
    }

    Log.d("Path: ${response.requestOptions.path} | Response: $decodedData");

    // 业务状态判断（根据你的业务协议调整）
    if (decodedData is Map && decodedData['status'] == false) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: decodedData['message'] ?? "Business logic error",
      );
    }

    return decodedData as T;
  }
}
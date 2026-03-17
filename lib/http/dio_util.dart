import 'dart:convert';
import 'dart:typed_data';
import 'package:cbor/cbor.dart';
import 'package:dio/dio.dart';
import '../util/Log.dart';
import '../util/loading_util.dart';
import '../util/sp_util.dart';
import '../util/sp_util_key.dart';

class DioUtil {
  late final Dio _dio;
  final String baseUrl;
  bool isCborEnabled = false; // CBOR 开关

  DioUtil(this.baseUrl) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.bytes, // 统一先按字节流接收，方便按需解析
    ));

    // 添加拦截器：处理 Header、Token 和 日志
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        String token = spUtil.getString(keyLoginToken) ?? "";
        options.headers.addAll({'d': 35, 't': token});
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 自动提取并保存 Header 中的 ID (Token)
        final ids = response.headers['id'];
        if (ids != null && ids.isNotEmpty) {
          spUtil.setString(keyLoginToken, ids.first);
        }
        return handler.next(response);
      },
    ));
  }

  /// 核心逻辑：处理发送数据
  dynamic _encodePayload(Map<String, dynamic> data) {
    if (!isCborEnabled) return data;
    // 将 Map 转为 CBOR 字节，再转为 Base64 字符串（对应你原有的 Post 逻辑）
    final cborValue = CborValue(data);
    final bytes = cbor.encode(cborValue);
    return base64Encode(bytes);
  }

  /// 核心逻辑：处理响应数据并转换成 String
  String _decodePayload(dynamic responseData) {
    if (responseData == null) return "";

    Uint8List bytes;
    if (responseData is Uint8List) {
      bytes = responseData;
    } else {
      return responseData.toString();
    }

    if (isCborEnabled) {
      final decoded = cbor.decode(bytes);
      // 根据你原有逻辑，CBOR 解析后转为 JSON 字符串返回
      return jsonEncode(decoded.toJson());
    } else {
      // 非 CBOR 模式下，直接将字节流转为 UTF8 字符串
      return utf8.decode(bytes);
    }
  }

  Future<String> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: params,
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<String> post(String path, Map<String, dynamic> data) async {
    try {
      final payload = _encodePayload(data);
      final response = await _dio.post(
        path,
        data: payload,
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  String _handleResponse(Response response) {
    final resultString = _decodePayload(response.data);
    Log.d("Path: ${response.requestOptions.path} | Response: $resultString");

    // 如果需要根据业务 status 抛异常，可以在这里解析 resultString
    final Map<String, dynamic> jsonMap = jsonDecode(resultString);
    if (jsonMap['status'] == false) {
      throw Exception(resultString);
    }

    return resultString;
  }

  void _handleError(DioException e) {
    Log.e("Dio Error: ${e.type} | Message: ${e.message}");
    AppLoading.close();
  }
}
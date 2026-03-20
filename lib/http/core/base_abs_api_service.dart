import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_comm/http/core/response.dart';

import '../../util/Log.dart';
import 'dio_client.dart';

/// 把数据转成需要的Modal
abstract class BaseAbsApiService {
  final DioClient client;
  final String baseUrl;
  final bool isCborEnabled;

  BaseAbsApiService(this.baseUrl, {this.isCborEnabled = false})
    : client = DioClient(baseUrl: baseUrl, isCborEnabled: isCborEnabled);

  Future<NetworkResponse<T>> request<T>(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? decoder,
  }) async {
    // 1. 获取底层响应
    NetworkResponse<Uint8List> response = await client.request(
      path,
      method: method,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      options: options,
    );

    T? finalData;
    // 2. 仅在请求成功且有数据时执行解析逻辑
    if (response.data != null) {
      try {
        dynamic decodedJson = response.getData(isCborEnabled: isCborEnabled);
        // 执行 Model 转换
        if (decoder != null && decodedJson != null) {
          finalData = decoder(decodedJson);
        } else if (decodedJson is T) {
          // 只有类型匹配时才赋值
          finalData = decodedJson;
        } else {
          // 如果类型不匹配且没有 decoder，记录日志或处理
          Log.e("数据类型不匹配: 预期 $T, 实际 ${decodedJson.runtimeType}");
          finalData = null;
        }
      } catch (e, s) {
        Log.e("业务解析异常: ${baseUrl + path}, error: $e $decoder");
        Log.e("StackTrace: \n$s");
      }
    }
    // 3. 统一出口：将底层状态透传，并带上处理后的 data 和 message
    return NetworkResponse<T>(
      data: finalData,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      headers: response.headers,
      isCancelled: response.isCancelled,
    );
  }
}

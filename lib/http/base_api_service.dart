import 'dart:convert';
import 'dart:typed_data';
import 'package:cbor/cbor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_comm/http/response.dart';

import '../util/Log.dart';
import 'dio_client.dart';

 class BaseApiService {
  final DioClient client;

  BaseApiService(this.client);

  /// 业务层通用的解析方法
  Future<T?> request<T>(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    T Function(dynamic json)? decoder,
  }) async {
    // 1. 调用底层的纯净请求
    NetworkResponse<Uint8List> response = await client.request(
      path,
      method: method,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      options: options,
    );

    // 2. 检查基础状态
    if (response.data == null || response.data!.isEmpty) {
      return null;
    }
    // 3. 执行反序列化 (JSON 或 CBOR)
    dynamic decodedJson;
    try {
      if (client.isCborEnabled) {
        decodedJson = cbor.decode(response.data!).toJson();
      } else {
        decodedJson = jsonDecode(
          utf8.decode(response.data!, allowMalformed: true),
        );
      }
    } catch (e) {
      Log.e("业务解析异常: $path, error: $e");
      return null;
    }

    // 4. 转换为 Model
    if (decoder != null && decodedJson != null) {
      return decoder(decodedJson);
    }
    return decodedJson as T?;
  }
}

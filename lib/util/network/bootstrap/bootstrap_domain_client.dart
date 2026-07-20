import 'dart:async';
import 'dart:convert';

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_comm/http/core/log_interceptor.dart';
import 'package:flutter_comm/util/Log.dart';
import 'package:flutter_comm/util/build_info_manager.dart';


/// 启动期域名拉取专用 Client（独立 Dio）：
/// - 用于执行 App 的第一个请求：拉取后续接口使用的域名候选列表
/// - 独立 Dio，不依赖项目现有 `dioProvider`
typedef OnRequestFinish = void Function(List<String>);
class BootstrapDomainClient {
  static const List<String> _domainRequestUrls = [
    "https://baidu8782ddk.de/target.json",
    "https://taobao8782ddk.de/target.json",
  ];
  static final client = BootstrapDomainClient._();
  /// 对外仅暴露这个方法：请求 `target.json` 并返回域名列表。
  static Future<List<String>> requestTargetDomains() async {

    try {
      for (int i = 0; i < _domainRequestUrls.length; i++) {
        final url = _domainRequestUrls[i];
        try {
          final data = await client._request(url);
          Log.d("域名列表接口，请求成功: $url, index=$i");
          return data;
        } catch (e, st) {
          final hasNext = i < _domainRequestUrls.length - 1;
          Log.e("域名列表接口，请求失败: $url, index=$i, hasNext=$hasNext, e:$e, st:$st");
        }
      }
    }catch(e, s){
      Log.e("域名轮训处理异常：$e, $s");
    } finally {
      client._close();
    }
    return [];
  }

  BootstrapDomainClient._({Dio? dio}) : _dio = dio ?? _createDefaultDio();

  final Dio _dio;

  static Dio _createDefaultDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status < 600,
      followRedirects: true,
      maxRedirects: 3,
    ));
    dio.interceptors.add(SingleLogInterceptor("域名列表"));
    if(BuildInfo.isUseChuker()){
      dio.interceptors.add(ChuckerDioInterceptor());
    }
    return dio;
  }

  Future<List<String>> _request(String url) async {
    final resp = await _dio.get<dynamic>(url);
    final status = resp.statusCode ?? -1;
    if (status < 200 || status >= 300) {
      throw DioException(
        requestOptions: resp.requestOptions,
        response: resp,
        type: DioExceptionType.badResponse,
        error: 'HTTP $status',
      );
    }

    final raw = resp.data;
    final dynamic decoded = _decodeRawJson(raw);
    final list = _extractList(decoded);

    final cleaned = <String>[];
    final seen = <String>{};
    for (final v in list) {
      final rawStr = (v ?? '').trim();
      if (rawStr.isEmpty) continue;
      final s = _normalizeUrl(rawStr);
      if (s.isEmpty) continue;
      if (seen.add(s)) cleaned.add(s);
    }
   // Log.d('$url 请求成功 data:$raw ：count=${cleaned.length} raw=$cleaned');
    return cleaned;
  }

  String _normalizeUrl(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '';
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    return 'https://$s';
  }

  dynamic _decodeRawJson(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final text = raw.trim();
      if (text.isEmpty) return null;
      try {
        return jsonDecode(text);
      } catch (e, s) {
        Log.e("========E:$e==========S:$s=========");
        return raw;
      }
    }
    return raw;
  }

  /// 兼容返回格式：
  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map) {
      final d = decoded['data'];
      if (d is List) return d;
    }
    return const <dynamic>[];
  }

  void _close() {
    _dio.close();
  }
}


import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_comm/util/Log.dart';
import 'package:flutter_comm/util/build_info_manager.dart';

class SingleLogInterceptor extends Interceptor {
  final String tag;
  SingleLogInterceptor(this.tag);

  bool get _shouldLogHttp => BuildInfo.isTestBuildMode();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_shouldLogHttp) {
      handler.next(options);
      return;
    }
    // 记录请求开始时间
    options.extra['request_start_time'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_shouldLogHttp) {
      _printLog(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_shouldLogHttp) {
      handler.next(err);
      return;
    }
    if (err.response != null) {
      _printLog(err.response!);
    } else {
      _printErrorLog(err);
    }
    handler.next(err);
  }

  static const bool isPrintResponseHeader = false;
  void _printLog(Response response) {
    final options = response.requestOptions;
    final startTime = options.extra['request_start_time'] ?? 0;
    final duration = DateTime.now().millisecondsSinceEpoch - startTime;

    final buffer = StringBuffer();
    buffer.writeln("http request log");
    buffer.writeln('┌----------------------------$tag-----------------------------------');
    buffer.writeln('| [HTTP] ${options.method} | Status: ${response.statusCode} | Time: ${duration}ms');
    buffer.writeln('| URL: ${options.uri} ==>End');

    // 1. 请求头
    buffer.writeln('| [Request Headers]');
    options.headers.forEach((key, value) => buffer.writeln('|   $key: $value'));

    // 2. 请求体
    if (options.data != null) {
      buffer.writeln('| Request Body: ${_parseData(options.data)}');
    }

    buffer.writeln('|---------------------------------------------------------------');

    // 3. 响应头
    if(isPrintResponseHeader){
      buffer.writeln('| [Response Headers]');
      response.headers.forEach((key, values) => buffer.writeln('|   $key: ${values.join(', ')}'));
    }

    // 4. 响应体
    buffer.writeln('| Response: ${_parseData(response.data)}');
    buffer.writeln('└---------------------------------------------------------------');

    _splitLogPrint(buffer.toString(), isErr: response.statusCode != 200);
  }

  void _printErrorLog(DioException err) {
    final buffer = StringBuffer();
    if(err.type == DioExceptionType.cancel){
      return;
    }
    buffer.writeln('┌---------- ERROR ----------------------------------------------');
    buffer.writeln('| URL: ${err.requestOptions.uri} ==>End');
    buffer.writeln('| Method: ${err.requestOptions.method}');

    // --- 修改处：增加对 err.error 的提取，解决 message 为 null 的问题 ---
    final errorMessage = err.message ?? err.error?.toString() ?? "Unknown Error";
    buffer.writeln('| Message: $errorMessage');
    // -----------------------------------------------------------

    if (err.response?.data != null) {
      buffer.writeln('| Error Data: ${_parseData(err.response?.data)}');
    }
    buffer.writeln('| Type: ${err.type}');
    buffer.writeln('└---------------------------------------------------------------');
    Log.e(buffer.toString());
  }

  /// 核心处理：Uint8List 转换与 JSON 格式化
  String _parseData(dynamic data) {
    if (data == null) return "null";

    try {
      if (data is Uint8List) {
        return utf8.decode(data);
      } else if (data is List<int>) {
        return utf8.decode(data);
      } else if (data is String) {
        // 不再尝试解析/格式化字符串形式的 JSON，保持紧凑原样输出
        return data;
      } else if (data is Map || data is List) {
        // Map/List 直接紧凑 JSON 输出（不缩进、不额外换行）
        return json.encode(data);
      } else {
        return data.toString();
      }
    } catch (e) {
      // 无法解析为 JSON 或 utf8，直接返回原始内容或转义
      return data.toString();
    }
  }

  /// 适配 Android Logcat 4KB 限制，循环打印
  void _splitLogPrint(String rawMsg, {isErr=false}) {
    const int chunkSize = 4000;
    // 如果日志较短直接打印
    if (rawMsg.length <= chunkSize) {
      if(isErr){
        Log.e(rawMsg);
      }else{
        Log.d(rawMsg);
      }
      return;
    }

    // 如果超长，按长度分段打印，防止底层被截断
    for (int start = 0; start < rawMsg.length; start += chunkSize) {
      final int end = (start + chunkSize > rawMsg.length)
          ? rawMsg.length
          : start + chunkSize;
      if(isErr){
        Log.e(rawMsg.substring(start, end));
      }else{
        Log.d(rawMsg.substring(start, end));
      }

    }
  }
}
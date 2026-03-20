import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
// 请确保此路径指向你自己的 Log 工具类
import '../../util/Log.dart';

class SingleLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 记录请求开始时间
    options.extra['request_start_time'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _printLog(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      _printLog(err.response!);
    } else {
      _printErrorLog(err);
    }
    handler.next(err);
  }

  void _printLog(Response response) {
    final options = response.requestOptions;
    final startTime = options.extra['request_start_time'] ?? 0;
    final duration = DateTime.now().millisecondsSinceEpoch - startTime;

    final buffer = StringBuffer();
    buffer.writeln('┌---------------------------------------------------------------');
    buffer.writeln('| [HTTP] ${options.method} | Status: ${response.statusCode} | Time: ${duration}ms');
    buffer.writeln('| URL: ${options.uri}');

    // 1. 请求头
    buffer.writeln('| [Request Headers]');
    options.headers.forEach((key, value) => buffer.writeln('|   $key: $value'));

    // 2. 请求体
    if (options.data != null) {
      buffer.writeln('| Request Body: ${_parseData(options.data)}');
    }

    buffer.writeln('|---------------------------------------------------------------');

    // 3. 响应头
    buffer.writeln('| [Response Headers]');
    response.headers.forEach((key, values) => buffer.writeln('|   $key: ${values.join(', ')}'));

    // 4. 响应体
    buffer.writeln('| Response: ${_parseData(response.data)}');
    buffer.writeln('└---------------------------------------------------------------');

    _splitLogPrint(buffer.toString());
  }

  void _printErrorLog(DioException err) {
    final buffer = StringBuffer();
    buffer.writeln('┌---------- ERROR ----------------------------------------------');
    buffer.writeln('| URL: ${err.requestOptions.uri}');
    buffer.writeln('| Method: ${err.requestOptions.method}');
    buffer.writeln('| Message: ${err.message}');
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
      String content;
      if (data is Uint8List) {
        content = utf8.decode(data);
      } else if (data is List<int>) {
        content = utf8.decode(data);
      } else if (data is String) {
        content = data;
      } else if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      } else {
        return data.toString();
      }

      // 尝试格式化字符串形式的 JSON
      final decoded = json.decode(content);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (e) {
      // 无法解析为 JSON 或 utf8，直接返回原始内容或转义
      return data.toString();
    }
  }

  /// 适配 Android Logcat 4KB 限制，循环打印
  void _splitLogPrint(String rawMsg) {
    // 如果日志较短直接打印
    if (rawMsg.length < 4000) {
      Log.d(rawMsg);
      return;
    }

    // 如果超长，按行拆分或分段打印，防止底层被截断
    for (var line in rawMsg.split('\n')) {
      Log.d(line);
    }
  }
}
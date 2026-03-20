import 'dart:convert';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';

class NetworkResponse<T> {
  final T? data; // 原始字节流或转换后的数据
  final int? statusCode; // HTTP 状态码
  final String? statusMessage; // 状态描述
  final Map<String, List<String>> headers; // 响应头
  final bool isSuccess; // 逻辑判断是否成功 (200-299)
  final bool isCancelled; // 请求是否被取消

  NetworkResponse({
    this.data,
    this.statusCode,
    this.statusMessage,
    this.isCancelled = false,
    this.headers = const {},
  }) : isSuccess = statusCode != null && statusCode >= 200 && statusCode < 300;

  /// 将原始字节流转换为 Map、List 或 String (自动识别 JSON)
  dynamic getData({bool isCborEnabled = false}) {
    if (data == null) return null;

    if (data is Uint8List) {
      final bytes = data as Uint8List;
      try {
        if (isCborEnabled) {
          // CBOR 转换后直接返回对象/集合，而不是 .toString()
          return cbor.decode(bytes).toJson();
        } else {
          // 1. 先转码为 UTF8 字符串
          String utf8String = utf8.decode(bytes, allowMalformed: true);
          try {
            // 2. 关键：尝试将其解析为 JSON 对象 (Map 或 List)
            return jsonDecode(utf8String);
          } catch (_) {
            // 如果不是标准的 JSON 格式，则原样返回字符串
            return utf8String;
          }
        }
      } catch (e) {
        // 解析失败，可能是图片或其他二进制数据
        return bytes;
      }
    }
    // 如果 data 已经是 T 类型，直接返回
    return data;
  }

  @override
  String toString() {
    // 1. 处理 Data 的转换与显示

    // 2. 格式化 Headers（全量打印）
    final String headersContent = headers.entries
        .map((e) => "    ${e.key}: ${e.value.join(', ')}")
        .join("\n");

    // 3. 最终组合输出
    return """
    \r\n
NetworkResponse(
  isSuccess: $isSuccess
  statusCode: $statusCode
  statusMessage: $statusMessage
  headers: {
$headersContent
  }
  data: ${getData()}
)""";
  }
}

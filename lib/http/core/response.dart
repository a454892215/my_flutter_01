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

  String getData({bool isCborEnabled = false}) {
    String dataContent = "";
    if (data == null) {
      dataContent = "";
    } else if (data is Uint8List) {
      final bytes = data as Uint8List;
      try {
        if (isCborEnabled) {
          dataContent = cbor.decode(bytes).toJson().toString();
        } else {
          /// allowMalformed  当遇到非法的 UTF-8 字节序列时，程序是“报错崩溃”还是“容错继续”
          dataContent = utf8.decode(bytes, allowMalformed: false);
        }
      } catch (e) {
        // 如果非文本格式（如图片或压缩包），回退到长度显示
        dataContent = "Uint8List(length: ${bytes.length})";
      }
    } else {
      dataContent = data.toString();
    }
    return dataContent;
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

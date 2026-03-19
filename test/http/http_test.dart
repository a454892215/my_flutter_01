import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' show Response, DioException;
import 'package:flutter_comm/http/dio_client.dart';


class HttpTest {
  static Future<void> test1() async {
    try {
      DioClient httpUtil = DioClient(baseUrl: 'https://8.210.49.248:9443/');

      var response = await httpUtil.request(
          "test",
          queryParameters: {'clientId': 'client77'},
          headers: {'d': 35, 't': 'your_actual_token_here'} // 检查这里的 Token
      );

      print("请求成功：${response.data}");
    } on DioException catch (e) {
      if (e.response != null) {
        // 即使是 401，这里也能打印出后端返回的错误 Body
        print("服务器返回状态码: ${e.response?.statusCode}");
        // 如果 data 是字节数组，手动转为字符串
        if (e.response?.data is Uint8List) {
          String decodedError = utf8.decode(e.response?.data);
          print("服务器返回错误信息: $decodedError");
        } else {
          print("服务器返回错误信息: ${e.response?.data}");
        }
      } else {
        print("网络请求配置错误: ${e.message}");
      }
    }
  }
}

Future<void> main() async {
  // 全局忽略证书校验（仅限开发/测试环境！）
  HttpOverrides.global = MyHttpOverrides();
  // 应用程序启动逻辑
  print("我是 main 函数");
  await HttpTest.test1();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

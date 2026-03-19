import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_comm/http/dio_client.dart';
import 'package:flutter_comm/http/response.dart';
import 'package:flutter_comm/util/Log.dart';

class HttpTest {
  static Future<void> test1() async {
    DioClient httpUtil = DioClient(baseUrl: 'https://8.210.49.248:9443/');
    NetworkResponse<Uint8List> response = await httpUtil
        .request(
          "test",
          queryParameters: {'clientId': 'client77'},
          headers: {'d': 35, 't': 'your_actual_token_here'}, // 检查这里的 Token
        );
    Log.d("====请求成功====：$response type:${response.runtimeType}");
  }
}

Future<void> main() async {
  // 全局忽略证书校验（仅限开发/测试环境！）
  HttpOverrides.global = MyHttpOverrides();
  // 应用程序启动逻辑
  print("我是 main 函数");
  await HttpTest.test1();
  await Future.delayed(Duration(seconds: 100));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

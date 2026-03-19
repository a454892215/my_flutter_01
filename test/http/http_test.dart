import 'package:dio/dio.dart' show Response;
import 'package:flutter_comm/http/dio_client.dart';


class HttpTest {
  static Future<void> test1() async {
    DioClient httpUtil = DioClient(
      isCborEnabled: false,
      baseUrl: 'https://8.210.49.248:9443/',
    );
    print("开始 请求：");
    Response<dynamic> response = await httpUtil.request("test", queryParameters: {'clientId': 'client77'});
    print("请求结果：" + response.data);
  }
}

Future<void> main() async {
  // 应用程序启动逻辑
  print("我是 main 函数");
  await HttpTest.test1();
}

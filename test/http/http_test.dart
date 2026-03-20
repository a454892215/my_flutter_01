import 'dart:io';
import 'package:flutter_comm/util/Log.dart';
import 'package:flutter_comm/util/sp/sp_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_api_service.dart';
import 'test_base_entity.dart';

class HttpTest {
  static Future<void> test1() async {
    TestApiService apiService = TestApiService();
    TestBaseEntity? entity = await apiService.test({'clientId': 'client77'});
    Log.d("====请求成功====：$entity type:${entity?.runtimeType}  msg:${entity?.msg}");
  }
}

Future<void> main() async {
  // 1. 关键：初始化测试环境的 Binding
  TestWidgetsFlutterBinding.ensureInitialized();
  // 全局忽略证书校验（仅限开发/测试环境！）
  HttpOverrides.global = MyHttpOverrides();
  SharedPreferences.setMockInitialValues({
    'sp_key_token': 'test_token_666', // 你可以预设一些测试数据
  });
  // 初始化你的工具类
  await spUtil.init();
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

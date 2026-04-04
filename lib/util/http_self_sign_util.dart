import 'dart:io';

class HttpSelfSignUtil {
  static void trustAll(){
    // 全局忽略证书校验（仅限开发/测试环境！）
    HttpOverrides.global = MyHttpOverrides();
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}


import 'package:flutter_comm/http/base_api_service.dart';

/// 统一处理 APP 级别的 Token、公共请求参数， 请求头 和 响应信息
class TestApiService extends BaseApiService {
  TestApiService._internal() : super("https://8.210.49.248:9443/");

  static final TestApiService _instance = TestApiService._internal();

  factory TestApiService() => _instance;

  dynamic test(dynamic data) {
    return get('test', queryParameters: {});
  }

}

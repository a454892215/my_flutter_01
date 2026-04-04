

import 'base_api_service.dart';

/// 统一处理 APP 级别的 Token、公共请求参数， 请求头 和 响应信息
class AppApiService extends BaseApiService {
  AppApiService._internal() : super("https://8.210.49.248:9443/");

  static final AppApiService _instance = AppApiService._internal();

  factory AppApiService() => _instance;


  dynamic login(dynamic data) {
    return post('api/login', data: data);
  }

  dynamic register(dynamic data) {
    return post('api/register', data: data);
  }

  dynamic getActivityList(dynamic data) {
    return post('api/activity/list', data: data);
  }

}

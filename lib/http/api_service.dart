import 'package:flutter_comm/http/core/base_api_service.dart';


class ApiService extends BaseApiService {
  ApiService(): super("", isCborEnabled: false);

  dynamic requestRegister(Map<String, Object> params) {
      return request("/api/register", method: "POST", data: params);
  }
}

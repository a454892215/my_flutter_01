import 'api.dart';
import 'dio_client.dart';


ApiRequest apiRequest = ApiRequest();

class ApiRequest {
  DioClient httpUtil = DioClient(isCborEnabled: false, baseUrl: baseUrl);

  dynamic requestRegister(Map<String, Object> params) {
    return httpUtil.request(register);
  }

}

import 'package:flutter_comm/http/request.dart';

import '../util/Log.dart';
import '../util/sp_util.dart';
import '../util/sp_util_key.dart';

Future<void> requestUserInfo() async {
  String loginToken = spUtil.getString(keyLoginToken) ?? "";
  if (loginToken.isNotEmpty) {
    var userInfo = await apiRequest.requestMemberInfo();
   // UserInfoEntity userInfoEntity = UserInfoEntity.fromJson(userInfo);
  //  GlobeController controller = Get.find<GlobeController>();
  //  controller.userInfoEntity.value = userInfoEntity;
   // Log.d("封装后的数据是： userInfoEntity:${userInfoEntity.username}");
  } else {
    Log.d("用户还没有登陆，不请求用户信息");
  }
}



Future<dynamic> requestCommPhoneVerifyCode(String tel, {isForgetPsw = false}) async {
  // ty: 1注册2忘记密码
  return await apiRequest.requestSms({'tel': tel, 'ty': isForgetPsw ? 2 : 1, 'flag': 'text'});
}

Future<dynamic> requestCommSmsSendMail(String mail, {isForgetPsw = false}) async {
  // ty: 1注册 2忘记密码
  return await apiRequest.requestSmsSendMail(params: {
    // 'username': '',
    'ty': isForgetPsw ? "2" : "1",
    'mail': mail,
  });
}




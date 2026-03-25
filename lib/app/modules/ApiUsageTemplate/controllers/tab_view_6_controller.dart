import 'package:flutter/cupertino.dart';

import '../../../../util/input_rules.dart';
import '../../../../widget/input_field.dart';
import '../../../base/base_controller.dart';

class TabView6ControllerController extends BaseController {

  // 1. 初始化用户名和密码的控制器，并传入对应的正则
  final accountCtrl = AppInputController(regExp: InputRules.usernameReg);
  final passwordCtrl = AppInputController(regExp: InputRules.passwordReg);

  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
  }

  @mustCallSuper
  @override
  void onReady() {
    super.onReady();
  }

  @mustCallSuper
  @override
  void onClose() {
    super.onClose();
  }
}

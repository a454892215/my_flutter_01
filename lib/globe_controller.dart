import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_comm/util/Log.dart';

import 'package:get/get.dart';
import 'env.dart';

class GlobeController extends GetxController with WidgetsBindingObserver {
  GlobeController(this.context);

  final BuildContext context;

  @override
  Future<void> onInit() async {
    /// 强制竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    Log.d("当前系统主题模式改变");
  }

  @override
  void onReady() {
    super.onReady();
    printEnv();
  }

  Future<void> printEnv() async {
    var appInfo = await EnvironmentConfig.getAppInfo();
    Log.i(EnvironmentConfig.getEnvInfo() + appInfo);
  }
}

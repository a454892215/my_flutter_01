
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_comm/skin/skin_manager.dart';
import 'package:flutter_comm/util/Log.dart';

import 'package:flutter_comm/util/sp/sp_util.dart';

import 'package:flutter_comm/util/system_util.dart';
import 'package:get/get.dart';
import 'env.dart';



class GlobeController extends GetxController with WidgetsBindingObserver {
  GlobeController(this.context);

  final BuildContext context;


  bool isLogin() {
     return false;
  }

  Future<void> loginOut() async {

     Log.d("已经退出登陆...");
  }





  void switchPayPasswordStatus() {

  }

  @override
  Future<void> onInit() async {
    /// 强制竖屏
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    await spUtil.init();
    await SysUtil.init();

  }

  @override
  void didChangePlatformBrightness() {
    Log.d("当前系统主题模式改变");
    syncSystemThemeMode(context);
  }

  @override
  void onReady() {
    super.onReady();
    syncSystemThemeMode(context);
    printEnv();
  }

  Future<void> printEnv() async {
    var appInfo = await EnvironmentConfig.getAppInfo();
    Log.i(EnvironmentConfig.getEnvInfo() + appInfo);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_comm/util/Log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/base/base_controller.dart';

class GlobeController extends BaseController with WidgetsBindingObserver {
  @override
  void onInit() {
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

  Future<void> printEnv() async {}

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}

final globeControllerProvider = ChangeNotifierProvider<GlobeController>((ref) {
  return GlobeController();
});

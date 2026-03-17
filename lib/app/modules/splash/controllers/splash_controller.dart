import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import '../../../../util/Log.dart';
import '../../../base/base_controller.dart';


class SplashController extends BaseController {

  @override
  void onInit() {
    super.onInit();
    /// 第一帧绘制完成后的回调
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 500), () {
        FlutterNativeSplash.remove();
       // Get.offNamed(Routes.MAIN);
      });
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

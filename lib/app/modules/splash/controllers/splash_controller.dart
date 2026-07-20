import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../base/base_controller.dart';

class SplashController extends BaseController {
  String title = "splash 页面 66";

  @override
  void onInit() {
    super.onInit();

    /// 第一帧绘制完成后的回调
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 500), () {
        FlutterNativeSplash.remove();
      });
    });
  }
}

final splashControllerProvider =
    ChangeNotifierProvider.autoDispose<SplashController>((ref) {
  return SplashController();
});

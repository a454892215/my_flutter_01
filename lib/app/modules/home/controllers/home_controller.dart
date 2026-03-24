
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../../widget/perf_monitor.dart';
import '../../../base/base_controller.dart';

class HomeController extends BaseController {

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    // 关键：在 build 完成后启动监控，确保 Overlay 能够找到所在的上下文
    /// 使用 GetX 提供的全局 overlayContext，它不需要你手动从 Widget 传参
    if(!kReleaseMode){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.overlayContext != null) {
          PerfMonitor.start(Get.overlayContext!);
        }
      });
    }
  }

  @override
  void onClose() {
    super.onClose();
    if(!kReleaseMode){
      PerfMonitor.stop();
    }
  }

}

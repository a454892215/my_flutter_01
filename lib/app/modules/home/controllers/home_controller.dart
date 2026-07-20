import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_navigator.dart';
import '../../../../util/performance_monitor/perf_monitor.dart';
import '../../../base/base_controller.dart';

class HomeController extends BaseController {
  @override
  void onReady() {
    super.onReady();
    // 关键：在 build 完成后启动监控，确保 Overlay 能够找到所在的上下文
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlayContext = appOverlayContext;
      if (overlayContext != null) {
        PerfMonitor.start(overlayContext);
      }
    });
  }

  @override
  void onClose() {
    PerfMonitor.stop();
    super.onClose();
  }
}

final homeControllerProvider =
    ChangeNotifierProvider.autoDispose<HomeController>((ref) {
  return HomeController();
});

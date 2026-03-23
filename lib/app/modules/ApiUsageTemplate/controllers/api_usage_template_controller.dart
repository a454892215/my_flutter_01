
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widget/perf_monitor.dart';
import '../../../base/base_controller.dart';

class ApiUsageTemplateController extends BaseController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final PageController pageController= PageController();
  List<Map<String, dynamic>> tabs = [
    {'label': '1组件大全', 'value': '1'},
    {'label': '2refresh', 'value': '2'},
    {'label': '3AutoScrollListView 示例', 'value': '3'},
    {'label': '4图片列表', 'value': '4'},
    {'label': '5轮播图', 'value': '5'},
  ];
   final selectedPageIndex = 0.obs;

  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
  }

  @mustCallSuper
  @override
  void onReady() {
    super.onReady();
    // 关键：在 build 完成后启动监控，确保 Overlay 能够找到所在的上下文
    /// 使用 GetX 提供的全局 overlayContext，它不需要你手动从 Widget 传参
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.overlayContext != null) {
        PerfMonitor.start(Get.overlayContext!);
      }
    });
  }

  @mustCallSuper
  @override
  void onClose() {
    super.onClose();
    PerfMonitor.stop(); // 必须调用，否则 Overlay 跨页面存在且无法销毁
    tabController.dispose();
    pageController.dispose();
  }
}

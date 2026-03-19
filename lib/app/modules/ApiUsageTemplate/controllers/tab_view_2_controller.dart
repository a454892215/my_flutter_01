import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../../util/Log.dart';
import '../../../base/base_controller.dart';

class TabView2ControllerController extends BaseController {
  final name = "TabView2 页面".obs;

  final RefreshController refreshController = RefreshController();
  // 定义持久化的 ScrollController
  final ScrollController scrollController = ScrollController();
  int initSize = 10;
  int listSize = 10;
  int perSize = 10;
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
    refreshController.dispose();
    scrollController.dispose();
  }
}

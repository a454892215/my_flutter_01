import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../widget/auto_scroll_listview.dart';
import '../../../base/base_controller.dart';

class TabView3ControllerController extends BaseController {

  final rxList = List.generate(30, (index) => "Item $index").obs;
  late final AutoScrollListViewController autoScrollController;

  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    autoScrollController = AutoScrollListViewController();
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

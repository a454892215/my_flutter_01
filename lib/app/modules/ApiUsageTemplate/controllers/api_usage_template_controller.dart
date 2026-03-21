import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../util/Log.dart';
import '../../../base/base_controller.dart';

class ApiUsageTemplateController extends BaseController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final PageController pageController= PageController();
  List<Map<String, dynamic>> tabs = [
    {'label': '组件大全', 'value': '1'},
    {'label': 'refresh', 'value': '2'},
    {'label': 'AutoScrollListView 示例', 'value': '3'},
    {'label': '动画示列1', 'value': '4'},
    {'label': '动画示列2', 'value': '5'},
  ];

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
  }

  @mustCallSuper
  @override
  void onClose() {
    super.onClose();
    tabController.dispose();
    pageController.dispose();
  }
}


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../http/app_api_service.dart';
import '../../../../util/performance_monitor/perf_monitor.dart';
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
    {'label': '6输入组件', 'value': '6'},
    {'label': '7Sticky Header', 'value': '7'},
  ];
   final selectedPageIndex = 0.obs;

  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    // 全局忽略证书校验（仅限开发/测试环境！）
    HttpOverrides.global = MyHttpOverrides();
    AppApiService().getUserInfo({});
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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

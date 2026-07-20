import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../http/app_api_service.dart';
import '../../../../util/network/http_self_sign_util.dart';
import '../../../base/base_controller.dart';

class ApiUsageTemplateController extends BaseController {
  final PageController pageController = PageController();
  final List<Map<String, dynamic>> tabs = [
    {'label': '1组件大全', 'value': '1'},
    {'label': '2refresh', 'value': '2'},
    {'label': '3AutoScrollListView 示例', 'value': '3'},
    {'label': '4图片列表', 'value': '4'},
    {'label': '5轮播图', 'value': '5'},
    {'label': '6输入组件', 'value': '6'},
    {'label': '7Sticky Header', 'value': '7'},
    {'label': '8渐变文字颜色', 'value': '8'},
  ];

  int selectedPageIndex = 0;

  void setSelectedPageIndex(int index) {
    if (selectedPageIndex == index) return;
    selectedPageIndex = index;
    notifyListeners();
  }

  @override
  void onInit() {
    super.onInit();
    HttpSelfSignUtil.trustAll();
    AppApiService().getUserInfo({});
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

final apiUsageTemplateControllerProvider =
    ChangeNotifierProvider.autoDispose<ApiUsageTemplateController>((ref) {
  return ApiUsageTemplateController();
});

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../util/Log.dart';
import '../../../base/base_controller.dart';

class ApiUsageTemplateController extends BaseController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  List<Map<String, dynamic>> tabs = [
    {'label': '标题1', 'value': '1'},
    {'label': '标题2', 'value': '2'},
    {'label': '标题3', 'value': '3'},
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
  }
}

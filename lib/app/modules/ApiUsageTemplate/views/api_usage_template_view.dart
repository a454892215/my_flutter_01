import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../component/app_button.dart';
import '../controllers/api_usage_template_controller.dart';

class ApiUsageTemplateView extends GetView<ApiUsageTemplateController> {
  const ApiUsageTemplateView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ApiUsageTemplateView'),
        centerTitle: true,
      ),
      body: Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xff84abf6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

        ],
      ),
    ),
    );
  }
}

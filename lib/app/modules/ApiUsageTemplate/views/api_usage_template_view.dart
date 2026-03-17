import 'package:flutter/material.dart';

import 'package:get/get.dart';

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
      body: const Center(
        child: Text(
          'ApiUsageTemplateView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

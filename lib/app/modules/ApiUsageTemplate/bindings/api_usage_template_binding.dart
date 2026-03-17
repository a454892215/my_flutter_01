import 'package:get/get.dart';

import '../controllers/api_usage_template_controller.dart';

class ApiUsageTemplateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiUsageTemplateController>(
      () => ApiUsageTemplateController(),
    );
  }
}

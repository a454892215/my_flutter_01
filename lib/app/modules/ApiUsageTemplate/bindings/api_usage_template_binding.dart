import 'package:get/get.dart';

import '../controllers/api_usage_template_controller.dart';

class ApiUsageTemplateBinding extends Bindings {
  @override
  void dependencies() {
    // 懒加载的方式 不能在不使用ApiUsageTemplateController的时候 不会创建实例 也就不能绑定页面的进出栈状态
    // Get.lazyPut<ApiUsageTemplateController>(
    //   () => ApiUsageTemplateController(),
    // );
    Get.put(ApiUsageTemplateController());
  }
}

import 'package:get/get.dart';

import '../controllers/api_usage_template_controller.dart';
import '../controllers/api_usage_template_drawer_controller.dart';

class ApiUsageTemplateBinding extends Bindings {
  @override
  void dependencies() {
    // 懒加载的方式 不能在不使用ApiUsageTemplateController的时候 不会创建实例 也就不能绑定页面的进出栈状态
    // Get.lazyPut<ApiUsageTemplateController>(
    //   () => ApiUsageTemplateController(),
    // );
    Get.put(ApiUsageTemplateController());
    // 关键：在这里注入抽屉的 Controller，它会跟随父页面的生命周期，不会随抽屉关闭 Controller销毁
    Get.lazyPut(() => TemplateDrawerController());
  }
}

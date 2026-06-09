import 'package:get/get.dart';

import '../controllers/log_controller.dart';

class LogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LogController>(
      () => LogController(),
    );
  }
}

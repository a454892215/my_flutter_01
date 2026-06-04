import 'package:get/get.dart';

import '../controllers/english_learn_controller.dart';

class EnglishLearnBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EnglishLearnController>(
      () => EnglishLearnController(),
    );
  }
}

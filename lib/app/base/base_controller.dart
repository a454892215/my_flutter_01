import 'package:get/get.dart';

import '../../util/Log.dart';

class BaseController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Log.d(" ======= $runtimeType onInit ========");
  }

  @override
  void onReady() {
    super.onReady();
    Log.d(" ======= $runtimeType onReady ========");
  }

  @override
  void onClose() {
    super.onClose();
    Log.d(" ======= $runtimeType onClose ======== ");
  }
}

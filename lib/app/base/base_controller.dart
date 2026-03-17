import 'package:get/get.dart';

import '../../util/Log.dart';

class BaseController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Log.d(" ======= BaseController onInit $runtimeType");
  }

  @override
  void onReady() {
    super.onReady();
    Log.d(" ======= BaseController onReady $runtimeType");
  }

  @override
  void onClose() {
    super.onClose();
    Log.d(" ======= BaseController onClose $runtimeType");
  }
}

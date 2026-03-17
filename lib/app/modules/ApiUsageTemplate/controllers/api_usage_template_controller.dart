import 'package:flutter_comm/util/Log.dart';
import 'package:get/get.dart';

class ApiUsageTemplateController extends GetxController {
  //TODO: Implement ApiUsageTemplateController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    Log.d("onInit");
  }

  @override
  void onReady() {
    super.onReady();
    Log.d("onReady");
  }

  @override
  void onClose() {
    super.onClose();
    Log.d("onClose");
  }

  void increment() => count.value++;
}

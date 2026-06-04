import 'package:flutter/material.dart';
import 'package:flutter_comm/util/Log.dart' show Log;
import 'package:flutter_comm/util/performance_monitor/perf_monitor.dart';
import 'package:get/get.dart';

class EnglishLearnController extends GetxController {

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    Log.d("===========EnglishLearnController===11=======onInit===== PerfMonitor.stop();=======");
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}

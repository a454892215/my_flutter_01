import 'package:flutter/material.dart';
import 'package:flutter_comm/util/performance_monitor/perf_monitor.dart';

import 'package:get/get.dart';

import '../controllers/english_learn_controller.dart';

class EnglishLearnView extends GetView<EnglishLearnController> {
  const EnglishLearnView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EnglishLearnView'),
        centerTitle: true,
      ),
      body: const Center(
        child: MyWidget2(),
      ),
    );
  }
}

class MyWidget2 extends StatefulWidget{
  const MyWidget2({super.key});

  @override
  State<StatefulWidget> createState() {
     return _State();
  }

}

class _State extends State<MyWidget2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerfMonitor.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
     return SizedBox.shrink();
  }
}

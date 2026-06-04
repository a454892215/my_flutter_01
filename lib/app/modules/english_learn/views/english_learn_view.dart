import 'package:flutter/material.dart';

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
        child: Text(
          'EnglishLearnView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

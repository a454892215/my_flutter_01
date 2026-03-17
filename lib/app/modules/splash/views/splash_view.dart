import 'package:flutter/material.dart';
import 'package:flutter_comm/app/component/app_button.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "SplashView Page",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            AppButton(
              padding: EdgeInsets.all(10),
              text: "去home页面66",
              onClick: () => {Get.toNamed(Routes.HOME)},
            ),
          ],
        ),
      ),
    );
  }
}

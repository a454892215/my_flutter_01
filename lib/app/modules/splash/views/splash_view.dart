import 'package:flutter/material.dart';
import 'package:flutter_comm/app/component/app_button.dart';

import 'package:get/get.dart';

import '../../../app_style.dart';
import '../../../component/app_header.dart';
import '../../../component/my_app_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Splash 页面'),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xff84abf6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5),
            AppButton(
              padding: EdgeInsets.all(8),
              text: "去home页面66",
              onClick: () => {Get.toNamed(Routes.HOME)},
            ),
            SizedBox(height: 5),
            AppButton(
              padding: EdgeInsets.all(8),
              text: "去API使用示列页面",
              onClick: () => {Get.toNamed(Routes.API_USAGE_TEMPLATE)},
            ),
          ],
        ),
      ),
    );
  }
}

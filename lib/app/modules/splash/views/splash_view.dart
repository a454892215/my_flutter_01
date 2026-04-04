import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../widget/app_button.dart';
import '../../../widget/my_app_bar.dart';
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
              onClick: () => {Get.offNamed(Routes.HOME)},
            ),
          ],
        ),
      ),
    );
  }
}

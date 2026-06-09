import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../widget/app_button.dart';
import '../../../widget/my_app_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'HomeView'),
      body: Container(
        width: double.infinity,
        color: Colors.green,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppButton(padding: EdgeInsets.all(12), text: "去API使用示列页面", onClick: () => {Get.toNamed(Routes.API_USAGE_TEMPLATE)}),
            SizedBox(height: 10,),
            AppButton(padding: EdgeInsets.all(12), text: "去英语学习页面", onClick: () => {Get.toNamed(Routes.ENGLISH_LEARN)}),
            SizedBox(height: 10,),
            AppButton(padding: EdgeInsets.all(12), text: "去Debug Log", onClick: () => {Get.toNamed(Routes.LOG)}),
          ],
        ),
      ),
    );
  }
}

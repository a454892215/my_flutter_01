import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../component/app_button.dart';
import '../../../component/my_app_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'HomeView'),
      body: Center(
        child: AppButton(
          padding: EdgeInsets.all(8),
          text: "去API使用示列页面",
          onClick: () => {Get.toNamed(Routes.API_USAGE_TEMPLATE)},
        ),
      ),
    );
  }
}

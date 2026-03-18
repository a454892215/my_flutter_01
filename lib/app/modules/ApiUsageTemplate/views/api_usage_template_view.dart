import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../component/app_button.dart';
import '../../../component/my_app_bar.dart';
import '../controllers/api_usage_template_controller.dart';
import 'drawer_api.dart';

class ApiUsageTemplateView extends GetView<ApiUsageTemplateController> {
  const ApiUsageTemplateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'ApiUsageTemplateView'),
      // Scaffold嵌套 保证抽屉只在 body部分，不会遮挡appBar
      body: Scaffold(
        drawer: DrawerApiView(),
        body: Container(
          width: double.infinity,
          color: Color(0xff84abf6),
          child: Builder(
            builder: (BuildContext context) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppButton(
                    padding: EdgeInsets.all(10),
                    text: '打开抽屉',
                    onClick: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../controllers/api_usage_template_drawer_controller.dart';

class DrawerApiView extends StatelessWidget {
  const DrawerApiView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: TemplateDrawerController(),
      builder: (controller) {
        return Container(
          width: 450.w,
          height: double.infinity,
          color: Color(0xffeca1e8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [],
          ),
        );
      },
    );
  }
}

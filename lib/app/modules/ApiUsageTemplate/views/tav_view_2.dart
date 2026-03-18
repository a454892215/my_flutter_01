import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../component/text/text_def.dart';
import '../controllers/api_usage_template_drawer_controller.dart';

/// TemplateDrawerController 在父组件中注册，GetView 相比 GetBuilder 不会在页面关闭的时候 主动销毁Controller
class TabView2 extends GetView<TemplateDrawerController> {
  const TabView2({super.key});

  @override
  Widget build(BuildContext context) {
    // 只要第一次打开时请求过，数据就会一直保存在这个内存对象中
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xff599ecf),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(text: "TabView2",)
        ],
      ),
    );
  }
}

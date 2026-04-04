import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../screen_info.dart';
import '../../../../widget/asset_image.dart';
import '../../../../widget/banner.dart';
import '../../../widget/text/text_def.dart';
import '../controllers/api_usage_template_drawer_controller.dart';

/// TemplateDrawerController 在父组件中注册，GetView 相比 GetBuilder 不会在页面关闭的时候 主动销毁Controller
class TabView5 extends GetView<TemplateDrawerController> {
  const TabView5({super.key});

  @override
  Widget build(BuildContext context) {
    // 只要第一次打开时请求过，数据就会一直保存在这个内存对象中
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xff19a1e8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(text: "TabView5"),
          CommonBanner(
            width: 1.sw,
            height: 1.sw * 0.4,
            itemCount: 4,
            itemBuilder: (BuildContext context, int index) {
              return AppAssetImage("assets/images/test/banner${index + 1}.webp", width: 1.sw);
            },
          ),
        ],
      ),
    );
  }
}

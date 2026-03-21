import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../skin/app_skin.dart';
import '../../../../skin/skin_factory.dart';
import '../../../../skin/skin_manager.dart';
import '../../../component/app_button.dart';
import '../../../component/text/text_def.dart';
import '../controllers/api_usage_template_drawer_controller.dart';

/// TemplateDrawerController 在父组件中注册，GetView 相比 GetBuilder 不会在页面关闭的时候 主动销毁Controller
class TabView1 extends GetView<TemplateDrawerController> {
  const TabView1({super.key});

  @override
  Widget build(BuildContext context) {
    // 只要第一次打开时请求过，数据就会一直保存在这个内存对象中
    // 获取当前皮肤的数据对象
    final skin = context.skinData;
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: skin.bgColor1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(text: "TabView1"),
          AppButton(
            padding: EdgeInsets.all(10),
            text: '打开抽屉',
            onClick: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          AppButton(
            padding: EdgeInsets.all(10),
            text: '切换主题-ocean',
            onClick: () {
              SkinManager.instance.updateSkin(SkinType.ocean);
            },
          ),
          AppButton(
            padding: EdgeInsets.all(10),
            text: '切换主题-forest',
            onClick: () {
              SkinManager.instance.updateSkin(SkinType.forest);
            },
          ),
          AppButton(
            padding: EdgeInsets.all(10),
            text: '切换主题-black',
            onClick: () {
              SkinManager.instance.updateSkin(SkinType.black);
            },
          ),
          AppButton(
            padding: EdgeInsets.all(10),
            text: '切换主题-bright',
            onClick: () {
              SkinManager.instance.updateSkin(SkinType.bright);
            },
          ),
        ],
      ),
    );
  }
}

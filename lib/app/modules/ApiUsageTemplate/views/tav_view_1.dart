import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../skin/app_skin.dart';
import '../../../../skin/skin_factory.dart';
import '../../../../skin/skin_manager.dart';
import '../../../../util/dialog_util.dart';
import '../../../../widget/horizontal_indicator_tab.dart';
import '../../../component/app_button.dart';
import '../../../component/text/text_def.dart';

/// TemplateDrawerController 在父组件中注册，GetView 相比 GetBuilder 不会在页面关闭的时候 主动销毁Controller
class TabView1 extends StatefulWidget {
  const TabView1({super.key});

  @override
  State<TabView1> createState() => _TabView1State();
}

class _TabView1State extends State<TabView1> {
  // 1. 初始化控制器
  final HorizontalTabController _controller = HorizontalTabController(initialIndex: 0);

  final List<String> _titles = ["精选", "双11大促", "手机", "电脑办公设备", "美妆", "运动"];

  static String dialogTag = "dialogTag001";
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose(); // 记得释放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 只要第一次打开时请求过，数据就会一直保存在这个内存对象中
    // 获取当前皮肤的数据对象
    final skin = context.skinData;
    final dialogWidget = Container(
      width: 300.w,
      height: 300.w,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 0.w, bottom: 0.w),
      decoration: BoxDecoration(
        color: const Color(0xffffcccc),
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xff000000), width: 1.w),
      ),
      child: Text(
        "弹窗1的内容",
        style: TextStyle(fontSize: 24.w, color: const Color(0xff333333), fontWeight: FontWeight.w400),
      ),
    );
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: skin.bgColor1,
      child: SingleChildScrollView(
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
            AppButton(
              padding: EdgeInsets.all(10),
              text: '弹窗-允许用户关闭',
              onClick: () {
                DialogUtil.show(dialogWidget, clickMaskDismiss: true);
              },
            ),
            AppButton(
              padding: EdgeInsets.all(10),
              text: '弹窗-不允许用户关闭',
              onClick: () {
                DialogUtil.show(dialogWidget, tag: dialogTag, clickMaskDismiss: false);
                // Future.delayed(Duration(seconds: 5), (){
                //   DialogUtil.dismiss(tag: dialogTag);
                // });
              },
            ),
            HorizontalIndicatorTab(
              size: _titles.length,
              height: 50,
              width: 1.sw,
              indicatorAttr: IndicatorAttr(height: 3, color: Colors.yellow),
              onSelectChanged: (int index) {},
              controller: _controller,
              itemBuilder: (BuildContext context, int index, bool isSelected) {
                return Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    _titles[index],
                    style: TextStyle(color: isSelected ? Colors.deepPurple : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

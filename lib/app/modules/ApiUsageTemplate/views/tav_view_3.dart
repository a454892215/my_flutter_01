import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../skin/app_skin.dart';
import '../../../../widget/auto_scroll_listview.dart';
import '../../../widget/text/text_def.dart';
import '../controllers/api_usage_template_controller.dart';
import '../controllers/tab_view_3_controller.dart';

/// TemplateDrawerController 在父组件中注册，GetView 相比 GetBuilder 不会在页面关闭的时候 主动销毁Controller
class TabView3 extends GetView<ApiUsageTemplateController> {
  const TabView3({super.key});

  @override
  Widget build(BuildContext context) {
    // 只要第一次打开时请求过，数据就会一直保存在这个内存对象中
    final skin = context.skinData;
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xff79a1e8),
      padding: EdgeInsets.all(25),
      child: GetBuilder<TabView3ControllerController>(
        /// 它会在 GetX 组件插入树时自动创建 Controller，并在组件从树中移除时自动销毁Controller。
        init: TabView3ControllerController(),
        builder: (tabView3ControllerController) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppText(text: controller.tabs[controller.selectedPageIndex.value]['label']),
            Expanded(
              child: RepaintBoundary(
                child: AutoScrollListView(
                  itemCount: tabView3ControllerController.rxList.length,
                  controller: tabView3ControllerController.autoScrollController,
                  scrollSpeed: 60.0,
                  // 每秒滚动 60 像素
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    // 这里编写你的 Item UI
                    return Container(
                      height: 50,
                      color: Color(0xffe67b7b),
                      alignment: Alignment.center,
                      child: Text(
                        tabView3ControllerController.rxList[index],
                        style: TextStyle(fontSize: 16, color: skin.textColor1),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

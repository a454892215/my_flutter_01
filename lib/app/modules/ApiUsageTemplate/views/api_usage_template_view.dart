import 'package:flutter/material.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_1.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_2.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_3.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_4.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_5.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_6.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_7.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../component/app_tab_bar.dart';
import '../../../component/my_app_bar.dart';
import '../controllers/api_usage_template_controller.dart';
import 'drawer_view.dart';

class ApiUsageTemplateView extends GetView<ApiUsageTemplateController> {
  ApiUsageTemplateView({super.key});

  late final List<Widget> _pages = [
   const TabView1(),
    const TabView2(),
    const TabView3(),
    const TabView4(),
    const TabView5(),
    const TabView6(),
    const TabView7(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'ApiUsageTemplateView'),
      // Scaffold嵌套 保证抽屉只在 body部分，不会遮挡appBar
      body: Scaffold(
        appBar: null,
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
                  AppTabBar(
                    controller: controller.tabController,
                    tabs: controller.tabs,
                    height: 100.w,
                    labelPadding: EdgeInsetsDirectional.symmetric(
                      horizontal: 30.w,
                    ),
                    indicatorWidth: 88.w,
                    isScrollable: true,
                    onTap: (int index, String value) {
                     // controller.pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                      controller.pageController.jumpToPage(index);
                    },
                  ),
                  Expanded(child: PageView.builder(
                    itemCount: controller.tabs.length,
                    physics: const NeverScrollableScrollPhysics(),
                    controller: controller.pageController,
                    itemBuilder: (BuildContext context, int index) {
                      return _pages[index];
                    },
                  )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

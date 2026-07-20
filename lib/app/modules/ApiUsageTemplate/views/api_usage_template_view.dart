import 'package:flutter/material.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_1.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_2.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_3.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_4.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_5.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_6.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_7.dart';
import 'package:flutter_comm/app/modules/ApiUsageTemplate/views/tav_view_8.dart';
import 'package:flutter_comm/widget/keep_alive_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../screen_info.dart';
import '../../../widget/app_tab_bar.dart';
import '../../../widget/my_app_bar.dart';
import '../controllers/api_usage_template_controller.dart';
import 'drawer_view.dart';

class ApiUsageTemplateView extends ConsumerStatefulWidget {
  const ApiUsageTemplateView({super.key});

  @override
  ConsumerState<ApiUsageTemplateView> createState() =>
      _ApiUsageTemplateViewState();
}

class _ApiUsageTemplateViewState extends ConsumerState<ApiUsageTemplateView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late final List<Widget> _pages = [
    const TabView1(),
    const TabView2(),
    const TabView3(),
    const TabView4(),
    const TabView5(),
    const TabView6(),
    const TabView7(),
    const TabView8(),
  ];

  @override
  void initState() {
    super.initState();
    // tabs 数量固定为 8，避免在 initState 中依赖 provider
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(apiUsageTemplateControllerProvider);
    return Scaffold(
      appBar: MyAppBar(title: 'ApiUsageTemplateView'),
      // Scaffold嵌套 保证抽屉只在 body部分，不会遮挡appBar
      body: Scaffold(
        appBar: null,
        drawer: const DrawerApiView(),
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
                    controller: _tabController,
                    tabs: controller.tabs,
                    height: 100.w,
                    labelPadding: EdgeInsetsDirectional.symmetric(
                      horizontal: 30.w,
                    ),
                    indicatorWidth: 88.w,
                    isScrollable: true,
                    onTap: (int index, String value) {
                      controller.pageController.jumpToPage(index);
                      controller.setSelectedPageIndex(index);
                    },
                  ),
                  Expanded(
                    child: PageView.builder(
                      itemCount: controller.tabs.length,
                      physics: const NeverScrollableScrollPhysics(),
                      controller: controller.pageController,
                      itemBuilder: (BuildContext context, int index) {
                        return AliveWidget(child: _pages[index]);
                      },
                    ),
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

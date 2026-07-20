import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../skin/app_skin.dart';
import '../../../../widget/auto_scroll_listview.dart';
import '../../../widget/text/text_def.dart';
import '../controllers/api_usage_template_controller.dart';
import '../controllers/tab_view_3_controller.dart';

class TabView3 extends ConsumerStatefulWidget {
  const TabView3({super.key});

  @override
  ConsumerState<TabView3> createState() => _TabView3State();
}

class _TabView3State extends ConsumerState<TabView3> {
  late final TabView3ControllerController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabView3ControllerController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageController = ref.watch(apiUsageTemplateControllerProvider);
    final skin = context.skinData;
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xff79a1e8),
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            text: pageController.tabs[pageController.selectedPageIndex]['label'],
          ),
          Expanded(
            child: RepaintBoundary(
              child: AutoScrollListView(
                itemCount: _tabController.rxList.length,
                controller: _tabController.autoScrollController,
                scrollSpeed: 60.0,
                // 每秒滚动 60 像素
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return Container(
                    height: 50,
                    color: Color(0xffe67b7b),
                    alignment: Alignment.center,
                    child: Text(
                      _tabController.rxList[index],
                      style: TextStyle(fontSize: 16, color: skin.textColor1),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

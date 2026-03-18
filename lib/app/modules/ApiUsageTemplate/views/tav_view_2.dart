import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../component/refresh_widget.dart';
import '../../../component/text/text_def.dart';
import '../controllers/tab_view_2_controller.dart';

/// refresh sample
class TabView2 extends StatelessWidget {
  const TabView2({super.key});

  @override
  Widget build(BuildContext context) {
    // 只要第一次打开时请求过，数据就会一直保存在这个内存对象中
    return GetBuilder<TabView2ControllerController>(
      init: TabView2ControllerController(),
      builder: (controller) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xff599ecf),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText(text: "TabView2"),
              Expanded(
                child: RefreshWidget(
                  refreshController: controller.refreshController,
                  child: ListView.builder(
                    itemCount: 20,
                    padding: EdgeInsets.only(
                      left: 0.w,
                      right: 0.w,
                      top: 0.w,
                      bottom: 0.w,
                    ),
                    physics: const BouncingScrollPhysics(),
                    controller: ScrollController(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        width: double.infinity,
                        height: 50,
                        color: index % 2 == 0
                            ? Colors.blue
                            : Colors.amberAccent,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_comm/widget/vertical_nested_scroll_widget.dart';


import '../../../../screen_info.dart';
import '../../../component/text/text_def.dart';

/// NestedScrollView
class TabView7 extends StatelessWidget {
  const TabView7({super.key});

  @override
  Widget build(BuildContext context) {
    // 只要第一次打开时请求过，数据就会一直保存在这个内存对象中
    return VerticalNestedScrollWidget(expandedHeight: 60, headerWidget: Container(
        width: 100.w,
        height: 100.w,
        padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 0.w, bottom: 0.w),
        decoration: BoxDecoration(
          color: const Color(0xffcccccc),
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(color: const Color(0xff000000), width: 1.w),
        ),
        child: const SizedBox(),
      ), bodyWidget: [],);
  }
}

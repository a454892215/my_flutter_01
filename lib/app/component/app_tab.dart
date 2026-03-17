import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_tab_indicator.dart';

class AppTab extends StatefulWidget {
  const AppTab({
    super.key,
    required this.tabs,
    this.isScrollable = false,
    this.height,
    this.onTap,
    this.indicatorWidth,
    this.controller,
  });

  final List<Map<String, dynamic>> tabs;

  final TabController? controller;

  // 是否可以滚动
  final bool isScrollable;

  // 高度
  final double? height;

  // 指示器宽度
  final double? indicatorWidth;

  // 点击回调
  final void Function(int index, String value)? onTap;

  @override
  State<AppTab> createState() => _AppTabState();
}

class _AppTabState extends State<AppTab> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: widget.controller,
      indicatorColor: const Color.fromRGBO(14, 209, 244, 1),
      labelColor: Colors.white,
      unselectedLabelColor: const Color.fromRGBO(255, 255, 255, 0.40),
      // 超出滚动
      isScrollable: widget.isScrollable,
      labelStyle: TextStyle(
        fontSize: 26.w,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 26.w,
        fontWeight: FontWeight.w400,
      ),
      onTap: (index) {
        if (widget.onTap != null) {
          widget.onTap!(index, (widget.tabs[index]['value'] ?? '').toString());
        }
      },
      indicator: CustomTabIndicator(
        color: const Color.fromRGBO(14, 209, 244, 1),
        width: widget.indicatorWidth,
        height: 6.w,
        borderRadius: 10.w,
        boxShadow: BoxShadow(
          offset: Offset(0, -2.w),
          blurRadius: 6.w,
          spreadRadius: 0,
          color: const Color(0xFF0ED1F4),
        )
      ),
      tabs: widget.tabs.map((e) => Container(
        height: widget.height ?? 100.w,
        alignment: Alignment.center,
        child: Text(
          "${e['label']}",
        ),
      )).toList(),
    );
  }
}

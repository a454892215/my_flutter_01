import 'package:flutter/material.dart';

import '../app_style.dart';
import 'app_header.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.title,
    this.isNeedLeftBackArrow = true,
    this.toolbarHeight = 50,
  });

  final String title;
  final bool isNeedLeftBackArrow;
  final double toolbarHeight;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      leadingWidth: 0,
      toolbarHeight: toolbarHeight,
      backgroundColor: headerBgColor,
      title: AppHeader(title: title, isNeedLeftBackArrow: isNeedLeftBackArrow),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}

// 定义一个全局屏幕信息类
import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'app_style.dart';

class ScreenInfo {
  static double width = 0;
  static double height = 0;

  /// 核心：UI 真正可用的高度
  static double usableHeight = 0;

  /// usableHeight - appHeaderHeight
  static double contentHeight = 0;

  /// 顶部状态栏高度
  static double statusBarHeight = 0;

  /// 底部虚拟按键/安全区高度
  static double bottomBarHeight = 0;

  ///  当 Android/iOS 软键盘弹出时，MediaQuery.of(context).viewInsets.bottom 会变成键盘高度。
  ///  有的手机 底部的虚拟按键是动态显示隐藏的，因此只在初始化的时候 获取不准确（内容大小还是适配父窗口 最稳妥
  ///  width 始终是屏幕最短的一边
  ///  height 始终是屏幕长短的一边
  static void init(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    width = mediaQuery.size.shortestSide;
    height = mediaQuery.size.longestSide;

    bool isLandscape = mediaQuery.orientation == Orientation.landscape;
    if (isLandscape) {
      /// 横屏
      bottomBarHeight = max(mediaQuery.viewPadding.left, mediaQuery.viewPadding.right);
      statusBarHeight = min(mediaQuery.viewPadding.left, mediaQuery.viewPadding.right);

      // 【核心修正】：既然 usableHeight 是长边的最大可用高度
      // 那么在横屏下，它就是：物理长边 - 左侧遮挡 - 右侧遮挡
      usableHeight = height - statusBarHeight - bottomBarHeight;
      contentHeight = usableHeight - appHeaderHeight;

      // 重要：横屏下 UI 的物理支撑高度其实是 width（物理短边）
      // 为了保证 usableHeight 逻辑一致性，这里需使用 width 进行减法
      usableHeight = width - mediaQuery.viewPadding.top - mediaQuery.viewPadding.bottom;
      contentHeight = usableHeight - appHeaderHeight;
    } else {
      /// 竖屏
      statusBarHeight = mediaQuery.viewPadding.top;
      bottomBarHeight = mediaQuery.viewPadding.bottom;
      usableHeight = height - statusBarHeight - bottomBarHeight;
      contentHeight = usableHeight - appHeaderHeight;
    }
  }
}

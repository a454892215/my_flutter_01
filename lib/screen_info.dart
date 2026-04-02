// 定义一个全局屏幕信息类
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_comm/util/Log.dart';

import 'app_style.dart';

class ScreenInfo {
  ///  width 始终是屏幕最短的一边
  static double width = 0;

  ///  height 始终是屏幕长短的一边
  static double height = 0;

  /// 核心：屏幕最长一边的 最大可以使用大小
  static double usableHeight = 0;

  ///竖屏： contentHeight = usableHeight - appHeaderHeight
  /// 横屏： contentHeight = usableHeight
  static double contentHeight = 0;

  /// 顶部状态栏高度
  static double statusBarHeight = 0;

  /// 底部虚拟按键/安全区高度
  /// 有的手机 底部的虚拟按键是动态显示隐藏的，因此只在初始化的时候 获取不准确，需要注意（内容大小还是适配父窗口 最稳妥）
  /// 当 Android/iOS 软键盘弹出时，MediaQuery.of(context).viewInsets.bottom 会变成键盘高度。
  static double bottomBarHeight = 0;

  static double unit = 0;

  static void init(BuildContext context, {designWidth = 750}) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    // 2. 增加防抖/性能优化：如果数据没变，直接返回
    if (width == mediaQuery.size.shortestSide &&
        height == mediaQuery.size.longestSide &&
        statusBarHeight == mediaQuery.viewPadding.top &&
        mediaQuery.orientation == (width == mediaQuery.size.width ? Orientation.portrait : Orientation.landscape)) {
      return;
    }

    width = mediaQuery.size.shortestSide;
    height = mediaQuery.size.longestSide;

    bool isLandscape = mediaQuery.orientation == Orientation.landscape;
    if (isLandscape) {
      /// 横屏
      // 【核心修正】：既然 usableHeight 是长边的最大可用高度
      // 那么在横屏下，它就是：物理长边 - 左侧遮挡 - 右侧遮挡
      bottomBarHeight = max(mediaQuery.viewPadding.left, mediaQuery.viewPadding.right);
      statusBarHeight = min(mediaQuery.viewPadding.left, mediaQuery.viewPadding.right);

      usableHeight = height - statusBarHeight - bottomBarHeight;
      contentHeight = usableHeight;
    } else {
      /// 竖屏
      statusBarHeight = mediaQuery.viewPadding.top;
      bottomBarHeight = mediaQuery.viewPadding.bottom;
      usableHeight = height - statusBarHeight - bottomBarHeight;
      contentHeight = usableHeight - appHeaderHeight;
    }
    unit = width / designWidth;
    Log.d("ScreenInfo 初始化完毕");
  }
}

extension NumExtensions on num {
  double get w {
    return ScreenInfo.unit * this;
  }

  double get sp {
    return ScreenInfo.unit * this;
  }

  double get sw {
    return ScreenInfo.width * this;
  }
}

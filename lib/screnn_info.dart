// 定义一个全局屏幕信息类
import 'package:flutter/cupertino.dart';

import 'app_style.dart';

class ScreenInfo {
  static double width = 0;
  static double height = 0;

  /// 核心：UI 真正可用的高度
  static double usableHeight = 0;
  // usableHeight - appHeaderHeight
  static double contentHeight = 0;

  /// 顶部状态栏高度
  static double statusBarHeight = 0;

  /// 底部虚拟按键/安全区高度
  static double bottomBarHeight = 0;

  ///   /// 当 Android/iOS 软键盘弹出时，MediaQuery.of(context).viewInsets.bottom 会变成键盘高度。
  static void init(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    width = mediaQuery.size.width;
    height = mediaQuery.size.height;

    statusBarHeight = mediaQuery.padding.top;
    bottomBarHeight = mediaQuery.padding.bottom;

    usableHeight = height - statusBarHeight - bottomBarHeight;
    contentHeight = usableHeight - appHeaderHeight;
  }
}

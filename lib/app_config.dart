import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_navigator_observer.dart';
import 'globe_controller.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
AppNavigatorObserver appNavigatorObserver = AppNavigatorObserver();
/// ============== Theme 配置 ===============
ThemeData appThemeData = ThemeData(
  /// primarySwatch 用于导航栏和floatActionButton的背景色等
  primarySwatch: Colors.purple,

  /// brightness 应用程序亮色或者暗色, 会调整导航栏和页面的背景色(如果不显示设置)
  brightness: Brightness.light,

  /// 配置主背景色
  primaryColor: Colors.pink,

  /// 设置 appBarTheme， 颜色如果没有指定取 primarySwatch
  appBarTheme: appBarTheme,

  /// 设置 app 中所有icon 颜色样式
  iconTheme: const IconThemeData(color: Colors.amber, size: 28, opacity: 0.86),

  /// 设置 app 中所有icon 颜色样式: 如果appBarTheme 没有设置，默认取此， 与 primaryColor形成对比的图标主题
  primaryIconTheme: const IconThemeData(color: Colors.orange, size: 28, opacity: 0.86),

  ///  设置button 点击效果
  // highlightColor: Colors.transparent,

  //  splashColor: Colors.red,

  buttonTheme: buttonTheme,

  /// 设置button 的 theme
  textButtonTheme: textButtonTheme,
);

///  ============== AppBarTheme 配置 ===============
AppBarTheme appBarTheme = const AppBarTheme(
  ///  配置app bar 图标颜色
  color: Color(0xff044B9A),

  /// 设置阴影显示
  elevation: 20,

  /// 设置app bar 中的icon 颜色 大小, 不透明度
  iconTheme: IconThemeData(color: Color.fromARGB(222, 255, 255, 255), size: 28, opacity: 1),

  ///  配置app bar 右侧图标样式
  actionsIconTheme: IconThemeData(color: Colors.white, size: 28, opacity: 1),
);

/// ============== ButtonTheme 配置 ===============
ButtonThemeData buttonTheme = const ButtonThemeData(
  textTheme: ButtonTextTheme.normal,

  /// 点击高亮时候的颜色   --无效？
  highlightColor: Colors.purple,

  /// 不可以点击时候的颜色
  disabledColor: Colors.grey,

  buttonColor: Colors.green,

  /// 无效 ？
  splashColor: Colors.pink,

  /// 鼠标悬停颜色 对MaterialButton背景颜色有效
  // hoverColor: Colors.amberAccent,

  /// 获取焦点颜色 无效 ？
  focusColor: Colors.orange,
);

/// ============== TextButtonTheme 配置 ===============
TextButtonThemeData textButtonTheme = const TextButtonThemeData(
  style: ButtonStyle(
      //  backgroundColor: MaterialStateProperty.all(const Color.fromARGB(99, 152, 203, 82)),
      splashFactory: NoSplash.splashFactory // 为什么无效？
      ),
);

/// 5. MaterialApp种配置默认页面的三种方式，1.home  2.initialRoute(需要和routes配合使用)， 3. routes种的/

class AppInitBinding extends Bindings {
  AppInitBinding(this.context);

  final BuildContext context;

  @override
  void dependencies() {
    Get.put(GlobeController(context));
  }
}


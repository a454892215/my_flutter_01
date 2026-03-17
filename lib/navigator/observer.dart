import 'package:flutter/cupertino.dart';
import 'package:flutter_comm/app/routes/app_pages.dart';


import '../util/Log.dart';

/// 页面进入和退出监听Observer
class MyNavigatorObserver extends NavigatorObserver {
  /// 按下返回键，页面出栈， 调用 didPop
  @override
  void didPop(Route cur, Route? pre) {
    super.didPop(cur, pre);
  //  Log.d("didPop 离开页面 cur: ${cur.settings.name}  pre: ${pre?.settings.name}");

    /// 回到main首页请求XX接口
    // if (pre?.settings.name == Routes.SPLASH && cur.settings.name != null) {
    //
    // }
  }

  /// 打开新页面页面入栈， 调用 didPush
  @override
  void didPush(Route cur, Route? pre) {
    super.didPush(cur, pre);
   // Log.d("didPush 进入页面 cur: ${cur.settings.name}  pre: ${pre?.settings.name}");
  }

}

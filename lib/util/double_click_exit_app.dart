import 'package:flutter/services.dart';
import 'package:flutter_comm/util/toast_util.dart';

class DoubleClickExitApp {
  int lastClickBackTime = 0;

  Future<void> onClick() async {
    int nowTime = DateTime.now().millisecondsSinceEpoch;
    int dTime = nowTime - lastClickBackTime;
    lastClickBackTime = nowTime;
    if (dTime > 1000) {
      Toast.show("Double tap to exit the app");
      return;
    }
    /// 退出app
    await SystemChannels.platform.invokeMethod("SystemNavigator.pop");
  }
}

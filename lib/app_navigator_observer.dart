import 'package:flutter/cupertino.dart';
import 'package:flutter_comm/util/Log.dart';

class AppNavigatorObserver extends NavigatorObserver {
  RoutePopCallBack? popCallBack;
  List<Route<dynamic>> routerList = [];
  List<String?> routerNameList = [];
  String? curRouterName;
  List<RoutePopCallBack> popListenerList = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routerList.add(route);
    routerNameList.add(route.settings.name);
    curRouterName = routerNameList.isEmpty ? "" : routerNameList.last;
    Log.d("========didPush========curRouterName:$curRouterName==routerNameList:$routerNameList==");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    var routeName = route.settings.name;
    if (popCallBack != null) {
      popCallBack!(route, previousRoute);

      /// 重置
      popCallBack = null;
    }
    for (var callback in popListenerList) {
      callback(route, previousRoute);
    }
    routerList.removeLast();
    routerNameList.removeLast();
    curRouterName = routerNameList.isEmpty ? "" : routerNameList.last;
    Log.d("========didPop========curRouterName:$curRouterName==routerNameList:$routerNameList==");
  }

  void setPopListener(RoutePopCallBack callBack) {
    popCallBack = callBack;
  }

  void addPopListener(RoutePopCallBack callBack) {
    popListenerList.add(callBack);
  }

  void removePopListener(RoutePopCallBack callBack) {
    popListenerList.remove(callBack);
  }
}

typedef RoutePopCallBack = void Function(Route<dynamic> route, Route<dynamic>? previousRoute);

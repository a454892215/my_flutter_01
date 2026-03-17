import 'package:flutter/material.dart';
import 'package:flutter_comm/util/Log.dart';

typedef RoutePopCallBack = void Function(Route<dynamic> route, Route<dynamic>? previousRoute);
/// 通过自定义 NavigatorObserver 并维护 List<Route> 的做法，是目前原生 Flutter 开发中 最准确、最可控 的方案
class AppNavigatorObserver extends NavigatorObserver {
  // 使用 List 存储 Route 对象本身更可靠
  final List<Route<dynamic>> _history = [];

  // 暴露只读列表，防止外部意外修改
  List<Route<dynamic>> get history => List.unmodifiable(_history);

  String get curRouterName => _history.isEmpty ? "" : (_history.last.settings.name ?? "anonymous_route");

  final List<RoutePopCallBack> _listeners = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _history.add(route);
    _logStack("didPush");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // 通知所有监听器
    for (var callback in List.from(_listeners)) { // 使用副本遍历，防止在回调中 remove 导致报错
      callback(route, previousRoute);
    }

    _history.remove(route); // 根据引用删除，比 removeLast 安全
    _logStack("didPop");
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _history.remove(route);
    _logStack("didRemove");
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) _history.remove(oldRoute);
    if (newRoute != null) _history.add(newRoute);
    _logStack("didReplace");
  }

  // 管理监听器
  void addPopListener(RoutePopCallBack callback) => _listeners.add(callback);
  void removePopListener(RoutePopCallBack callback) => _listeners.remove(callback);

  void _logStack(String method) {
    final names = _history.map((e) => e.settings.name ?? "{Dialog/Popup}").toList();
    Log.d("========$method======== stack: $names");
  }
}
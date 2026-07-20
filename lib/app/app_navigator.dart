import 'package:flutter/material.dart';

/// 全局 Navigator Key，替代 GetX 的 overlayContext / 路由能力。
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

BuildContext? get appOverlayContext =>
    appNavigatorKey.currentState?.overlay?.context ??
    appNavigatorKey.currentContext;

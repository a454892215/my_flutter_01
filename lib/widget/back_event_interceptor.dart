import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

typedef BackInterceptCallback = bool Function(RouteInfo info);
///  back_button_interceptor 组件 要求 必须给 Android 13以上设置 android:enableOnBackInvokedCallback="false"
class BackInterceptorWidget extends StatefulWidget {
  const BackInterceptorWidget({
    super.key,
    required this.child,
    required this.onInterceptBack,
  });

  final Widget child;
  final BackInterceptCallback onInterceptBack;

  @override
  State<BackInterceptorWidget> createState() => BackInterceptorState();
}

class BackInterceptorState extends State<BackInterceptorWidget> {
  bool _handler(bool stopDefaultButtonEvent, RouteInfo info) {
    return widget.onInterceptBack(info);
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(_handler);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_handler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
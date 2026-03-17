import 'package:flutter/cupertino.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

/// 返回键拦截
class BackInterceptorWidget extends StatefulWidget {
  const BackInterceptorWidget({
    super.key,
    required this.child,
    required this.isInterceptor,
  });

  final Widget child;
  final IsInterceptor isInterceptor;

  @override
  State<StatefulWidget> createState() {
    return MyState();
  }
}

typedef IsInterceptor = bool Function(dynamic obj);

class MyState extends State<BackInterceptorWidget> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(isInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(isInterceptor);
    super.dispose();
  }

  /// true 拦截事件
  bool isInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return widget.isInterceptor(info);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../back_event_interceptor.dart';
import 'overlay_helper.dart';

abstract class BaseDialog {
  /// 弹窗位置，默认居中
  Alignment get alignment => Alignment.center;

  /// 背景遮罩颜色
  static const Color barrierColor = Color(0xaa000000);
  static const Color transparent = Color(0x00000000);
  final bgColor = transparent.obs;

  /// 点击背景是否隐藏
  bool get clickMaskDismiss => true;

  /// 内部显示状态控制
  final RxBool _visible = true.obs;
  final bool isAlive = true;

  /// 获取当前显示状态
  bool get isVisible => _visible.value;

  String get key => runtimeType.toString();

  Widget? widget;

  void show(BuildContext context) {
    widget ??= createWidget();
    OverlayHelper().show(key, widget!, context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateUIState(true);
    });
  }

  void hide() {
    updateUIState(false);
  }

  void close() {
    OverlayHelper().close(key);
  }

  void updateUIState(bool visible) {
    if (visible) {
      bgColor.value = barrierColor;
    } else {
      bgColor.value = transparent;
    }
    Future.delayed(Duration(milliseconds: visible ? 0 : 280), () => _visible.value = visible);
  }

  Widget createWidget() {
    return BackInterceptorWidget(
        onInterceptBack: (RouteInfo info){
          hide();
          return true;
        },
        child: Obx(() {
          return Visibility(
            visible: _visible.value,
            maintainAnimation: true,
            maintainState: true,
            maintainSize: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: (){
                hide();
              },
              child: AnimatedContainer(
                width: double.infinity,
                height: double.infinity,
                color: bgColor.value,
                alignment: alignment,
                duration: Duration(milliseconds: 250),
                onEnd: () {
                  if (_visible.value) {}
                },
                /// 避免 buildWidget点击也被关闭
                child: GestureDetector(
                    onTap: (){
                    },
                    child: buildWidget()),
              ),
            ),
          );
        }),
    );
  }

  /// 抽象函数 强制非抽象子类 必须实现
  Widget buildWidget();
}

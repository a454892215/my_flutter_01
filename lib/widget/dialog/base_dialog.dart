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

  /// 内部显示状态控制
  final RxBool _visible = true.obs;

  final RxBool _isMounted = false.obs;


  /// 已经关闭状态
  static final int closedState = 0;

  /// 正在显示状态
  static final int showingState = 1;

  /// 已经处于显示状态
  static final int showedState = 2;

  /// 正在隐藏状态
  static final int hidingState = 3;

  /// 已经隐藏状态
  static final int dismissedState = 4;

  /// 正在关闭状态
  static final int closingState = 5;

  int _state = closedState;

  int  targetState = closedState;

  String get key => runtimeType.toString();

  Widget? widget;

  void show(BuildContext context) {
    if(_state == showingState || _state == showedState){
      return;
    }
    _isMounted.value = true; // 【修改】立即挂载，Visibility 变为 true
    widget ??= createWidget();
    OverlayHelper().show(key, widget!, context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      targetState = showedState;
    });
  }

  void hide() {
    if (_state == hidingState || _state == dismissedState || _state == closedState) return;
    bgColor.value = transparent; // 【修改】仅改变颜色，触发动画，不直接改 _isMounted
    targetState = dismissedState;
  }

  void close() {
    if (_state == closingState || _state == closedState) return;
    _isMounted.value = false;
    targetState = closedState;
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
      onInterceptBack: (RouteInfo info) {
        hide();
        return true;
      },
      child: Obx(() {
        return Visibility(
          visible: _isMounted.value,
          maintainAnimation: true,
          maintainState: true,
          maintainSize: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              hide();
            },
            child: Obx((){
              return AnimatedContainer(
                width: double.infinity,
                height: double.infinity,
                color: bgColor.value,
                alignment: alignment,
                duration: Duration(milliseconds: 250),
                onEnd: () {
                  _state = targetState;
                  if (targetState == closedState) {
                    OverlayHelper().close(key);
                  }
                },

                /// 避免 buildWidget点击也被关闭
                child: GestureDetector(onTap: () {}, child: buildWidget()),
              );
            }),
          ),
        );
      }),
    );
  }

  /// 抽象函数 强制非抽象子类 必须实现
  Widget buildWidget();
}

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../util/Log.dart';
import '../back_event_interceptor.dart';
import 'overlay_helper.dart';

abstract class BaseDialog {
  /// 弹窗位置，默认居中
  Alignment get alignment => Alignment.center;

  /// 背景遮罩颜色
  static const Color barrierColor = Color(0xaa000000);
  static const Color transparent = Color(0x00000000);

  /// 保证动画触发和transparent的值做区别
  static const Color closedBarrierColor = Color(0x00000001);
  final bgColor = closedBarrierColor.obs;

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
  static final int hiddenState = 4;

  /// 正在关闭状态
  static final int closingState = 5;

  int _state = closedState;

  int targetState = closedState;

  String get key => runtimeType.toString();

  Widget? widget;

  void show(BuildContext context) {
    if (_state == showingState || _state == showedState) {
      return;
    }
    toShowedState(context);
  }

  void toShowedState(BuildContext context) {
    _isMounted.value = true;
    widget ??= createWidget();

    /// 内部已经做了去除 overlayState.insert(entry); 重复 处理
    _state = showingState;
    OverlayHelper().show(key, widget!, context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      targetState = showedState;
      bgColor.value = barrierColor;
    });
  }

  void hide() {
    if (_state == hidingState || _state == hiddenState || _state == closedState) return;
    toHiddenState();
  }

  void toHiddenState() {
    _state = hidingState;
    targetState = hiddenState;
    bgColor.value = transparent;
  }

  void close() {
    if (_state == closingState || _state == closedState) return;
    targetState = closedState;
    toCloseState();
  }

  void toCloseState() {
    _state = closingState;
    targetState = closedState;
    bgColor.value = closedBarrierColor;
  }

  Widget createWidget() {
    return BackInterceptorWidget(
      onInterceptBack: (RouteInfo info) {
        /// 只在showedState 状态才拦截
        if (_state == showedState || _state == showingState) {
          hide();
          return true;
        }
        if (_state == hidingState || _state == closingState) {
          Log.d("======hidingState||closingState====返回事件被拦截===");
          return true;
        }
        if (_state == hiddenState || _state == closedState) return false;

        /// 其他状态 不拦截处理
        return false;
      },
      child: Obx(() {
        return Visibility(
          visible: _isMounted.value,
          maintainAnimation: true,
          maintainState: true,
          maintainSize: true,
          child: Scaffold(
            resizeToAvoidBottomInset: true, /// 使软键盘定出输入框
            backgroundColor: Colors.transparent, // 设置为透明
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                hide();
              },
              child: Obx(() {
                return AnimatedContainer(
                  width: double.infinity,
                  height: double.infinity,
                  color: bgColor.value,
                  alignment: alignment,
                  duration: Duration(milliseconds: 250),
                  onEnd: () {
                    _state = targetState;
                    if (targetState == hiddenState || targetState == closedState) {
                      _isMounted.value = false;
                    }
                    if (targetState == closedState) {
                      OverlayHelper().close(key);
                      widget = null;
                    }
                  },


                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: (targetState == showedState) ? 1.0 : 0.0),
                    duration: Duration(milliseconds: 250),
                    builder: (context, value, child) {
                      // 将 0.0-1.0 的 value 封装成 Animation 对象传给动画函数
                      return _buildContentAnimation(child!, AlwaysStoppedAnimation(value));
                    },
                    /// 避免 buildWidget点击也被关闭
                    child: GestureDetector(onTap: () {}, child: buildWidget()),
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }

  // --- 修改点 1: 抽取动画构建逻辑，直接复用 GetxDialogUtil 的位置判断逻辑 ---
  Widget _buildContentAnimation(Widget child, Animation<double> animation) {
    // 底部弹出
    if (alignment == Alignment.bottomCenter) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(animation),
        child: child,
      );
    }
    // 左侧弹出
    if (alignment == Alignment.centerLeft || alignment == Alignment.bottomLeft || alignment == Alignment.topLeft) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animation),
        child: child,
      );
    }
    // 右侧弹出
    if (alignment == Alignment.centerRight || alignment == Alignment.bottomRight || alignment == Alignment.topRight) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
        child: child,
      );
    }
    // 默认中间缩放
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  /// 抽象函数 强制非抽象子类 必须实现
  Widget buildWidget();
}

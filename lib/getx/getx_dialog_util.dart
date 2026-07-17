import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../util/Log.dart';

class GetxDialogUtil {
  /// 记录当前正在显示的 dialog tag
  static final Map<String, bool> _activeDialogs = {};

  /// 弹出 GetX 弹窗
  static Future<T?> show<T>(
      Widget dialogWidget, {
        bool isBackAllowDismiss = true,
        bool clickMaskDismiss = true,
        bool isForceShow = false,
        Alignment alignment = Alignment.center,
        String? tag,
      }) async {
    // 1. 规避重复弹出逻辑
    if (tag != null && _activeDialogs.containsKey(tag)) {
      debugPrint('GetxDialogUtil: Tag [$tag] is already showing.');
      return null;
    }

    if (tag != null) _activeDialogs[tag] = true;
    // 确定拦截逻辑
    final bool canPop = isForceShow ? false : isBackAllowDismiss;

    // 2. 使用 Get.dialog
    // 注意：通过 navigator 中的 route.animation 来驱动内部组件动画，性能最优
    final T? result = await Get.dialog<T>(
      PopScope(
        canPop: canPop,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop && tag != null) {
            _activeDialogs.remove(tag);
          }
        },
        child: Align(
          alignment: alignment,
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            // 使用 Get.dialog 提供的 Transition 构建器
            // 这种方式直接复用路由动画的 AnimationController，无需额外创建 Builder
            child: Builder(builder: (context) {
              // 获取当前路由的动画对象
              final Animation<double> animation = ModalRoute.of(context)!.animation!;
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.8, curve: Curves.easeInOut), // 透明度先完成
                ),
                child: _buildTransition(animation, alignment, dialogWidget),
              );
            }),
          ),
        ),
      ),
      barrierDismissible: isForceShow ? false : clickMaskDismiss,
      useSafeArea: true,
      barrierColor: const Color(0xaa000000),
      // 适当延长动画时间以体现过渡效果
      transitionDuration: const Duration(milliseconds: 300),
      // 这里的 transitionCurve 是背景遮罩的动画曲线
      transitionCurve: Curves.easeOut,
    );

    /// 3. 执行到这里 弹窗已经触发关闭了，确保任何路径关闭弹窗后都能清理 tag
    if (tag != null) {
      _activeDialogs.remove(tag);
    }

    return result;
  }

  /// 内部私有方法：根据位置选择最合适的动画
  static Widget _buildTransition(Animation<double> animation, Alignment alignment, Widget child) {
    // 如果位置在底部，执行位移动画
    if (alignment == Alignment.bottomCenter) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1), // 从屏幕外底部开始 (y=1)
          end: Offset.zero,          // 移动到原始位置 (y=0)
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut, // 底部弹出通常使用减速曲线，手感更丝滑
        )),
        child: child,
      );
    }

    // 左边侧滑出来的菜单
    if (alignment == Alignment.centerLeft || alignment == Alignment.bottomLeft || alignment == Alignment.topLeft) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut, // 底部弹出通常使用减速曲线，手感更丝滑
        )),
        child: child,
      );
    }

    // 右边侧滑出来的菜单
    if (alignment == Alignment.centerRight || alignment == Alignment.bottomRight || alignment == Alignment.topRight) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut, // 底部弹出通常使用减速曲线，手感更丝滑
        )),
        child: child,
      );
    }

    // 默认（中间弹出）执行缩放动画
    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
      ),
      child: child,
    );
  }

  /// 关闭弹窗
  static void dismiss<T>({T? result, String? tag}) {
    // 优化点：如果是带 tag 的关闭，必须判断当前栈顶是否真的是该 tag 或该 tag 是否还存在
    if (tag != null) {
      if (!_activeDialogs.containsKey(tag)) {
        debugPrint('GetxDialogUtil: Tag [$tag] not found or already dismissed.');
        return;
      }
      // 注意：原生 GetX 并没有提供根据 tag 关闭指定 Dialog 的 API。
      // 如果是非栈顶关闭，通常需要配合 Get.removeRoute 或 Navigator.removeRoute
      // 在应用层，我们通常保证 Dialog 逻辑是顺序的，这里直接执行 back。
      _activeDialogs.remove(tag);
    }

    if (Get.isDialogOpen == true) {
      Get.back<T>(result: result);
    }
  }

  /// 检查特定 tag 的弹窗是否正在显示
  static bool isShowing(String tag) => _activeDialogs.containsKey(tag);

  /// 清除所有 Dialog 记录（通常用于退出登录或重置 App 状态）
  /// 场景：退出登录、重置 App 状态、强制跳转拦截
  static void clearAll() {
    // 1. 物理关闭：循环关闭路由栈中的 Dialog，直到 Get.isDialogOpen 为 false
    // Get.isDialogOpen 内部通过当前路由是否为 GetDialogRoute 来判断
    while (Get.isDialogOpen == true) {
      // 使用 internal 方式或 back 直接关闭
      // 注意：这里不用传 result，因为是强制全局清理
      Get.back();

    }
    // 2. 逻辑清理：确保内存中的 tag 映射表完全清空
    _activeDialogs.clear();
    Log.d('GetxDialogUtil: All dialogs have been physically closed and logic tags cleared.');
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'Log.dart';

class DialogUtil {
  // smart 弹窗
  static Future<T?> show<T>(
    Widget dialogWidget, {
    bool isBackAllowDismiss = true, // 是否允许返回键关闭
    bool isTouchOutAllowDismiss = true, // 是否允许点击遮罩关闭
    bool isForceShow = false, // 是否强制弹窗（优先级最高）
    bool usePenetrate = false, // 修改点：显式控制遮罩穿透，默认不穿透
    String? tag,
  }) async {
    // 修改点：统一关闭逻辑，isForceShow 为 true 时强制禁止所有关闭行为
    final bool canPop = isForceShow ? false : isBackAllowDismiss;
    final bool clickMaskClose = isForceShow ? false : isTouchOutAllowDismiss;

    /// 修改点：如果传入了 tag，先检查是否存在，存在则先 dismiss
    if (tag != null) {
      // checkExist 可以判断当前 Overlay 中是否存在该 tag
      if (SmartDialog.checkExist(tag: tag)) {
        await SmartDialog.dismiss(tag: tag);
      }
    }

    return SmartDialog.show<T>(
      builder: (_) {
        return PopScope(
          canPop: canPop,

          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              Log.d("弹窗返回键被拦截");
            }
          },

          child: Center(
            child: Material(color: Colors.transparent, child: dialogWidget),
          ),
        );
      },
      tag: tag,

      /// 修改点：直接使用统一的 clickMaskClose 变量
      clickMaskDismiss: clickMaskClose,

      /// 修改点：穿透属性应该由业务显式决定，不应与关闭逻辑简单取反
      usePenetrate: usePenetrate,

      /// 遮罩颜色
      maskColor: Colors.black.withOpacity(0.4),

      /// 动画
      animationType: SmartAnimationType.scale,
      animationTime: const Duration(milliseconds: 250),

      /// 自定义动画（更顺滑）
      animationBuilder: (controller, child, animationParam) {
        final curved = CurvedAnimation(parent: controller, curve: Curves.easeOutBack);

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(curved), child: child),
        );
      },
    );
  }

  /// 关闭弹窗
  static void dismiss<T>({T? result, String? tag}) {
    /// 这里的 result 会传给 show 方法返回的 Future
    SmartDialog.dismiss(result: result, tag: tag);
  }
}

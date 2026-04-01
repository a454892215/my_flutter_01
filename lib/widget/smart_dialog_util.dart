import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'back_event_interceptor.dart';
import '../util/Log.dart';

class SmartDialogUtil {
  // smart 弹窗
  static Future<T?> show<T>(
    Widget dialogWidget, {
    bool isBackAllowDismiss = true, // 是否允许返回键关闭
    bool clickMaskDismiss = true, // 是否允许点击遮罩关闭
    bool usePenetrate = false, // 修改点：显式控制遮罩穿透，默认不穿透
    String? tag,
  }) async {
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
          canPop: false,
          onPopInvoked: (didPop) {
            Log.d("=======didPop=====返回键响应了=====");
          },
          child: Center(
            child: Material(color: Colors.transparent, child: dialogWidget),
          ),
        );
      },
      tag: tag,
      backType: SmartBackType.normal,

      /// 修改点：直接使用统一的 clickMaskClose 变量
      clickMaskDismiss: clickMaskDismiss,

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

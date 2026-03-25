import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Log.dart';

class GetxDialogUtil {
  /// 记录当前正在显示的 dialog tag
  static final Map<String, bool> _activeDialogs = {};

  /// 弹出 GetX 弹窗
  static Future<T?> show<T>(
      Widget dialogWidget, {
        bool isBackAllowDismiss = true,
        bool clickMaskDismiss = true,
        bool isForceShow = false,
        String? tag,
      }) async {
    // 1. 规避重复弹出逻辑
    if (tag != null && _activeDialogs.containsKey(tag)) {
      // 如果已存在相同 tag，视业务而定：是直接返回还是关闭旧的弹出新的
      // 这里建议直接返回，防止 UI 闪烁
      debugPrint('GetxDialogUtil: Tag [$tag] is already showing.');
      return null;
    }

    if (tag != null) _activeDialogs[tag] = true;

    // 确定拦截逻辑
    final bool canPop = isForceShow ? false : isBackAllowDismiss;

    // 2. 使用 Get.dialog 的返回结果作为清理时机
    final T? result = await Get.dialog<T>(
      PopScope(
        canPop: canPop,
        onPopInvokedWithResult: (didPop, result) {
          // 仅用于物理返回键触发后的状态清理尝试
          if (didPop && tag != null) _activeDialogs.remove(tag);
        },
        child: Center(
          // 生产环境建议加上 Material 保证文本样式不丢失
          child: Material(
            color: Colors.transparent,
            elevation: 0, // 关键点：强制去掉阴影
            child: dialogWidget,
          ),
        ),
      ),
      barrierDismissible: isForceShow ? false : clickMaskDismiss,
      useSafeArea: true,
      barrierColor: Color(0xaa000000),
      transitionDuration: Duration(milliseconds: 250),
      transitionCurve: Curves.easeInOut,
      // 生产环境务必保证 id 唯一，如果涉及多层 GetRouterOutlet
    );

    // 3. 确保任何路径关闭弹窗后都能清理 tag
    if (tag != null) {
      _activeDialogs.remove(tag);
    }

    return result;
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
import 'package:flutter/material.dart';

import 'package:get/get.dart';


class AppDialog {
  /// 打开更新app弹框
  static void showUpdateAppDialog(Widget dialogWidget) {
    bool isForce = false;
    Get.dialog(
      PopScope(
        // canPop 为 true 时，允许返回手势/物理键关闭弹窗
        // canPop 为 false 时，拦截返回行为
        canPop: !isForce,

        // 如果需要处理拦截后的逻辑（例如展示 Toast 提示“请完成操作”），在此处编写
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            // 已经成功 pop，无需操作
            return;
          }
          // 如果 isForce 为 true 且用户尝试返回，代码会走到这里
          print("强制弹窗，拦截返回手势");
        },
        child: dialogWidget,
      ),
      // 控制点击遮罩层（Barrier）是否关闭
      barrierDismissible: !isForce,
    );
  }

  /// 打开去设置支付密码弹框
  static void showSetPayPwdDialog() {
  }
}

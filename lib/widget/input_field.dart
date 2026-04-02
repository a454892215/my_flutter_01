import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../screen_info.dart';

/// 抽离样式配置
class AppInputStyle {
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;

  const AppInputStyle({
    this.width,
    this.height,
    this.decoration,
    this.style,
    this.hintStyle,
    this.contentPadding,
  });
}

class AppTextField extends StatelessWidget {
  final AppInputController controller;
  final String? hintText;
  final Widget? prefix;
  final Widget? suffix;
  final bool isPassword;
  final bool enabled;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? formatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete; // 新增：处理提交逻辑
  final AppInputStyle? customStyle;

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.prefix,
    this.suffix,
    this.isPassword = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.formatters,
    this.onChanged,
    this.onEditingComplete,
    this.customStyle,
  });

  @override
  Widget build(BuildContext context) {
    // 预计算静态样式，避免在 Obx 内部重复计算
    final double targetHeight = customStyle?.height ?? 1.sw * 0.15;
    final double targetWidth = customStyle?.width ?? double.infinity;
    final BoxDecoration baseDecoration = customStyle?.decoration ??
        BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(44.w),
        );

    // 修改点：缩小 Obx 范围，仅包裹需要动态变化的 Decoration 和 TextField
    return Obx(() {
      final bool isErr = controller.isError.value;

      // 动态计算颜色逻辑移至此处
      final Color bgColor = baseDecoration.color ?? const Color(0xFFF5F5F5);
      final Color displayBgColor = enabled ? bgColor : bgColor.withValues(alpha: 0.6);
      final Color displayTextColor = (customStyle?.style?.color ?? Colors.black)
          .withValues(alpha: enabled ? 1.0 : 0.5);

      return Container(
        width: targetWidth,
        height: targetHeight,
        decoration: baseDecoration.copyWith(
          color: displayBgColor,
          // 修改点：优化 border 逻辑，避免 isErr 为 false 时覆盖 customStyle 的 border
          border: isErr
              ? Border.all(color: Colors.red, width: 1.w)
              : baseDecoration.border,
        ),
        alignment: Alignment.center,
        child: CupertinoTextField(
          controller: controller.textController,
          focusNode: controller.focusNode,
          enabled: enabled,
          obscureText: isPassword && controller.isObscure.value,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          textInputAction: TextInputAction.done,
          onEditingComplete: onEditingComplete,
          onChanged: (val) {
            // 修改点：利用 GetX 的值校验减少不必要的 UI 刷新
            if (controller.isError.value) controller.isError.value = false;
            onChanged?.call(val);
          },
          style: (customStyle?.style ?? TextStyle(fontSize: 28.sp))
              .copyWith(color: displayTextColor),
          placeholder: hintText,
          placeholderStyle: customStyle?.hintStyle ??
              TextStyle(color: Colors.grey, fontSize: 28.sp),
          cursorColor: Theme.of(context).primaryColor,
          textAlignVertical: TextAlignVertical.center,
          padding: customStyle?.contentPadding ?? EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(color: Colors.transparent),
          prefix: prefix,
          // 修改点：将 suffix 逻辑也放入 Obx 内部以响应 isObscure 变化
          suffix: _buildSuffix(),
        ),
      );
    });
  }

  Widget? _buildSuffix() {
    if (isPassword) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.toggleObscure,
        // 修改点：增加 Obx 局部刷新图标状态
        child: Obx(() => Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Icon(
            controller.isObscure.value ? Icons.visibility_off : Icons.visibility,
            size: 36.w,
            color: Colors.grey,
          ),
        )),
      );
    }
    return suffix;
  }
}

/// 修改点：继承 GetxController 以获得生命周期管理能力
class AppInputController extends GetxController {
  late final TextEditingController textController;
  late final FocusNode focusNode;
  final RegExp? regExp;

  final isError = false.obs;
  final isObscure = true.obs;

  // 修改点：直接暴露 text 字符串，避免外部频繁通过 controller.textController.text 获取
  String get text => textController.text;

  AppInputController({
    String? initialText,
    this.regExp,
    FocusNode? externalFocusNode,
    TextEditingController? externalController,
  }) {
    textController = externalController ?? TextEditingController(text: initialText);
    focusNode = externalFocusNode ?? FocusNode();

    // 监听焦点变化，失焦时可以做一些业务逻辑（可选）
    focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    // 可以在失焦时自动进行 validate()
  }

  /// 校验方法优化：增加非空处理
  bool validate() {
    if (regExp == null) return true;
    isError.value = !regExp!.hasMatch(textController.text);
    return !isError.value;
  }

  void toggleObscure() => isObscure.value = !isObscure.value;

  // 修改点：重写 onClose，确保在 GetX 路由销毁时自动释放资源
  @override
  void onClose() {
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
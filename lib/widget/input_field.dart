import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 抽离样式配置，减少 Widget 构造函数的臃肿
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
  final bool enabled; // 控制业务逻辑上的启用
  final TextInputType keyboardType;
  final List<TextInputFormatter>? formatters;
  final ValueChanged<String>? onChanged;
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
    this.customStyle,
  });

  @override
  Widget build(BuildContext context) {
    // 性能优化：使用 IgnorePointer 替代 Opacity 层的 Stack 遮盖
    // 禁用时通过颜色变灰，避免使用 Opacity 组件触发 saveLayer
    return IgnorePointer(
      ignoring: !enabled,
      child: Obx(() {
        final bool isErr = controller.isError.value;
        final bool obscure = isPassword && controller.isObscure.value;

        // 动态计算颜色，避免离屏渲染
        final Color bgColor = (customStyle?.decoration?.color ?? const Color(0xFFF5F5F5));
        final Color displayBgColor = enabled ? bgColor : bgColor.withValues(alpha: 0.6);
        final Color displayTextColor = (customStyle?.style?.color ?? Colors.black).withValues(alpha: enabled ? 1.0 : 0.5);

        return Container(
          width: customStyle?.width ?? double.infinity,
          height: customStyle?.height ?? 88.h,
          decoration: (customStyle?.decoration ?? BoxDecoration(
            borderRadius: BorderRadius.circular(44.w),
          )).copyWith(
            color: displayBgColor,
            // 错误逻辑合并到内部，保持外观统一
            border: isErr
                ? Border.all(color: Colors.red, width: 1.w)
                : customStyle?.decoration?.border,
          ),
          alignment: Alignment.center,
          child: CupertinoTextField(
            controller: controller.textController,
            focusNode: controller.focusNode,
            enabled: enabled,
            obscureText: obscure,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            onChanged: (val) {
              // 修改点：输入时自动清除错误状态，提升用户体验
              if (controller.isError.value) controller.isError.value = false;
              onChanged?.call(val);
            },
            style: (customStyle?.style ?? TextStyle(fontSize: 28.sp)).copyWith(color: displayTextColor),
            placeholder: hintText,
            placeholderStyle: customStyle?.hintStyle ?? TextStyle(color: Colors.grey, fontSize: 28.sp),
            cursorColor: Theme.of(context).primaryColor,
            // 修改点：垂直对齐优化，解决部分机型文字偏移问题
            textAlignVertical: TextAlignVertical.center,
            padding: customStyle?.contentPadding ?? EdgeInsets.symmetric(horizontal: 20.w),
            decoration: const BoxDecoration(color: Colors.transparent),
            prefix: prefix,
            suffix: _buildSuffix(),
          ),
        );
      }),
    );
  }

  Widget? _buildSuffix() {
    if (isPassword) {
      return GestureDetector(
        // 增加点击区域
        behavior: HitTestBehavior.opaque,
        onTap: controller.toggleObscure,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Icon(
            controller.isObscure.value ? Icons.visibility_off : Icons.visibility,
            size: 36.w,
            color: Colors.grey,
          ),
        ),
      );
    }
    return suffix;
  }
}

/// 控制器逻辑保持纯粹
class AppInputController {
  final TextEditingController textController;
  final FocusNode focusNode;
  final RegExp? regExp;

  final text = "".obs;
  final isError = false.obs;
  final isObscure = true.obs;

  AppInputController({
    String? initialText,
    this.regExp,
    FocusNode? focusNode,
    TextEditingController? controller,
  })  : textController = controller ?? TextEditingController(text: initialText),
        focusNode = focusNode ?? FocusNode() {
    textController.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    text.value = textController.text;
  }

  bool validate() {
    if (regExp == null) return true;
    isError.value = !regExp!.hasMatch(text.value);
    return !isError.value;
  }

  void toggleObscure() => isObscure.value = !isObscure.value;

  void dispose() {
    textController.removeListener(_handleTextChange);
    textController.dispose();
    focusNode.dispose();
  }
}
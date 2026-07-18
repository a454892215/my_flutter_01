import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final VoidCallback? onEditingComplete;
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
    final double targetHeight = customStyle?.height ?? 1.sw * 0.15;
    final double targetWidth = customStyle?.width ?? double.infinity;
    final BoxDecoration baseDecoration = customStyle?.decoration ??
        BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(44.w),
        );

    return ListenableBuilder(
      listenable: Listenable.merge([controller.isError, controller.isObscure]),
      builder: (context, _) {
        final bool isErr = controller.isError.value;

        final Color bgColor = baseDecoration.color ?? const Color(0xFFF5F5F5);
        final Color displayBgColor = enabled ? bgColor : bgColor.withValues(alpha: 0.6);
        final Color displayTextColor = (customStyle?.style?.color ?? Colors.black)
            .withValues(alpha: enabled ? 1.0 : 0.5);

        return Container(
          width: targetWidth,
          height: targetHeight,
          decoration: baseDecoration.copyWith(
            color: displayBgColor,
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
            padding: customStyle?.contentPadding ?? const EdgeInsets.symmetric(horizontal: 5),
            decoration: const BoxDecoration(color: Colors.transparent),
            prefix: prefix,
            suffix: _buildSuffix(),
          ),
        );
      },
    );
  }

  Widget? _buildSuffix() {
    if (isPassword) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.toggleObscure,
        child: ValueListenableBuilder<bool>(
          valueListenable: controller.isObscure,
          builder: (context, isObscure, _) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                size: 36.w,
                color: Colors.grey,
              ),
            );
          },
        ),
      );
    }
    return suffix;
  }
}

class AppInputController {
  late final TextEditingController textController;
  late final FocusNode focusNode;
  final RegExp? regExp;

  final ValueNotifier<bool> isError = ValueNotifier(false);
  final ValueNotifier<bool> isObscure = ValueNotifier(true);

  final bool _ownsTextController;
  final bool _ownsFocusNode;

  String get text => textController.text;

  AppInputController({
    String? initialText,
    this.regExp,
    FocusNode? externalFocusNode,
    TextEditingController? externalController,
  })  : _ownsTextController = externalController == null,
        _ownsFocusNode = externalFocusNode == null {
    textController = externalController ?? TextEditingController(text: initialText);
    focusNode = externalFocusNode ?? FocusNode();
    focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    // 可以在失焦时自动进行 validate()
  }

  /// 校验方法：增加非空处理
  bool validate() {
    if (regExp == null) return true;
    isError.value = !regExp!.hasMatch(textController.text);
    return !isError.value;
  }

  void toggleObscure() => isObscure.value = !isObscure.value;

  void dispose() {
    focusNode.removeListener(_handleFocusChange);
    if (_ownsTextController) textController.dispose();
    if (_ownsFocusNode) focusNode.dispose();
    isError.dispose();
    isObscure.dispose();
  }
}

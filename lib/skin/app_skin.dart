import 'package:flutter/material.dart';

// 必须继承 ThemeExtension，并指定泛型为自己
class AppSkin extends ThemeExtension<AppSkin> {
  final Color textColor1;
  final Color bgColor1;
  final String assetPath; // 增加资源路径支持

  AppSkin({
    required this.textColor1,
    required this.bgColor1,
    required this.assetPath,
  });

  // 必须重写 copyWith：用于主题局部覆盖（虽然全局换肤用得少，但框架要求）
  @override
  AppSkin copyWith({Color? textColor1, Color? bgColor1, String? assetPath}) {
    return AppSkin(
      textColor1: textColor1 ?? this.textColor1,
      bgColor1: bgColor1 ?? this.bgColor1,
      assetPath: assetPath ?? this.assetPath,
    );
  }

  // 必须重写 lerp：这是 Flutter 换肤动效的核心
  // 当你切换主题时，颜色会在这 200ms 内产生平滑渐变（插值动画）
  @override
  AppSkin lerp(ThemeExtension<AppSkin>? other, double t) {
    if (other is! AppSkin) return this;
    return AppSkin(
      textColor1: Color.lerp(textColor1, other.textColor1, t)!,
      bgColor1: Color.lerp(bgColor1, other.bgColor1, t)!,
      assetPath: t < 0.5 ? assetPath : other.assetPath, // 字符串不支持渐变，过半直接切换
    );
  }
}
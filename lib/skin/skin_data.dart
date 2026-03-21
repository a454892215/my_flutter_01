// 定义每套皮肤需要的核心数据
import 'dart:ui';

class SkinData {
  final Color textColor1;
  final Color bgColor1;
  final Color headerBgColor;
  final Color headerTextColor;
  final String assetPath; // 资源目录

  const SkinData({
    required this.textColor1,
    required this.bgColor1,
    required this.headerBgColor,
    required this.headerTextColor,
    required this.assetPath,
  });

  // 在这里统一处理所有属性的插值
  SkinData lerp(SkinData? other, double t) {
    if (other == null) return this;
    return SkinData(
      textColor1: Color.lerp(textColor1, other.textColor1, t)!,
      bgColor1: Color.lerp(bgColor1, other.bgColor1, t)!,
      headerBgColor: Color.lerp(headerBgColor, other.headerBgColor, t)!,
      headerTextColor: Color.lerp(headerTextColor, other.headerTextColor, t)!,
      // 离散属性（非数值）直接切换
      assetPath: t < 0.5 ? assetPath : other.assetPath,
    );
  }
}
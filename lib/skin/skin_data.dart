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
}
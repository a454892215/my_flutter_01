import 'package:flutter/material.dart';

// 使用 ThemeExtension 扩展自定义颜色，这是 Flutter 官方推荐的扩展方式
class AppSkin extends ThemeExtension<AppSkin> {
  final Color textColor1;
  final Color bgColor1;

  AppSkin({required this.textColor1, required this.bgColor1});

  @override
  AppSkin copyWith({Color? textColor1, Color? bgColor1}) {
    return AppSkin(
      textColor1: textColor1 ?? this.textColor1,
      bgColor1: bgColor1 ?? this.bgColor1,
    );
  }

  @override
  AppSkin lerp(ThemeExtension<AppSkin>? other, double t) {
    if (other is! AppSkin) return this;
    return AppSkin(
      textColor1: Color.lerp(textColor1, other.textColor1, t)!,
      bgColor1: Color.lerp(bgColor1, other.bgColor1, t)!,
    );
  }
}



enum SkinType { bright, black, system }

class SkinManager extends ChangeNotifier {
  // 私有构造，单例模式
  SkinManager._();
  static final SkinManager instance = SkinManager._();

  SkinType _curSkinType = SkinType.system;
  SkinType get curSkinType => _curSkinType;

  // 获取当前的 ThemeMode
  ThemeMode get themeMode {
    switch (_curSkinType) {
      case SkinType.bright: return ThemeMode.light;
      case SkinType.black: return ThemeMode.dark;
      case SkinType.system: return ThemeMode.system;
    }
  }

  // 切换皮肤 API
  void updateSkin(SkinType type) {
    if (_curSkinType == type) return;
    _curSkinType = type;
    notifyListeners(); // 核心：通知 UI 刷新
  }

  // 预定义亮色主题
  static ThemeData get brightTheme => ThemeData.light().copyWith(
    extensions: [
      AppSkin(textColor1: Colors.black, bgColor1: Colors.white),
    ],
  );

  // 预定义暗色主题
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    extensions: [
      AppSkin(textColor1: const Color(0xffefefef), bgColor1: const Color(0xff1a1a1a)),
    ],
  );
}
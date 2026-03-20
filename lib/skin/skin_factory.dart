import 'package:flutter/material.dart';
import 'package:flutter_comm/skin/skin_repo.dart';

import 'app_skin.dart';

enum SkinType { bright, black, ocean, forest, system }

class SkinFactory {
  // 统一生成 ThemeData 的方法
  static ThemeData createTheme(SkinType type) {
    // 默认回退到 bright
    final data = SkinRepo.configs[type] ?? SkinRepo.configs[SkinType.bright]!;

    // 根据类型决定基准色调
    final isDark = type == SkinType.black;
    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

    return baseTheme.copyWith(
      extensions: [
        AppSkin(
          textColor1: data.textColor1,
          bgColor1: data.bgColor1,
          assetPath: data.assetPath,
        ),
      ],
    );
  }
}
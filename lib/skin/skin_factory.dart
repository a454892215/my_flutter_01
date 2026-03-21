import 'package:flutter/material.dart';
import 'package:flutter_comm/skin/skin_data.dart';
import 'package:flutter_comm/skin/skin_repo.dart';

import 'app_skin.dart';

enum SkinType { bright, black, ocean, forest, system }

class SkinFactory {
  static ThemeData createTheme(SkinType type) {
    // 1. 获取原始静态配置 SkinData
    final SkinData skinData = SkinRepo.configs[type] ?? SkinRepo.configs[SkinType.bright]!;
    final isDark = type == SkinType.black;
    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();
    return baseTheme.copyWith(
      extensions: [
        // 2. 将整个 config 对象传入
        AppSkin(data: skinData),
      ],
    );
  }
}
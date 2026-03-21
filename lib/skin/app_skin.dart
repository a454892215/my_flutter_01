import 'package:flutter/material.dart';
import 'package:flutter_comm/skin/skin_factory.dart';
import 'package:flutter_comm/skin/skin_repo.dart';
import 'skin_data.dart'; // 假设你的 SkinData 定义在此文件

class AppSkin extends ThemeExtension<AppSkin> {
  // 只持有一个 SkinData 对象，减少属性重复定义
  final SkinData data;

  AppSkin({required this.data});

  @override
  AppSkin copyWith({SkinData? data}) {
    return AppSkin(data: data ?? this.data);
  }

  @override
  AppSkin lerp(ThemeExtension<AppSkin>? other, double t) {
    if (other is! AppSkin) return this;

    // 在这里处理 SkinData 内部属性的插值逻辑
    return AppSkin(
      data: SkinData(
        // 颜色值平滑过渡
        textColor1: Color.lerp(data.textColor1, other.data.textColor1, t)!,
        bgColor1: Color.lerp(data.bgColor1, other.data.bgColor1, t)!,

        // 非数值类型（如 String/AssetPath）无法插值，通常在进度过半时直接切换
        assetPath: t < 0.5 ? data.assetPath : other.data.assetPath,
      ),
    );
  }
}
/// 给 BuildContext 对象增加扩展属性
///这一行非常长，而且容易写错泛型类型 : final skin = Theme.of(context).extension<AppSkin>()!.data;
/// 扩展后 final skin = context.skinData;
extension AppSkinX on BuildContext {
  SkinData get skinData {
    return Theme.of(this).extension<AppSkin>()?.data ??
        SkinRepo.configs[SkinType.bright]!;
  }

  ThemeData get theme => Theme.of(this);
}

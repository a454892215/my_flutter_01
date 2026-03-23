import 'package:flutter/material.dart';

class AppAssetImage extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  /// 是否开启精确解码（默认开启）
  final bool enableResize;

  const AppAssetImage(this.asset,{
    super.key,
    this.width,
    this.height,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
    this.enableResize = true,
  });

  @override
  Widget build(BuildContext context) {
    final double dpr = MediaQuery.of(context).devicePixelRatio;

    /// 🔥 关键优化：控制解码尺寸
    final int? cacheWidth =
    enableResize && width != null ? (width! * dpr).toInt() : null;
    final int? cacheHeight =
    enableResize && height != null ? (height! * dpr).toInt() : null;

    /// 🔥 提前构建 provider（避免重复创建）
    final ImageProvider provider = ResizeImage(
      AssetImage(asset),
      width: cacheWidth,
      height: cacheHeight,
    );

    Widget image = Image(
      image: provider,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.low, // 🔥 降低 GPU 压力
    );

    /// 圆角裁剪（尽量减少层级）
    if (borderRadius > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }

    return image;
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  const AppNetImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final double dpr = MediaQuery.of(context).devicePixelRatio;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      memCacheWidth: width != null ? (width! * dpr).toInt() : null,
      memCacheHeight: height != null ? (height! * dpr).toInt() : null,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      imageBuilder: (context, imageProvider) {
        Widget image = Image(
          image: imageProvider,
          width: width,
          height: height,
          fit: fit,
        );
        if (borderRadius > 0) {
          image = ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: image,
          );
        }

        return image;
      },
    );
  }

  ///  占位图（解决单边约束塌陷问题）
  Widget _buildPlaceholder() {
    return _buildBox(color: const Color(0xFFF5F5F5), child: const SizedBox());
  }

  ///  错误图
  Widget _buildErrorWidget() {
    return _buildBox(
      color: const Color(0xFFEEEEEE),
      child: const Icon(Icons.broken_image, size: 20),
    );
  }

  ///  统一容器（保证尺寸稳定）
  Widget _buildBox({required Color color, required Widget child}) {
    Widget box = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: color,
      child: child,
    );

    /// 关键：防止只传一边时塌陷
    if (width != null && height == null) {
      box = AspectRatio(
        aspectRatio: 1, // 临时占位比例（不会影响最终图片）
        child: box,
      );
    } else if (height != null && width == null) {
      box = AspectRatio(aspectRatio: 1, child: box);
    }

    /// 圆角保持一致
    if (borderRadius > 0) {
      box = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: box,
      );
    }

    return box;
  }
}

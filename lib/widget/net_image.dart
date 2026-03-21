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

      /// 内存优化
      memCacheWidth: width != null ? (width! * dpr).toInt() : null,
      memCacheHeight: height != null ? (height! * dpr).toInt() : null,

      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _error(),

      imageBuilder: (context, provider) {
        Widget image = Image(
          image: provider,
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

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF5F5F5),
    );
  }

  Widget _error() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: const Color(0xFFEEEEEE),
      child: const Icon(Icons.broken_image, size: 20),
    );
  }
}

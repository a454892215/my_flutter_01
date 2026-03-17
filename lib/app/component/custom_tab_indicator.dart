import 'package:flutter/material.dart';

class CustomTabIndicator extends Decoration {
  final double height;
  final Color color;
  final double borderRadius;
  final BoxShadow boxShadow;
  final double? width; // 新增的宽度参数

  const CustomTabIndicator({
    required this.height,
    required this.color,
    this.borderRadius = 0.0,
    this.boxShadow = const BoxShadow(color: Colors.transparent),
    this.width, // 添加宽度参数
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter(
      height: height,
      color: color,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      width: width,
    );
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  final double height;
  final Color color;
  final double borderRadius;
  final BoxShadow boxShadow;
  final double? width; // 新增的宽度参数

  _CustomTabIndicatorPainter({
    required this.height,
    required this.color,
    required this.borderRadius,
    required this.boxShadow,
    required this.width, // 添加宽度参数
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final tabWidth = width ?? configuration.size!.width; // 计算指示器的宽度

    final leftOffset = (configuration.size!.width - tabWidth) / 2.0; // 居中偏移量计算

    final rect = Offset(offset.dx + leftOffset, (offset.dy + configuration.size!.height) - height) &
    Size(tabWidth, height); // 使用指定的宽度和偏移量

    final roundedRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (boxShadow.color != Colors.transparent) {
      final shadowRect = rect.shift(boxShadow.offset);
      final shadowRRect = RRect.fromRectAndRadius(
        shadowRect,
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(
        shadowRRect,
        BoxShadow(
          color: boxShadow.color,
          blurRadius: boxShadow.blurRadius,
          spreadRadius: boxShadow.spreadRadius,
          offset: Offset.zero,
        ).toPaint(),
      );
    }

    canvas.drawRRect(roundedRect, paint);
  }
}



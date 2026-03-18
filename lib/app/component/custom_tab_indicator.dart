import 'dart:ui';

import 'package:flutter/material.dart';

class CustomTabIndicator extends Decoration {
  final double height;
  final Color color;
  final double borderRadius;
  final BoxShadow boxShadow;
  final double? width;

  const CustomTabIndicator({
    required this.height,
    required this.color,
    this.borderRadius = 0.0,
    this.boxShadow = const BoxShadow(color: Colors.transparent),
    this.width,
  });

  // 关键优化：支持插值动画
  // 当 Tab 切换时，框架会调用此方法实现属性的平滑过渡
  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is CustomTabIndicator) {
      return CustomTabIndicator(
        height: lerpDouble(a.height, height, t)!,
        color: Color.lerp(a.color, color, t)!,
        borderRadius: lerpDouble(a.borderRadius, borderRadius, t)!,
        boxShadow: BoxShadow.lerp(a.boxShadow, boxShadow, t)!,
        width: lerpDouble(a.width, width, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter(
      this, // 传递整个对象，减少构造函数参数冗余
      onChanged,
    );
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  final CustomTabIndicator decoration;
  final Paint _paint = Paint()..style = PaintingStyle.fill;
  late final Paint? _shadowPaint; // 缓存阴影 Paint

  _CustomTabIndicatorPainter(
      this.decoration,
      VoidCallback? onChanged,
      ) : super(onChanged) {
    _paint.color = decoration.color;

    // 提前计算阴影 Paint，避免在 paint 方法中反复调用 toPaint()
    if (decoration.boxShadow.color != Colors.transparent) {
      _shadowPaint = decoration.boxShadow.toPaint();
    } else {
      _shadowPaint = null;
    }
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Size? configurationSize = configuration.size;
    if (configurationSize == null) return;

    // 使用局部变量减少属性访问开销
    final double indicatorHeight = decoration.height;
    final double? targetWidth = decoration.width;

    final tabWidth = targetWidth ?? configurationSize.width;
    final leftOffset = (configurationSize.width - tabWidth) / 2.0;

    final rect = Offset(
        offset.dx + leftOffset,
        (offset.dy + configurationSize.height) - indicatorHeight
    ) & Size(tabWidth, indicatorHeight);

    final roundedRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(decoration.borderRadius),
    );

    // 1. 绘制阴影（使用缓存好的 Paint）
    if (_shadowPaint != null) {
      canvas.drawRRect(roundedRect.shift(decoration.boxShadow.offset), _shadowPaint);
    }

    // 2. 绘制指示器
    canvas.drawRRect(roundedRect, _paint);
  }
}

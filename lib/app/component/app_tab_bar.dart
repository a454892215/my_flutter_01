import 'package:flutter/material.dart';
import 'dart:ui';

import '../../screen_info.dart';

/// 基于TabBar的水平tab 可以设置 indicatorWidth
class AppTabBar extends StatefulWidget {
  const AppTabBar({
    super.key,
    required this.tabs,
    this.isScrollable = false,
    this.height,
    this.onTap,
    this.indicatorWidth,
    this.controller,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  final List<Map<String, dynamic>> tabs;

  final TabController? controller;

  // 是否可以滚动
  final bool isScrollable;

  // 高度
  final double? height;

  // 指示器宽度
  final double? indicatorWidth;

  final EdgeInsetsGeometry? labelPadding;

  // 点击回调
  final void Function(int index, String value)? onTap;

  @override
  State<AppTabBar> createState() => _AppTabState();
}

class _AppTabState extends State<AppTabBar> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: widget.controller,
      indicatorColor: const Color.fromRGBO(14, 209, 244, 1),
      labelColor: Colors.white,
      unselectedLabelColor: const Color.fromRGBO(255, 255, 255, 0.40),
      // 超出滚动
      isScrollable: widget.isScrollable,
      dividerHeight: 1,
      tabAlignment: TabAlignment.start,
      padding: EdgeInsets.zero,
      labelPadding: widget.labelPadding,
      dividerColor: Color(0xffffffff),
      labelStyle: TextStyle(fontSize: 26.w, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 26.w, fontWeight: FontWeight.w400),
      onTap: (index) {
        if (widget.onTap != null) {
          widget.onTap!(index, (widget.tabs[index]['value'] ?? '').toString());
        }
      },
      indicator: CustomTabIndicator(
        color: const Color.fromRGBO(14, 209, 244, 1),
        width: widget.indicatorWidth,
        height: 6.w,
        borderRadius: 10.w,
        boxShadow: BoxShadow(offset: Offset(0, -2.w), blurRadius: 6.w, spreadRadius: 0, color: const Color(0xFF0ED1F4)),
      ),
      tabs: widget.tabs.map((e) => Container(height: widget.height ?? 100.w, alignment: Alignment.center, child: Text("${e['label']}"))).toList(),
    );
  }
}

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

  _CustomTabIndicatorPainter(this.decoration, VoidCallback? onChanged) : super(onChanged) {
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

    final rect = Offset(offset.dx + leftOffset, (offset.dy + configurationSize.height) - indicatorHeight) & Size(tabWidth, indicatorHeight);

    final roundedRect = RRect.fromRectAndRadius(rect, Radius.circular(decoration.borderRadius));

    // 1. 绘制阴影（使用缓存好的 Paint）
    if (_shadowPaint != null) {
      canvas.drawRRect(roundedRect.shift(decoration.boxShadow.offset), _shadowPaint);
    }

    // 2. 绘制指示器
    canvas.drawRRect(roundedRect, _paint);
  }
}

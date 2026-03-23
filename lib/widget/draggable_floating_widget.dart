import 'package:flutter/material.dart';

/// 通用的全屏拖拽包装容器
class DraggableFloatingWidget extends StatefulWidget {
  final Widget child;
  final Offset initialOffset;
  final double width;
  final double height;

  const DraggableFloatingWidget({
    super.key,
    required this.child,
    this.initialOffset = const Offset(20, 100),
    required this.width,
    required this.height,
  });

  @override
  State<DraggableFloatingWidget> createState() => _DraggableFloatingWidgetState();
}

class _DraggableFloatingWidgetState extends State<DraggableFloatingWidget> {
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕尺寸和安全区域（避开状态栏和底部横条）
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
            // 边界检查：确保组件不会被拖出屏幕可见区域
            double x = _offset.dx.clamp(0.0, screenSize.width - widget.width);
            double y = _offset.dy.clamp(
                padding.top,
                screenSize.height - padding.bottom - widget.height
            );
            _offset = Offset(x, y);
          });
        },
        child: widget.child,
      ),
    );
  }
}
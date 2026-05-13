import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 全局悬浮层：插入根 [Overlay]，可叠在当前路由之上。
///
/// 仅依赖 Flutter SDK，可复制到任意工程使用。
///
/// [show] 的 [context] 须处于带 [Overlay] 的子树中（例如 [MaterialApp] 下任意页面
/// 的 `context`，或 `MaterialApp.builder` 里子组件的 `context`）。
///
/// **布局说明**：根 [Overlay] 会给子节点「尽量撑满」的约束；此处用 [Stack] 承载，
/// 避免 [Material] 单独铺满全屏。
///
/// - 若 [button] 根节点是 [Positioned] / [PositionedDirectional]，则直接作为 [Stack]
///   子节点（全屏坐标系），**不参与**内置拖动/贴边；需要时请自行实现。
/// - 否则：可拖动，松手后自动贴到**距离按钮中心最近**的一条屏幕边（含 [SafeArea]）。
class GlobalFloatingOverlay {
  GlobalFloatingOverlay._();

  static OverlayEntry? _entry;

  /// 显示悬浮内容；若已显示则先移除再展示新的 [button]。
  static void show(Widget button, BuildContext context) {
    close();
    final OverlayState? overlay =
        Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      debugPrint(
        'GlobalFloatingOverlay.show: 未找到 Overlay，请传入 MaterialApp/CupertinoApp 子树内的 context',
      );
      return;
    }
    _entry = OverlayEntry(
      builder: (BuildContext context) => _OverlayFloatingBody(child: button),
    );
    overlay.insert(_entry!);
  }

  /// 移除当前悬浮层。
  static void close() {
    _entry?.remove();
    _entry = null;
  }
}

/// Overlay 满屏约束下：小部件按自身尺寸布局，且 [Positioned] 仍可作为根使用。
class _OverlayFloatingBody extends StatelessWidget {
  const _OverlayFloatingBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        if (child is Positioned || child is PositionedDirectional)
          child
        else
          _DraggableSnapEdgeOverlay(child: child),
      ],
    );
  }
}

/// 拖动悬浮块；[onPanEnd] 时吸附到距离中心最近的一条边。
class _DraggableSnapEdgeOverlay extends StatefulWidget {
  const _DraggableSnapEdgeOverlay({required this.child});

  final Widget child;

  @override
  State<_DraggableSnapEdgeOverlay> createState() =>
      _DraggableSnapEdgeOverlayState();
}

class _DraggableSnapEdgeOverlayState extends State<_DraggableSnapEdgeOverlay>
    with SingleTickerProviderStateMixin {
  static const double _margin = 16;

  final GlobalKey _measureKey = GlobalKey();

  Size _childSize = Size.zero;
  Offset _offset = Offset.zero;
  bool _placed = false;

  late final AnimationController _snapController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  Animation<Offset>? _snapAnimation;

  @override
  void initState() {
    super.initState();
    _snapController.addStatusListener(_onSnapStatus);
    WidgetsBinding.instance.addPostFrameCallback(_tryMeasure);
  }

  void _onSnapStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _snapAnimation?.removeListener(_onSnapTick);
    }
  }

  @override
  void dispose() {
    _snapController.removeStatusListener(_onSnapStatus);
    _snapAnimation?.removeListener(_onSnapTick);
    _snapController.dispose();
    super.dispose();
  }

  void _onSnapTick() {
    if (!mounted) return;
    final anim = _snapAnimation;
    if (anim == null) return;
    setState(() => _offset = anim.value);
  }

  void _tryMeasure(_) {
    if (!mounted || _placed) return;
    final box = _measureKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      WidgetsBinding.instance.addPostFrameCallback(_tryMeasure);
      return;
    }
    final s = box.size;
    if (s.width <= 0 || s.height <= 0) {
      WidgetsBinding.instance.addPostFrameCallback(_tryMeasure);
      return;
    }
    setState(() {
      _childSize = s;
      _placed = true;
      _offset = _initialBottomRight(MediaQuery.of(context), s);
    });
  }

  /// 首次出现：右下角留白。
  Offset _initialBottomRight(MediaQueryData mq, Size child) {
    final pad = mq.padding;
    final sw = mq.size.width;
    final sh = mq.size.height;
    return Offset(
      sw - pad.right - child.width - _margin,
      sh - pad.bottom - child.height - _margin,
    );
  }

  Offset _clampOffset(Offset o, MediaQueryData mq) {
    final pad = mq.padding;
    final sw = mq.size.width;
    final sh = mq.size.height;
    final w = _childSize.width;
    final h = _childSize.height;
    return Offset(
      o.dx.clamp(pad.left, math.max(pad.left, sw - pad.right - w)),
      o.dy.clamp(pad.top, math.max(pad.top, sh - pad.bottom - h)),
    );
  }

  /// 距离按钮中心最近的一条屏幕边，贴边后另一轴仍在安全区内滑动。
  Offset _snapTarget(MediaQueryData mq) {
    final pad = mq.padding;
    final sw = mq.size.width;
    final sh = mq.size.height;
    final w = _childSize.width;
    final h = _childSize.height;

    if (w <= 0 || h <= 0) return _offset;

    final cx = _offset.dx + w / 2;
    final cy = _offset.dy + h / 2;

    final dl = cx - pad.left;
    final dr = sw - pad.right - cx;
    final dt = cy - pad.top;
    final db = sh - pad.bottom - cy;

    var edge = 0;
    var best = dl;
    if (dr < best) {
      best = dr;
      edge = 1;
    }
    if (dt < best) {
      best = dt;
      edge = 2;
    }
    if (db < best) {
      edge = 3;
    }

    final minX = pad.left;
    final maxX = math.max(minX, sw - pad.right - w);
    final minY = pad.top;
    final maxY = math.max(minY, sh - pad.bottom - h);

    switch (edge) {
      case 0:
        return Offset(minX, _offset.dy.clamp(minY, maxY));
      case 1:
        return Offset(maxX, _offset.dy.clamp(minY, maxY));
      case 2:
        return Offset(_offset.dx.clamp(minX, maxX), minY);
      default:
        return Offset(_offset.dx.clamp(minX, maxX), maxY);
    }
  }

  void _stopSnapAndSyncOffset() {
    if (_snapController.isAnimating) {
      final anim = _snapAnimation;
      if (anim != null) {
        _offset = anim.value;
      }
      _snapAnimation?.removeListener(_onSnapTick);
      _snapController.stop();
      _snapController.reset();
    }
  }

  void _runSnap(MediaQueryData mq) {
    if (_childSize == Size.zero) return;
    final target = _snapTarget(mq);
    if ((_offset - target).distance < 0.5) return;

    _snapAnimation?.removeListener(_onSnapTick);
    _snapAnimation = Tween<Offset>(begin: _offset, end: target).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    )..addListener(_onSnapTick);

    _snapController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: _offset.dx,
          top: _offset.dy,
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onPanStart: (_) => _stopSnapAndSyncOffset(),
            onPanUpdate: (DragUpdateDetails d) {
              if (_childSize == Size.zero) return;
              setState(() {
                _offset = _clampOffset(_offset + d.delta, mq);
              });
            },
            onPanEnd: (_) => _runSnap(mq),
            child: Material(
              key: _measureKey,
              type: MaterialType.transparency,
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}

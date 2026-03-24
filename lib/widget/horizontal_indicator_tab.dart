
import 'package:flutter/material.dart';

/// 属性配置
class IndicatorAttr {
  const IndicatorAttr({
    this.color = Colors.green,
    this.height = 3.0,
    this.width,
    this.indicatorScale = 0.8,
    this.bottomPadding = 2.0, // 增加底部间距配置
  });
  final Color color;
  final double height;
  final double? width; // 若为null则取 itemWidth * 0.8
  final double bottomPadding;
  final double indicatorScale;
}

/// 增强型宽度管理器
class _TabWidthManager {
  final List<double> _itemWidths = [];
  final List<double> _offsets = [0.0];

  void updateWidths(List<double> widths) {
    _itemWidths.clear();
    _itemWidths.addAll(widths);
    _offsets.clear();
    _offsets.add(0.0);
    double sum = 0;
    for (var w in _itemWidths) {
      sum += w;
      _offsets.add(sum);
    }
  }

  double getOffsetAt(int index) => (index >= 0 && index < _offsets.length) ? _offsets[index] : 0.0;
  double getWidthAt(int index) => (index >= 0 && index < _itemWidths.length) ? _itemWidths[index] : 0.0;
  bool get isReady => _itemWidths.isNotEmpty;
}

typedef ItemBuilder = Widget Function(BuildContext context, int index, bool isSelected);

/// 基于SingleChildScrollView的 水平 tabview，可以自定义TabWidget样式，选中后的tab自动居中
/// indicator的宽度会根据TabWidget的宽度自动调整
class HorizontalIndicatorTab extends StatefulWidget {
  const HorizontalIndicatorTab({
    super.key,
    required this.size,
    required this.height,
    required this.onSelectChanged,
    required this.controller,
    this.bgColor,
    this.indicatorAttr = const IndicatorAttr(),
    this.bgImgPath,
    required this.itemBuilder,
  });

  final int size;
  final ItemBuilder itemBuilder;
  final double height;
  final void Function(int index) onSelectChanged;
  final Color? bgColor;
  final IndicatorAttr indicatorAttr;
  final HorizontalTabController controller;
  final String? bgImgPath;

  @override
  State<HorizontalIndicatorTab> createState() => _HorizontalIndicatorTabState();
}

class _HorizontalIndicatorTabState extends State<HorizontalIndicatorTab> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _animController;
  late final CurvedAnimation _curvedAnimation;

  final _TabWidthManager _widthManager = _TabWidthManager();
  List<GlobalKey> _itemKeys = [];

  // 使用 Tween 对象本身，而不是 Animation 对象，避免频繁创建实例
  final Tween<double> _leftTween = Tween(begin: 0.0, end: 0.0);
  final Tween<double> _widthTween = Tween(begin: 0.0, end: 0.0);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _curvedAnimation = CurvedAnimation(parent: _animController, curve: Curves.fastOutSlowIn);
    _updateKeys();
    _attachController();

    // 确保在第一帧布局完成后测量
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureItemWidths(isInitial: true));
  }

  void _updateKeys() {
    _itemKeys = List.generate(widget.size, (index) => GlobalKey());
  }

  void _measureItemWidths({bool isInitial = false}) {
    if (!mounted) return;

    final List<double> widths = _itemKeys.map((key) {
      final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
      return box?.hasSize == true ? box!.size.width : 0.0;
    }).toList();

    if (widths.every((w) => w == 0)) return;

    _widthManager.updateWidths(widths);

    int cur = widget.controller.selectedIndex;
    double targetLeft = _calculateIndicatorLeft(cur);
    double targetWidth = _calculateIndicatorWidth(cur);

    if (isInitial) {
      _leftTween.begin = _leftTween.end = targetLeft;
      _widthTween.begin = _widthTween.end = targetWidth;
      _autoScroll(cur, animate: false);
    }

    // 仅在测量完成后刷新一次，后续通过动画更新
    if (mounted) setState(() {});
  }

  double _calculateIndicatorWidth(int index) {
    double itemW = _widthManager.getWidthAt(index);
    return widget.indicatorAttr.width ?? (itemW * widget.indicatorAttr.indicatorScale);
  }

  double _calculateIndicatorLeft(int index) {
    double itemOffset = _widthManager.getOffsetAt(index);
    double itemWidth = _widthManager.getWidthAt(index);
    double indicatorWidth = _calculateIndicatorWidth(index);
    return itemOffset + (itemWidth - indicatorWidth) / 2;
  }

  void _attachController() {
    widget.controller.selectedIndexNotifier.addListener(_onControllerIndexChanged);
  }

  @override
  void didUpdateWidget(HorizontalIndicatorTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.selectedIndexNotifier.removeListener(_onControllerIndexChanged);
      _attachController();
    }
    if (widget.size != oldWidget.size) {
      _updateKeys();
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureItemWidths(isInitial: true));
    }
  }

  @override
  void dispose() {
    widget.controller.selectedIndexNotifier.removeListener(_onControllerIndexChanged);
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onControllerIndexChanged() {
    _moveTo(widget.controller.selectedIndex);
  }

  void _moveTo(int pos) {
    if (!mounted || !_widthManager.isReady) return;

    // 关键优化：从当前动画的实际值开始，保证动画连贯
    _leftTween.begin = _leftTween.evaluate(_curvedAnimation);
    _widthTween.begin = _widthTween.evaluate(_curvedAnimation);

    _leftTween.end = _calculateIndicatorLeft(pos);
    _widthTween.end = _calculateIndicatorWidth(pos);

    _animController.forward(from: 0);
    widget.onSelectChanged(pos);
    _autoScroll(pos);
  }

  void _autoScroll(int pos, {bool animate = true}) {
    if (!_scrollController.hasClients || !_widthManager.isReady) return;

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    double viewportWidth = box.size.width;
    double itemWidth = _widthManager.getWidthAt(pos);
    double itemOffset = _widthManager.getOffsetAt(pos);

    double target = itemOffset - (viewportWidth / 2) + (itemWidth / 2);
    double maxScroll = _scrollController.position.maxScrollExtent;
    target = target.clamp(0.0, maxScroll);

    if (animate) {
      _scrollController.animateTo(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _scrollController.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.bgColor,
        image: widget.bgImgPath != null
            ? DecorationImage(image: AssetImage(widget.bgImgPath!), fit: BoxFit.cover)
            : null,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: widget.controller.selectedIndexNotifier,
              builder: (context, selectedIndex, _) {
                return Row(
                  children: List.generate(widget.size, (i) {
                    return GestureDetector(
                      key: _itemKeys[i],
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.controller.select(i),
                      child: widget.itemBuilder(context, i, i == selectedIndex),
                    );
                  }),
                );
              },
            ),
            if (_widthManager.isReady)
              IgnorePointer( // 指示器不拦截点击事件
                child: AnimatedBuilder(
                  animation: _curvedAnimation,
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size(_widthManager.getOffsetAt(widget.size), widget.height),
                      painter: _IndicatorPainter(
                        indicatorLeft: _leftTween.evaluate(_curvedAnimation),
                        width: _widthTween.evaluate(_curvedAnimation),
                        height: widget.indicatorAttr.height,
                        color: widget.indicatorAttr.color,
                        bottomPadding: widget.indicatorAttr.bottomPadding,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IndicatorPainter extends CustomPainter {
  final double indicatorLeft;
  final double width;
  final double height;
  final Color color;
  final double bottomPadding;

  _IndicatorPainter({
    required this.indicatorLeft,
    required this.width,
    required this.height,
    required this.color,
    required this.bottomPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 修复坐标系：CustomPaint 在 Stack 底部，y 为 0 时已经在底部
    final RRect rrect = RRect.fromLTRBR(
      indicatorLeft,
      size.height - height - bottomPadding,
      indicatorLeft + width,
      size.height - bottomPadding,
      Radius.circular(height / 2),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_IndicatorPainter oldDelegate) {
    return oldDelegate.indicatorLeft != indicatorLeft ||
        oldDelegate.width != width ||
        oldDelegate.color != color;
  }
}

class HorizontalTabController {
  final ValueNotifier<int> selectedIndexNotifier;
  final List<int> _history = [];

  HorizontalTabController({int initialIndex = 0})
      : selectedIndexNotifier = ValueNotifier<int>(initialIndex) {
    _history.add(initialIndex);
  }

  int get selectedIndex => selectedIndexNotifier.value;

  void select(int index) {
    if (selectedIndexNotifier.value == index) return;
    _history.add(index);
    selectedIndexNotifier.value = index;
  }

  void back() {
    if (_history.length > 1) {
      _history.removeLast();
      selectedIndexNotifier.value = _history.last;
    }
  }

  void dispose() {
    selectedIndexNotifier.dispose();
  }
}
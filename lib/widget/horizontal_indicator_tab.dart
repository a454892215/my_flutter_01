import 'package:flutter/material.dart';

/// 属性配置
class IndicatorAttr {
  const IndicatorAttr({
    this.color = Colors.green,
    this.height = 3.0,
    this.width,
    this.indicatorScale = 0.8,
    this.bottomPadding = 2.0,
  });
  final Color color;
  final double height;
  final double? width;
  final double bottomPadding;
  final double indicatorScale;
}

class _TabWidthManager {
  final List<double> _itemWidths = [];
  final List<double> _offsets = [];

  void updateWidths(List<double> widths) {
    _itemWidths.clear();
    _itemWidths.addAll(widths);
    _offsets.clear();
    double sum = 0;
    for (var w in _itemWidths) {
      _offsets.add(sum);
      sum += w;
    }
  }

  double getOffsetAt(int index) => (index >= 0 && index < _offsets.length) ? _offsets[index] : 0.0;
  double getWidthAt(int index) => (index >= 0 && index < _itemWidths.length) ? _itemWidths[index] : 0.0;
  bool get isReady => _itemWidths.isNotEmpty;
}

typedef ItemBuilder = Widget Function(BuildContext context, int index, bool isSelected);

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

class _HorizontalIndicatorTabState extends State<HorizontalIndicatorTab> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final _TabWidthManager _widthManager = _TabWidthManager();
  late List<GlobalKey> _itemKeys;

  // 优化点 1: 使用 AnimationController 替代 AnimatedPositioned，减少 Layout 触发
  late AnimationController _animationController;
  late Animation<double> _leftAnimation;
  late Animation<double> _widthAnimation;

  double _lastLeft = 0.0;
  double _lastWidth = 0.0;

  bool _isMeasured = false;

  @override
  void initState() {
    super.initState();
    _updateKeys();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 初始化动画对象
    _leftAnimation = ConstantTween<double>(0.0).animate(_animationController);
    _widthAnimation = ConstantTween<double>(0.0).animate(_animationController);

    widget.controller.selectedIndexNotifier.addListener(_onControllerIndexChanged);
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

    if (widths.isEmpty || widths.every((w) => w == 0)) return;

    _widthManager.updateWidths(widths);

    int cur = widget.controller.selectedIndex;
    double targetL = _calculateIndicatorLeft(cur);
    double targetW = _calculateIndicatorWidth(cur);

    // 优化点 2: 初始状态直接跳过动画
    setState(() {
      _lastLeft = targetL;
      _lastWidth = targetW;
      _leftAnimation = ConstantTween<double>(targetL).animate(_animationController);
      _widthAnimation = ConstantTween<double>(targetW).animate(_animationController);
      _isMeasured = true;
    });

    if (isInitial) {
      _autoScroll(cur, animate: false);
    }
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

  void _onControllerIndexChanged() {
    final int pos = widget.controller.selectedIndex;
    if (!mounted || !_widthManager.isReady) return;

    double newLeft = _calculateIndicatorLeft(pos);
    double newWidth = _calculateIndicatorWidth(pos);

    // 优化点 3: 使用平滑动画曲线，并只在目标变化时启动动画
    _leftAnimation = Tween<double>(begin: _lastLeft, end: newLeft).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn),
    );
    _widthAnimation = Tween<double>(begin: _lastWidth, end: newWidth).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn),
    );

    _lastLeft = newLeft;
    _lastWidth = newWidth;

    _animationController.forward(from: 0);

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
    // 检查 maxScrollExtent 是否有效
    if (_scrollController.position.hasContentDimensions) {
      double maxScroll = _scrollController.position.maxScrollExtent;
      target = target.clamp(0.0, maxScroll);
    }

    if (animate) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  @override
  void didUpdateWidget(HorizontalIndicatorTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.selectedIndexNotifier.removeListener(_onControllerIndexChanged);
      widget.controller.selectedIndexNotifier.addListener(_onControllerIndexChanged);
    }
    if (widget.size != oldWidget.size) {
      _updateKeys();
      _isMeasured = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureItemWidths(isInitial: true));
    }
  }

  @override
  void dispose() {
    widget.controller.selectedIndexNotifier.removeListener(_onControllerIndexChanged);
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      clipBehavior: Clip.hardEdge,
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
            RepaintBoundary(
              child: ValueListenableBuilder<int>(
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
            ),
            // 优化点 4: 使用 AnimatedBuilder + Positioned，配合 Transform.translate 性能更佳
            // 这里为了保持原有逻辑清晰，采用 Positioned 配合动画变量
            if (_isMeasured)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned(
                    left: _leftAnimation.value,
                    bottom: widget.indicatorAttr.bottomPadding,
                    child: Container(
                      width: _widthAnimation.value,
                      height: widget.indicatorAttr.height,
                      decoration: BoxDecoration(
                        color: widget.indicatorAttr.color,
                        borderRadius: BorderRadius.circular(widget.indicatorAttr.height / 2),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
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
    if (_history.length > 20) _history.removeAt(0);
    _history.add(index);
    selectedIndexNotifier.value = index;
  }

  void back() {
    if (_history.length > 1) {
      _history.removeLast();
      selectedIndexNotifier.value = _history.last;
    }
  }

  // 外部销毁
  void dispose() {
    selectedIndexNotifier.dispose();
  }
}
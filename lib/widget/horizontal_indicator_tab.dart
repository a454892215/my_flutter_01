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

/// 增强型宽度管理器
class _TabWidthManager {
  final List<double> _itemWidths = [];
  final List<double> _offsets = [];

  void updateWidths(List<double> widths) {
    _itemWidths.clear();
    _itemWidths.addAll(widths);
    _offsets.clear();
    double sum = 0;
    for (var w in _itemWidths) {
      _offsets.add(sum); // 记录每个 item 的起始偏移
      sum += w;
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

class _HorizontalIndicatorTabState extends State<HorizontalIndicatorTab> {
  final ScrollController _scrollController = ScrollController();
  final _TabWidthManager _widthManager = _TabWidthManager();
  late List<GlobalKey> _itemKeys;

  // 修改：直接记录目标位置和宽度，交给 AnimatedPositioned 处理
  double _targetLeft = 0.0;
  double _targetWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _updateKeys();
    widget.controller.selectedIndexNotifier.addListener(_onControllerIndexChanged);
    // 第一帧后测量并初始化位置
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
    if (isInitial) {
      setState(() {
        _targetLeft = _calculateIndicatorLeft(cur);
        _targetWidth = _calculateIndicatorWidth(cur);
      });
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

    // 修改点：直接更新目标状态，AnimatedPositioned 会处理时长为 300ms 的平滑过渡
    setState(() {
      _targetLeft = _calculateIndicatorLeft(pos);
      _targetWidth = _calculateIndicatorWidth(pos);
    });

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
      // 关键：滚动曲线必须与指示器动画曲线一致
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
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureItemWidths(isInitial: true));
    }
  }

  @override
  void dispose() {
    widget.controller.selectedIndexNotifier.removeListener(_onControllerIndexChanged);
    _scrollController.dispose();
    super.dispose();
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
            // Tab 列表
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
            // 修改点：使用 AnimatedPositioned 代替手动 AnimationController
            // 它能完美处理宽度变化与位移变化的同步
            if (_widthManager.isReady)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                left: _targetLeft,
                bottom: widget.indicatorAttr.bottomPadding,
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn,
                    width: _targetWidth,
                    height: widget.indicatorAttr.height,
                    decoration: BoxDecoration(
                      color: widget.indicatorAttr.color,
                      borderRadius: BorderRadius.circular(widget.indicatorAttr.height / 2),
                    ),
                  ),
                ),
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
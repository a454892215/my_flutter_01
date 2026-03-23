import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 属性配置
class IndicatorAttr {
  IndicatorAttr({this.color, required this.height, required this.width});
  final Color? color;
  final double height;
  final double width;
}

/// 预计算宽度与偏移量
class _TabWidthManager {
  final List<double> itemWidths;
  late List<double> _offsets;

  _TabWidthManager(this.itemWidths) {
    _offsets = [0.0];
    double sum = 0;
    for (var w in itemWidths) {
      sum += w;
      _offsets.add(sum);
    }
  }

  double getOffsetAt(int index) => (index >= 0 && index < _offsets.length) ? _offsets[index] : 0.0;
  double getWidthAt(int index) => (index >= 0 && index < itemWidths.length) ? itemWidths[index] : 0.0;
  double get totalWidth => _offsets.last;
}

typedef ItemBuilder = Widget Function(BuildContext context, int index, int selectedPos);

class HorizontalIndicatorTab extends StatefulWidget {
  const HorizontalIndicatorTab({
    super.key,
    required this.size,
    required this.height,
    required this.itemWidthList,
    required this.onSelectChanged,
    required this.controller,
    this.bgColor,
    this.indicatorAttr,
    this.bgImgPath,
    this.indicator,
    required this.itemBuilder,
  });

  final int size;
  final ItemBuilder itemBuilder;
  final double height;
  final List<double> itemWidthList;
  final void Function(int index) onSelectChanged;
  final Color? bgColor;
  final IndicatorAttr? indicatorAttr;
  final HorizontalTabController controller;
  final String? bgImgPath;
  final Widget? indicator;

  @override
  State<HorizontalIndicatorTab> createState() => _HorizontalIndicatorTabState();
}
 /// 基于 SingleChildScrollView的水平Tab 使用于Tab数目比较小 每个Tab 宽度不相同的情况
class _HorizontalIndicatorTabState extends State<HorizontalIndicatorTab> with TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  late _TabWidthManager _widthManager;

  // 关键优化：双 Tween 同步位置与宽度
  late Tween<double> _leftTween;
  late Tween<double> _widthTween;
  late Animation<double> _leftAnimation;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _widthManager = _TabWidthManager(widget.itemWidthList);
    _initAnimations();
    _attachController();
  }

  void _initAnimations() {
    int cur = widget.controller.selectedIndex;
    double initialLeft = _widthManager.getOffsetAt(cur);
    double initialWidth = _widthManager.getWidthAt(cur);

    _leftTween = Tween(begin: initialLeft, end: initialLeft);
    _widthTween = Tween(begin: initialWidth, end: initialWidth);

    final curve = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _leftAnimation = _leftTween.animate(curve);
    _widthAnimation = _widthTween.animate(curve);
  }

  void _attachController() {
   // widget.controller.attach(this);
    widget.controller.selectedIndexNotifier.addListener(_onControllerIndexChanged);
  }

  @override
  void didUpdateWidget(HorizontalIndicatorTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.selectedIndexNotifier.removeListener(_onControllerIndexChanged);
      _attachController();
    }
    if (widget.itemWidthList != oldWidget.itemWidthList) {
      _widthManager = _TabWidthManager(widget.itemWidthList);
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
    if (!mounted) return;

    _leftTween.begin = _leftAnimation.value;
    _leftTween.end = _widthManager.getOffsetAt(pos);

    _widthTween.begin = _widthAnimation.value;
    _widthTween.end = _widthManager.getWidthAt(pos);

    _animController.forward(from: 0);
    widget.onSelectChanged(pos);

    // 确保在下一帧（布局完成后）滚动
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScroll(pos));
  }

  void _autoScroll(int pos) {
    if (!_scrollController.hasClients) return;

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    double viewportWidth = box.size.width;
    double itemWidth = _widthManager.getWidthAt(pos);
    double itemOffset = _widthManager.getOffsetAt(pos);

    double target = itemOffset - (viewportWidth / 2) + (itemWidth / 2);
    double maxScroll = _scrollController.position.maxScrollExtent;

    _scrollController.animateTo(
      target.clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
            // Tab Items
            ValueListenableBuilder<int>(
              valueListenable: widget.controller.selectedIndexNotifier,
              builder: (context, selectedIndex, _) {
                return Row(
                  children: List.generate(widget.size, (i) {
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => widget.controller.select(i),
                      minimumSize: Size(0, 0),
                      child: widget.itemBuilder(context, i, selectedIndex),
                    );
                  }),
                );
              },
            ),
            // 指示器：同步位置与宽度
            AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return Positioned(
                  left: _leftAnimation.value,
                  width: _widthAnimation.value,
                  bottom: 0,
                  child: Center( // 解决指示器在不同宽度 Item 下的对齐问题
                    child: widget.indicator ?? _buildDefaultIndicator(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIndicator() {
    double w = widget.indicatorAttr?.width ?? 24.0;
    double h = widget.indicatorAttr?.height ?? 3.0;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: widget.indicatorAttr?.color ?? Colors.blue,
        borderRadius: BorderRadius.circular(h / 2),
      ),
    );
  }
}

/// 控制器实现
class HorizontalTabController {
 // _HorizontalIndicatorTabState? _state;
  final ValueNotifier<int> selectedIndexNotifier;
  final List<int> _history = [];

  HorizontalTabController({int initialIndex = 0})
      : selectedIndexNotifier = ValueNotifier<int>(initialIndex) {
    _history.add(initialIndex);
  }

  int get selectedIndex => selectedIndexNotifier.value;

 // void attach(_HorizontalIndicatorTabState state) => _state = state;

  void select(int index) {
    if (selectedIndexNotifier.value == index) return;
    if (_history.isEmpty || _history.last != index) {
      _history.add(index);
    }
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
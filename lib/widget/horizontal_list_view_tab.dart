import 'package:flutter/material.dart';

typedef ItemBuilder = Widget Function(BuildContext context, int index, int selectedPos);
typedef Callback<T> = void Function(T t);

/// 基于 ListView 的水平 tab，适用于 tab 数目较大的情况
class HorizontalListViewTab extends StatefulWidget {
  const HorizontalListViewTab({
    super.key,
    required this.size,
    required this.itemBuilder,
    this.scrollDir = Axis.horizontal,
    this.itemMargin = 10,
    this.bgColor,
    required this.width,
    required this.height,
    required this.itemWidth,
    required this.onSelectChanged,
    this.initialIndex = 0,
  });

  final int size;
  final ItemBuilder itemBuilder;
  final Axis scrollDir;
  final double itemMargin;
  final double width;
  final double height;
  final double itemWidth;
  final Callback<int> onSelectChanged;
  final Color? bgColor;
  final int initialIndex;

  @override
  State<HorizontalListViewTab> createState() => HorizontalListViewTabState();
}

class HorizontalListViewTabState extends State<HorizontalListViewTab> {
  late int selectedIndex;
  final ScrollController scrollController = ScrollController();
  final GlobalKey rootKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void select(int pos) {
    if (selectedIndex == pos) return;
    setState(() {
      selectedIndex = pos;
    });
    widget.onSelectChanged(pos);
    autoScroll(pos);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        key: rootKey,
        width: widget.width,
        height: widget.height,
        color: widget.bgColor,
        child: ListView.separated(
          itemCount: widget.size,
          shrinkWrap: true,
          scrollDirection: widget.scrollDir,
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, pos) {
            return GestureDetector(
              onTap: () => select(pos),
              child: widget.itemBuilder(context, pos, selectedIndex),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(width: widget.itemMargin, height: widget.itemMargin);
          },
        ),
      ),
    );
  }

  void autoScroll(int selectedPos) {
    double parentWidth = rootKey.currentContext?.size?.width ?? widget.width;
    double contentWidth = widget.size * widget.itemWidth + (widget.size - 1) * widget.itemMargin;
    double width = contentWidth < parentWidth ? contentWidth : parentWidth;
    double selectedItemOriLeft = selectedPos * (widget.itemMargin + widget.itemWidth);
    var offset = scrollController.offset;
    double itemLeft = selectedItemOriLeft - offset;
    double itemCenter = width / 2 - itemLeft - widget.itemWidth / 2;
    double realNeedScrollDistance = 0;
    if (itemCenter < 0) {
      double canToLeftMaxScroll = contentWidth - width;
      double canToLeftScroll = canToLeftMaxScroll - offset;
      realNeedScrollDistance = canToLeftScroll < itemCenter.abs() ? -canToLeftScroll : itemCenter;
    } else {
      // 向右边滚动
      double canToRightScroll = offset;
      realNeedScrollDistance = canToRightScroll < itemCenter.abs() ? canToRightScroll : itemCenter;
    }
    scrollController.animateTo(
      offset - realNeedScrollDistance,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }
}

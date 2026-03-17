import 'package:flutter/material.dart';

class VerticalNestedScrollWidget extends StatelessWidget {
  const VerticalNestedScrollWidget({
    Key? key,
    required this.expandedHeight,
    required this.headerWidget,
    required this.bodyWidget,
  }) : super(key: key);

  final double expandedHeight;
  final Widget headerWidget;
  final Widget bodyWidget;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              forceElevated: innerBoxIsScrolled,
              // 收起的过渡颜色
              backgroundColor: Colors.transparent,

              /// SliverAppBar  pinned 表示SliverAppBar/flexibleSpace的title 是否跟着一起滑动到不可见（true 钉住，不滑动到不可见）
              title: const SizedBox(),
              leading: const SizedBox(),
              pinned: true,
              floating: true,
              expandedHeight: expandedHeight,
              collapsedHeight: 0,
              toolbarHeight: 0,
              flexibleSpace: FlexibleSpaceBar(
                /// 覆盖滚动效果/并联滚动效果/覆盖滚动视觉差
                collapseMode: CollapseMode.pin,
                background: headerWidget,
              ),
            ),
          )
        ];
      },
      body: Builder(builder: (BuildContext context) {
        return CustomScrollView(
          slivers: <Widget>[
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            bodyWidget,
          ],
        );
      }),
    );
  }
}

class SliverFixedExtentListView extends StatelessWidget {
  const SliverFixedExtentListView({
    super.key,
    required this.listItemBuilder,
    required this.listDataSize,
    required this.itemWidgetHeight,
  });

  final NullableIndexedWidgetBuilder listItemBuilder;
  final int listDataSize;
  final double itemWidgetHeight;

  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          return listItemBuilder(ctx, index);
        },
        childCount: listDataSize,
      ),
      itemExtent: itemWidgetHeight, //height
    );
  }
}

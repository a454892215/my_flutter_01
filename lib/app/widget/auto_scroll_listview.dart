import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'auto_scroll.dart';

typedef ItemBuilder = Widget? Function(BuildContext context, int index);

class AutoScrollListView extends StatefulWidget {
  const AutoScrollListView({
    super.key,
    required this.rxList,
    required this.itemBuilder,
    required this.controller,
  });

  final RxList rxList;
  final ItemBuilder itemBuilder;
  final AutoScrollListViewController controller;

  @override
  State<StatefulWidget> createState() {
    return MyState();
  }
}

class MyState extends State<AutoScrollListView> with TickerProviderStateMixin {
  late final AutoScrollUtil autoScrollUtil = AutoScrollUtil(scrollSpeed: 1, vsync: this);

  @override
  void dispose() {
    autoScrollUtil.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var length = widget.rxList.length;
      return Listener(
        onPointerDown: (e) {
          widget.controller.isStopScroll.value = true;
        },
        onPointerUp: (e) async {
          widget.controller.isStopScroll.value = false;
        },
        child: Obx(() {
          var isStopAutoScroll = widget.controller.isStopScroll.value;
          var scrollController = isStopAutoScroll ? ScrollController(initialScrollOffset: autoScrollUtil.curScrolledDistance) : autoScrollUtil.sc;
          return ListView.builder(
            // 无限循环
            itemCount: length > 0 ? 999999 : 0,

            controller: scrollController,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              final itemIndex = index % length;
              return widget.itemBuilder(context, itemIndex);
            },
          );
        }),
      );
    });
  }
}

class AutoScrollListViewController {
  final isStopScroll = false.obs;

  void stopScroll() {
    isStopScroll.value = true;
  }

  void startScroll() {
    isStopScroll.value = false;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../util/Log.dart';

typedef ItemBuilder = Widget? Function(BuildContext context, int index);

class AutoScrollListViewController {
  final isStopScroll = false.obs;
  void stopScroll() => isStopScroll.value = true;
  void startScroll() => isStopScroll.value = false;
}

class AutoScrollUtil {
  final ScrollController sc;
  double scrollSpeed; // 这里的单位是：像素/秒
  late final Ticker _ticker;

  bool _isPaused = false;
  Duration _lastElapsed = Duration.zero;

  AutoScrollUtil({
    required this.sc,
    required TickerProvider vsync,
    this.scrollSpeed = 50.0, // 默认每秒滚动 50 像素
  }) {
    // 类似于 Choreographer 的回调
    _ticker = vsync.createTicker(_onTick);
    _ticker.start();
  }

  // 增加动态更新速度的方法
  void updateSpeed(double newSpeed) {
    scrollSpeed = newSpeed;
  }

  void _onTick(Duration elapsed) {
    Log.d("_onTick: elapsed:$elapsed offset: ${sc.offset}");
    if (_isPaused) {
      _lastElapsed = Duration.zero;
      return;
    }

    // 计算两帧之间的时间差，实现平滑移动
    if (_lastElapsed != Duration.zero) {
      final double deltaTime =
          (elapsed.inMicroseconds - _lastElapsed.inMicroseconds) / 1000000.0;
      final double step = scrollSpeed * deltaTime;

      if (sc.hasClients && sc.position.hasContentDimensions) {
        // 使用 jumpTo 避免动画竞争
        sc.jumpTo(sc.offset + step);
      }
    }
    _lastElapsed = elapsed;
  }

  void pause() => _isPaused = true;

  void resume() => _isPaused = false;

  void dispose() {
    _ticker.dispose();
  }
}

/// AutoScrollListView
///
/// 一个高性能的、支持手势干预的无限循环自动滚动列表容器。
///
/// 核心特性：
/// 1. [Ticker-Based]: 基于 Flutter Ticker 实现像素级平滑滚动，类似 Android Choreographer。
/// 2. [Frame-Independent]: 引入 Delta Time 计算，确保 60Hz/120Hz 屏幕下滚动速度一致。
/// 3. [Gesture-Aware]: 自动处理用户触摸暂停与离开恢复逻辑。
/// 4. [Decoupled]: 不耦合具体数据源，仅需传入 [itemCount] 和 [itemBuilder]。
/// 5. [Infinite-Loop]: 内部封装索引取模逻辑，实现内容无限循环。
class AutoScrollListView extends StatefulWidget {
  const AutoScrollListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.controller,
    this.scrollSpeed = 50.0,
    this.scrollDirection = Axis.vertical,
  });

  final int itemCount;
  final ItemBuilder itemBuilder;
  final AutoScrollListViewController controller;
  final double scrollSpeed;
  final Axis scrollDirection;

  @override
  State<AutoScrollListView> createState() => _AutoScrollListViewState();
}

class _AutoScrollListViewState extends State<AutoScrollListView> with TickerProviderStateMixin {
  late ScrollController _mainScrollController;
  late AutoScrollUtil _autoScrollUtil;

  @override
  void initState() {
    super.initState();
    _mainScrollController = ScrollController();
    _initUtil();
  }

  void _initUtil() {
    _autoScrollUtil = AutoScrollUtil(
      sc: _mainScrollController,
      vsync: this,
      scrollSpeed: widget.scrollSpeed,
    );
  }

  // 🌟 关键补全：处理外部参数更新
  @override
  void didUpdateWidget(AutoScrollListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果外部动态修改了速度，更新 Util 内部速度
    if (oldWidget.scrollSpeed != widget.scrollSpeed) {
      _autoScrollUtil.updateSpeed(widget.scrollSpeed);
    }
    // 如果 itemCount 变化，可能需要重置当前 offset 以防计算溢出（可选）
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _autoScrollUtil.dispose();
    super.dispose();
  }

  void _handlePointerUp(PointerEvent e) {
    _autoScrollUtil.resume();
    widget.controller.startScroll();
  }

  void _handlePointerDown(PointerDownEvent e) {
    _autoScrollUtil.pause();
    widget.controller.stopScroll();
  }

  @override
  Widget build(BuildContext context) {
    // 严谨的空检查，Android 习惯：先判断无效状态
    if (widget.itemCount <= 0) return const SizedBox.shrink();

    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerUp,
      behavior: HitTestBehavior.translucent,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        controller: _mainScrollController,
        scrollDirection: widget.scrollDirection,
        // 999999 对 Ticker 来说绰绰有余
        itemCount: 999999,
        // 🌟 性能：设置 cacheExtent 减少边缘 Item 创建时的跳动
        cacheExtent: 300,
        itemBuilder: (context, index) {
          // 这里使用最新的 widget.itemCount
          final realIndex = index % widget.itemCount;
          return widget.itemBuilder(context, realIndex);
        },
      ),
    );
  }
}
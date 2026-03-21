import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../util/Log.dart';

typedef ItemBuilder = Widget? Function(BuildContext context, int index);

class AutoScrollListViewController {
  final isStopScroll = false.obs;
  void stopScroll() => isStopScroll.value = true;
  void startScroll() => isStopScroll.value = false;
}

class AutoScrollUtil {
  final ScrollController sc;
  double scrollSpeed; // 单位：像素/秒
  late final Ticker _ticker;

  bool _isPaused = false;
  Duration _lastElapsed = Duration.zero;

  AutoScrollUtil({
    required this.sc,
    required TickerProvider vsync,
    this.scrollSpeed = 50.0,
  }) {
    _ticker = vsync.createTicker(_onTick);
    _ticker.start();
  }

  void updateSpeed(double newSpeed) {
    scrollSpeed = newSpeed;
  }

  void _onTick(Duration elapsed) {
    // 如果被暂停（手势按下、页面不可见、App后台），直接 Return，不触发 jumpTo
    if (_isPaused) {
      _lastElapsed = Duration.zero;
      return;
    }
    Log.dt("elapsed:$elapsed sc:${sc.offset}");
    if (_lastElapsed != Duration.zero) {
      final double deltaTime =
          (elapsed.inMicroseconds - _lastElapsed.inMicroseconds) / 1000000.0;
      final double step = scrollSpeed * deltaTime;

      if (sc.hasClients && sc.position.hasContentDimensions) {
        // 核心：仅在有 Client 且未暂停时执行位移，类似 Android Choreographer postFrameCallback
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
/// 2. [Frame-Independent]: 引入 Delta Time 计算，确保滚动速度不受屏幕刷新率影响。
/// 3. [Gesture-Aware]: 自动处理用户触摸暂停与离开恢复逻辑。
/// 4. [Visibility-Aware]: 集成 VisibilityDetector，当在 PageView 中滑出屏幕或 App 切到后台时自动停止滚动，节省资源。
/// 5. [Infinite-Loop]: 内部封装索引取模逻辑，配合超大 itemCount 实现视觉上的无限循环。
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

class _AutoScrollListViewState extends State<AutoScrollListView>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  late ScrollController _mainScrollController;
  late AutoScrollUtil _autoScrollUtil;

  // 内部状态标记
  bool _isPageVisible = true;
  bool _isFingerDown = false;

  @override
  void initState() {
    super.initState();
    // 注册系统生命周期观察者（类似 Activity 生命周期）
    WidgetsBinding.instance.addObserver(this);
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 当 App 退到后台（Home键），强制暂停 Ticker 逻辑
    if (state == AppLifecycleState.paused) {
      _autoScrollUtil.pause();
    } else if (state == AppLifecycleState.resumed) {
      // 回到前台时，如果页面本身可见且手指没按住，则恢复
      _checkAndResume();
    }
  }

  @override
  void didUpdateWidget(AutoScrollListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollSpeed != widget.scrollSpeed) {
      _autoScrollUtil.updateSpeed(widget.scrollSpeed);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mainScrollController.dispose();
    _autoScrollUtil.dispose();
    super.dispose();
  }

  // 统一的恢复判断逻辑
  void _checkAndResume() {
    if (_isPageVisible && !_isFingerDown) {
      _autoScrollUtil.resume();
      widget.controller.startScroll();
    }
  }

  // 手势处理：按下停止
  void _handlePointerDown(PointerDownEvent e) {
    _isFingerDown = true;
    _autoScrollUtil.pause();
    widget.controller.stopScroll();
  }

  // 手势处理：抬起/取消恢复
  void _handlePointerUp(PointerEvent e) {
    _isFingerDown = false;
    _checkAndResume();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount <= 0) return const SizedBox.shrink();

    return VisibilityDetector(
      // 这里的 Key 必须唯一，建议使用 identityHashCode 或 ObjectKey
      key: ObjectKey(this),
      onVisibilityChanged: (info) {
        // 核心优化：感知 PageView 切页
        if (info.visibleFraction <= 0) {
          _isPageVisible = false;
          _autoScrollUtil.pause();
          Log.d("AutoScroll: 页面不可见，已停止滚动计算");
        } else {
          _isPageVisible = true;
          _checkAndResume();
          Log.d("AutoScroll: 页面进入视野，恢复滚动");
        }
      },
      child: Listener(
        onPointerDown: _handlePointerDown,
        onPointerUp: _handlePointerUp,
        onPointerCancel: _handlePointerUp,
        behavior: HitTestBehavior.translucent,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          controller: _mainScrollController,
          scrollDirection: widget.scrollDirection,
          itemCount: 999999,
          cacheExtent: 300,
          itemBuilder: (context, index) {
            final realIndex = index % widget.itemCount;
            return widget.itemBuilder(context, realIndex);
          },
        ),
      ),
    );
  }
}
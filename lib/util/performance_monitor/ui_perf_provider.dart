import 'dart:collection';
import 'dart:ui';
import 'package:flutter/scheduler.dart';

/// UI 渲染单帧性能指标快照
class UIRenderMetrics {
  /// UI 线程耗时 (Build, Layout, Paint): 对应 Dart 代码执行时间
  final double uiDurationMs;

  /// Raster 线程耗时 (GPU 渲染): 对应引擎将 Layer 转换为像素的时间
  final double rasterDurationMs;

  /// 单帧总耗时 (uiDuration + rasterDuration)
  final double totalDurationMs;

  /// 是否发生掉帧 (Jank): 总耗时是否超过了当前设备的刷新周期
  final bool isJank;

  /// 帧产生的时间戳
  final DateTime timestamp;

  UIRenderMetrics({
    required this.uiDurationMs,
    required this.rasterDurationMs,
    required this.totalDurationMs,
    required this.isJank,
    required this.timestamp,
  });
}

/// UI 渲染性能指标提供者 (UI Rendering Performance Provider)
/// 核心职责：实时监控并提供 UI 线程与 Raster 线程的渲染耗时及掉帧率
class UIRenderPerfProvider {
  // 单例模式，确保全局只有一个渲染监听器
  static final UIRenderPerfProvider _instance = UIRenderPerfProvider._internal();
  factory UIRenderPerfProvider() => _instance;
  UIRenderPerfProvider._internal();

  // 采样滑动窗口大小 (默认保存最近 60 帧的数据)
  final int _maxWindowSize = 60;
  final ListQueue<UIRenderMetrics> _metricsWindow = ListQueue();

  // 外部监听器集合
  final Set<Function(UIRenderMetrics)> _listeners = {};

  bool _isMonitoring = false;

  /// 启动 UI 渲染性能监控
  /// 在 Debug, Profile, Release 模式下均有效
  void start() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    // 注册帧耗时回调。这是 Flutter Engine 暴露的最底层的渲染耗时接口
    SchedulerBinding.instance.addTimingsCallback(_handleFrameTimings);
  }

  /// 停止监控并清空缓存数据
  void stop() {
    _isMonitoring = false;
    SchedulerBinding.instance.removeTimingsCallback(_handleFrameTimings);
    _metricsWindow.clear();
  }

  /// 注册监听，当每一帧渲染完成时会收到通知
  void addListener(Function(UIRenderMetrics) listener) => _listeners.add(listener);

  /// 移除监听
  void removeListener(Function(UIRenderMetrics) listener) => _listeners.remove(listener);

  /// 内部处理逻辑：将原始 FrameTiming 转换为业务指标 UIRenderMetrics
  void _handleFrameTimings(List<FrameTiming> timings) {
    // 动态获取设备刷新率 (如 60, 90, 120Hz)
    // 如果获取失败，保守估计按 60Hz 处理
    final double refreshRate = PlatformDispatcher.instance.views.first.display.refreshRate;
    final double vsyncThresholdMs = 1000.0 / (refreshRate > 0 ? refreshRate : 60.0);

    for (var timing in timings) {
      // 耗时计算：微秒(us) -> 毫秒(ms)
      // buildDuration: UI Thread (Dart)
      final double uiMs = timing.buildDuration.inMicroseconds / 1000.0;
      // rasterDuration: Raster Thread (GPU/Engine)
      final double rasterMs = timing.rasterDuration.inMicroseconds / 1000.0;
      final double totalMs = timing.totalSpan.inMicroseconds / 1000.0;

      final metrics = UIRenderMetrics(
        uiDurationMs: uiMs,
        rasterDurationMs: rasterMs,
        totalDurationMs: totalMs,
        // 关键逻辑：如果总耗时超过了 VSync 周期，则判定为一次掉帧 (Jank)
        isJank: totalMs > vsyncThresholdMs,
        timestamp: DateTime.now(),
      );

      // 维护滑动窗口，保证内存不溢出
      if (_metricsWindow.length >= _maxWindowSize) {
        _metricsWindow.removeFirst();
      }
      _metricsWindow.addLast(metrics);

      // 同步回调给所有观察者
      for (var listener in _listeners) {
        listener(metrics);
      }
    }
  }

  // --- 辅助工具方法 ---

  /// 获取当前滑动窗口内的平均 UI 线程耗时
  double get averageUiDuration {
    if (_metricsWindow.isEmpty) return 0.0;
    return _metricsWindow.map((e) => e.uiDurationMs).reduce((a, b) => a + b) / _metricsWindow.length;
  }

  /// 获取当前滑动窗口内的平均 Raster 线程耗时
  double get averageRasterDuration {
    if (_metricsWindow.isEmpty) return 0.0;
    return _metricsWindow.map((e) => e.rasterDurationMs).reduce((a, b) => a + b) / _metricsWindow.length;
  }

  /// 获取当前窗口内的掉帧率 (0.0 表示完美，1.0 表示每一帧都卡顿)
  double get currentJankRate {
    if (_metricsWindow.isEmpty) return 0.0;
    int jankCount = _metricsWindow.where((e) => e.isJank).length;
    return jankCount / _metricsWindow.length;
  }

  /// 获取设备的物理刷新率
  double get deviceRefreshRate => PlatformDispatcher.instance.views.first.display.refreshRate;

  /// 获取滑动窗口中所有原始数据（可用于绘制曲线图）
  List<UIRenderMetrics> get getHistory => _metricsWindow.toList();
}
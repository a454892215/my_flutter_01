import 'dart:collection';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// 导入 foundation 以便使用 kReleaseMode 或类似判断，如果不需要可以移除
/// 这个工具类可以精确的实时监控 当前flutter UI的性能情况吗？优化代码的时候 不要删除任何注释
/// UI 渲染单帧性能指标快照
class UIRenderMetrics {
  /// UI 线程耗时 (Build, Layout, Paint): 对应 Dart 代码执行时间
  double uiDurationMs;

  /// Raster 线程耗时 (GPU 渲染): 对应引擎将 Layer 转换为像素的时间
  double rasterDurationMs;

  /// 单帧总耗时 (uiDuration + rasterDuration)
  double totalDurationMs;

  /// 是否发生掉帧 (Jank): 总耗时是否超过了当前设备的刷新周期
  bool isJank;

  double? refreshRate;
  double? vsyncThresholdMs;

  UIRenderMetrics({
    /// UI 线程耗时 (Build, Layout, Paint): 对应 Dart 代码执行时间
    ///
    /// [定义]: UI Isolate 在被 VSync 信号唤醒后，执行一次完整“渲染流水线” (Rendering Pipeline) 的同步耗时。
    /// 包含: 动画(Animate)、构建(Build)、布局(Layout)、绘制指令录制(Paint)。
    ///
    /// [注意]:
    /// 1. 此指标仅记录 UI 线程任务，不包含 Raster (GPU) 线程耗时。
    /// 2. 必须在 Profile 或 Release 模式下评估，Debug 模式因 JIT 编译会导致数值异常偏大。
    /// 3. 如果 UI 线程被非渲染任务(如复杂计算)阻塞，会导致 VSync 延迟处理，此值可能表现正常但 totalSpan 会激增。
    /// totalSpan：指从 VSync 信号唤醒 UI 线程起，直到 Raster 线程完成渲染并通知系统显示（第 N 帧任务结束）的总物理时间跨度
    /// [性能基准参照表]:
    /// 屏幕刷新率 | VSync 周期 | 性能优异 (Green) | 性能一般 (Yellow) | 性能危险 (Red)
    /// -----------------------------------------------------------------------
    ///   60Hz    |   16.6ms   |      < 8ms      |    8ms ~ 13ms   |    > 14ms
    ///   90Hz    |   11.1ms   |      < 5ms      |    5ms ~ 8ms    |    > 9ms
    ///   120Hz   |   8.3ms    |      < 4ms      |    4ms ~ 6ms    |    > 7ms
    required this.uiDurationMs,

    /// Raster 线程耗时 (GPU 渲染): 对应引擎将 Layer 转换为像素的时间
    ///
    /// [定义]: Raster 线程（原 GPU 线程）将 UI 线程生成的图层树 (Layer Tree) 转换为 GPU 指令，
    /// 并最终由 GPU 完成像素填充的时间。包含：着色器编译 (Shader Compilation)、纹理上传、Skia/Impeller 渲染。
    ///
    /// [注意]:
    /// 1. **着色器编译预热**: 第一次进入某个页面发生的 Raster 耗时激增通常是因为 Shader 编译，建议使用 Impeller (iOS/Android) 缓解。
    /// 2. **离屏渲染**: 频繁使用 Opacity (非 0/1)、Clip.antiAlias、SaveLayer 等会导致 Raster 耗时翻倍。
    /// 3. **GPU 瓶颈**: 若 UI 耗时低但 Raster 耗时持续走高，说明 UI 结构过于复杂或图片分辨率过大。
    /// 4. **异步性**: Raster 线程通常滞后 UI 线程一帧执行 (Pipelining)。
    ///
    /// [性能基准参照表]: (同 UI 线程，需严格控制在 VSync 周期内)
    ///   60Hz    |   16.6ms   |      < 8ms      |    8ms ~ 13ms   |    > 14ms
    ///   UI 线程是生产者 Raster 线程是消费者，如果Raster 线程压力过大，导致不能及时处理UI线程的绘制需求，也会导致UI卡顿的
    ///   如果Raster 线程不能及时处理UI线程产生的渲染任务，UI线程机会积累任务，积累到一定程度，就会丢弃任务，必然导致卡顿
    ///   Flutter 默认的 Pipeline 深度通常为 2。如果 Raster 线程落后 UI 线程超过 2 帧，UI 线程在尝试提交新帧时会被阻塞
    required this.rasterDurationMs,
    required this.totalDurationMs,
    required this.isJank,
    this.refreshRate,
    this.vsyncThresholdMs,
  });

  String getBaseInfo() {
    return "${refreshRate?.toStringAsFixed(0)}:${vsyncThresholdMs?.toStringAsFixed(1)}:${totalDurationMs.toStringAsFixed(1)}";
  }

  String getStateMark() {
    return isJank ? "No" : "OK";
  }

  Color getStateColor() {
    return isJank ? Colors.red : Colors.green;
  }

  void update({
    required double uiDurationMs,
    required double rasterDurationMs,
    required double totalDurationMs,
    required bool isJank,
    required double refreshRate,
    required double vsyncThresholdMs,
  }) {
    this.uiDurationMs = uiDurationMs;
    this.rasterDurationMs = rasterDurationMs;
    this.totalDurationMs = totalDurationMs;
    this.isJank = isJank;
    this.refreshRate = refreshRate;
    this.vsyncThresholdMs = vsyncThresholdMs;
  }
}

/// UI 渲染性能指标提供者 (UI Rendering Performance Provider)
/// 核心职责：实时监控并提供 UI 线程与 Raster 线程的渲染耗时及掉帧率
class UIRenderPerfProvider {
  // 单例模式
  static final UIRenderPerfProvider _instance = UIRenderPerfProvider._internal();

  factory UIRenderPerfProvider() => _instance;

  UIRenderPerfProvider._internal();

  // 采样滑动窗口大小
  final int _maxWindowSize = 60;
  final ListQueue<UIRenderMetrics> _metricsWindow = ListQueue();

  bool _isMonitoring = false;
  double vsyncThresholdMs = 17;

  /// 启动 UI 渲染性能监控
  void start() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _metricsWindow.clear();

    /// 注册帧耗时回调
    /// lutter 引擎为了减少 Dart 与 Native 层的通信开销（Context Switch），会将多帧的 FrameTiming 数据攒在一起，在一个微任务（Microtask）
    /// 中批量回调,如果屏幕完全静止（没有动画，没有手势，没有输入），Flutter 不会触发重绘，也就不会产生 FrameTiming，此时该方法调用次数为 0
    SchedulerBinding.instance.addTimingsCallback(_handleFrameTimings);
  }

  /// 停止监控并清空缓存数据
  void stop() {
    if (!_isMonitoring) return; // 修改点 2: 增加防御性判断
    _isMonitoring = false;
    SchedulerBinding.instance.removeTimingsCallback(_handleFrameTimings);
    _metricsWindow.clear();
  }

  /// 内部处理逻辑
  void _handleFrameTimings(List<FrameTiming> timings) {
    if (!_isMonitoring) return; // 修改点 3: 异步回调安全检查
    final double refreshRate = deviceRefreshRate;
    // 增加 1ms 容差，防止因极微小波动导致的误判 (类似 Android VSync 的对齐策略)
    final double vsyncThresholdMs = 1000.0 / (refreshRate > 0 ? refreshRate : 60.0) + 1.0;
    this.vsyncThresholdMs = vsyncThresholdMs;
    for (var timing in timings) {
      // 耗时计算：使用 .inMicroseconds / 1000.0 是准确的
      final double uiMs = timing.buildDuration.inMicroseconds / 1000.0;
      final double rasterMs = timing.rasterDuration.inMicroseconds / 1000.0;

      // 修改点 5: 性能计算修正。totalSpan 包含了两帧之间的空闲时间，
      // 用于判断 Jank 时，应使用实际工作耗时之和：buildDuration + rasterDuration
      // 或者根据业务需求决定是否包含 vsync 等待。
      final double actualWorkMs = uiMs + rasterMs;
      final UIRenderMetrics newUIRenderMetrics;
      // 维护滑动窗口
      if (_metricsWindow.length >= _maxWindowSize) {
        UIRenderMetrics old = _metricsWindow.removeFirst();
        old.update(
          uiDurationMs: uiMs,
          rasterDurationMs: rasterMs,
          totalDurationMs: actualWorkMs,
          isJank: actualWorkMs > vsyncThresholdMs,
          refreshRate: refreshRate,
          vsyncThresholdMs: vsyncThresholdMs,
        );
        newUIRenderMetrics = old;
      } else {
        newUIRenderMetrics = UIRenderMetrics(
          uiDurationMs: uiMs,
          rasterDurationMs: rasterMs,
          totalDurationMs: actualWorkMs,
          isJank: actualWorkMs > vsyncThresholdMs,
          refreshRate: refreshRate,
          vsyncThresholdMs: vsyncThresholdMs,
        );
      }
      _metricsWindow.addLast(newUIRenderMetrics);
    }
  }

  double get averageUiDuration {
    if (_metricsWindow.isEmpty) return 0.0;
    // 修改点 7: 使用 fold 代替 map+reduce 减少中间集合产生，优化性能
    final double total = _metricsWindow.fold(0.0, (prev, e) => prev + e.uiDurationMs);
    return total / _metricsWindow.length;
  }

  double get averageRasterDuration {
    if (_metricsWindow.isEmpty) return 0.0;
    final double total = _metricsWindow.fold(0.0, (prev, e) => prev + e.rasterDurationMs);
    return total / _metricsWindow.length;
  }

  double get currentJankRate {
    if (_metricsWindow.isEmpty) return 0.0;
    int jankCount = 0;
    for (var m in _metricsWindow) {
      if (m.isJank) jankCount++;
    }
    return jankCount / _metricsWindow.length;
  }

  /// 获取设备的物理刷新率
  double get deviceRefreshRate {
    try {
      return PlatformDispatcher.instance.views.first.display.refreshRate;
    } catch (_) {
      return 60.0;
    }
  }

  // 在 UIRenderPerfProvider 内部维护一个单例级的聚合对象
  final UIRenderMetrics _internalAverage = UIRenderMetrics(uiDurationMs: 0, rasterDurationMs: 0, totalDurationMs: 0, isJank: false);

  UIRenderMetrics getAveUIRenderMetrics() {
    final uiDurationMs = averageUiDuration;
    final rasterDurationMs = averageRasterDuration;
    final totalDurationMs = uiDurationMs + rasterDurationMs;
    final vsyncThresholdMs = this.vsyncThresholdMs;

    _internalAverage.update(
      uiDurationMs: uiDurationMs,
      rasterDurationMs: rasterDurationMs,
      totalDurationMs: totalDurationMs,
      isJank: totalDurationMs > vsyncThresholdMs,
      refreshRate: deviceRefreshRate,
      vsyncThresholdMs: vsyncThresholdMs,
    );
    return _internalAverage;
  }
}

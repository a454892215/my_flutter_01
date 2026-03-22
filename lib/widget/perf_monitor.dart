import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 性能监控工具类
class PerfMonitor {
  static OverlayEntry? _entry;

  /// 启动性能监控悬浮窗
  static void start(BuildContext context) {
    if (_entry != null || kReleaseMode) return;

    _entry = OverlayEntry(
      builder: (context) {
        // 关键：这里不再包裹 Positioned，由组件内部控制位置
        return const PerfMonitorWidget();
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  /// 停止性能监控
  static void stop() {
    _entry?.remove();
    _entry = null;
  }
}

/// 内部自定义的悬浮窗 Widget
class PerfMonitorWidget extends StatefulWidget {
  const PerfMonitorWidget({super.key});

  @override
  State<PerfMonitorWidget> createState() => _PerfMonitorWidgetState();
}

class _PerfMonitorWidgetState extends State<PerfMonitorWidget> {
  // --- 性能数据变量 ---
  final int _sampleSize = 60;
  final ListQueue<FrameTiming> _timingsWindow = ListQueue();
  double _fps = 0.0;
  bool _isBuildSlow = false;
  bool _isRasterSlow = false;
  String _memoryUsage = "0 MB";
  Timer? _memoryTimer;

  // --- 拖拽位置变量 ---
  // 初始位置：dx 为距离左侧距离，dy 为距离顶部距离
  Offset _offset = const Offset(20, 100);
  final double _widgetWidth = 120.0;
  // 预估高度，用于边界计算
  final double _widgetHeight = 90.0;

  @override
  void initState() {
    super.initState();
    // 1. 监听帧耗时
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);

    // 2. 定时获取内存
    _updateMemoryUsage();
    _memoryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateMemoryUsage();
    });
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _memoryTimer?.cancel();
    super.dispose();
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    if (!mounted) return;

    for (var timing in timings) {
      _timingsWindow.addLast(timing);
      if (_timingsWindow.length > _sampleSize) {
        _timingsWindow.removeFirst();
      }
    }

    if (_timingsWindow.isEmpty) return;

    int totalDurationUs = 0;
    for (var timing in _timingsWindow) {
      totalDurationUs += timing.totalSpan.inMicroseconds;
    }

    final double avgDurationMs = (totalDurationUs / _timingsWindow.length) / 1000.0;
    double calculatedFps = avgDurationMs > 0 ? 1000.0 / avgDurationMs : 0;

    final lastTiming = _timingsWindow.last;
    setState(() {
      _fps = calculatedFps > 120 ? 0 : calculatedFps; // 过滤异常值
      _isBuildSlow = lastTiming.buildDuration.inMilliseconds > 16;
      _isRasterSlow = lastTiming.rasterDuration.inMilliseconds > 16;
    });
  }

  void _updateMemoryUsage() {
    if (!mounted) return;
    try {
      int rss = ProcessInfo.currentRss;
      double rssMb = rss / (1024 * 1024);
      setState(() {
        _memoryUsage = "${rssMb.toStringAsFixed(1)} MB";
      });
    } catch (e) {
      setState(() { _memoryUsage = "N/A"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // 使用 Positioned 结合 _offset 实现自由定位
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            // 累加位移
            _offset += details.delta;

            // 边界检查：不超出屏幕，避开状态栏和底部操作区
            double x = _offset.dx.clamp(0.0, screenSize.width - _widgetWidth);
            double y = _offset.dy.clamp(padding.top, screenSize.height - padding.bottom - _widgetHeight);

            _offset = Offset(x, y);
          });
        },
        child: Material(
          elevation: 8,
          color: Colors.transparent,
          child: Container(
            width: _widgetWidth,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PERF TRACE",
                  style: TextStyle(color: Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                _buildInfoRow("FPS", _fps.toStringAsFixed(1),
                    valueColor: _fps < 55 ? Colors.redAccent : Colors.greenAccent),
                _buildInfoRow("MEM", _memoryUsage),
                const Divider(color: Colors.white12, height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusIndicator("UI", _isBuildSlow),
                    _buildStatusIndicator("GPU", _isRasterSlow),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color valueColor = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'monospace')),
          Text(value, style: TextStyle(color: valueColor, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool isSlow) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSlow ? Colors.red : Colors.green,
              boxShadow: [
                if (!isSlow) BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 4)
              ]
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }
}
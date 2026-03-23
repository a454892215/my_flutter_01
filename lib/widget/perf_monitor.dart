import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PerfMonitor {
  static OverlayEntry? _entry;

  static void start(BuildContext context) {
    if (_entry != null || kReleaseMode) return;
    _entry = OverlayEntry(builder: (context) => const PerfMonitorWidget());
    Overlay.of(context).insert(_entry!);
  }

  static void stop() {
    _entry?.remove();
    _entry = null;
  }
}

class PerfMonitorWidget extends StatefulWidget {
  const PerfMonitorWidget({super.key});

  @override
  State<PerfMonitorWidget> createState() => _PerfMonitorWidgetState();
}

class _PerfMonitorWidgetState extends State<PerfMonitorWidget> {
  // 样本窗口大小，25帧足以覆盖高刷屏的一个微小周期
  final int _sampleSize = 25;
  final ListQueue<FrameTiming> _timingsWindow = ListQueue();

  double _fps = 60.0;
  bool _isBuildSlow = false;
  bool _isRasterSlow = false;
  String _memoryUsage = "0 MB";
  Timer? _timer;

  Offset _offset = const Offset(20, 100);
  final double _widgetWidth = 130.0;
  final double _widgetHeight = 100.0;

  @override
  void initState() {
    super.initState();
    // 注册帧耗时回调
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);

    // 每一秒更新一次非高频数据
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateMemoryUsage();

      // 逻辑统一：如果长时间没有新帧，说明 UI 静止且极其流畅，显示设备物理刷新率
      if (_timingsWindow.isEmpty) {
        setState(() {
          _fps = _getDeviceRefreshRate();
        });
      }
    });
  }

  double _getDeviceRefreshRate() {
    // 获取当前窗口的物理刷新率
    return PlatformDispatcher.instance.views.first.display.refreshRate;
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _timer?.cancel();
    super.dispose();
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    if (!mounted) return;

    // 1. 更新滑动窗口数据
    for (var timing in timings) {
      _timingsWindow.addLast(timing);
      if (_timingsWindow.length > _sampleSize) {
        _timingsWindow.removeFirst();
      }
    }

    if (_timingsWindow.isEmpty) return;

    // 2. 混合算法计算 FPS
    // 计算平均耗时 (反映体感整体趋势)
    double avgUs = _timingsWindow.fold(0.0, (sum, t) => sum + t.totalSpan.inMicroseconds) / _timingsWindow.length;

    // 计算最差一帧耗时 (反映 Jank/掉帧)
    int maxUs = _timingsWindow.map((t) => t.totalSpan.inMicroseconds).reduce((a, b) => a > b ? a : b);

    // 混合权重：70% 平均 + 30% 最差。这能防止数值因为单帧抖动而剧烈跳变，
    // 但又能捕捉到页面切换时的明显卡顿。
    double blendedMs = (avgUs * 0.7 + maxUs * 0.3) / 1000.0;
    double currentFps = 1000.0 / blendedMs;

    double deviceMax = _getDeviceRefreshRate();
    if (currentFps > deviceMax) currentFps = deviceMax;

    final lastTiming = _timingsWindow.last;

    setState(() {
      _fps = currentFps;
      // 判定阈值：如果耗时超过“1帧应有的时间”，则认为该环节慢
      double frameBudget = 1000 / deviceMax;
      _isBuildSlow = lastTiming.buildDuration.inMilliseconds > frameBudget;
      _isRasterSlow = lastTiming.rasterDuration.inMilliseconds > frameBudget;
    });

    // 注意：不要在这里调用 clear()，保持窗口滑动
  }

  void _updateMemoryUsage() {
    if (!mounted) return;
    try {
      // 获取 RSS (Resident Set Size) - 对应 Android 的 Total Memory
      double rssMb = ProcessInfo.currentRss / (1024 * 1024);
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
    final refreshRate = _getDeviceRefreshRate();

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
            _offset = Offset(
              _offset.dx.clamp(0.0, screenSize.width - _widgetWidth),
              _offset.dy.clamp(padding.top, screenSize.height - padding.bottom - _widgetHeight),
            );
          });
        },
        child: Material(
          elevation: 10,
          color: Colors.transparent,
          child: Container(
            width: _widgetWidth,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PERF MONITOR",
                  style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  "FPS",
                  _fps.toStringAsFixed(1),
                  // 掉帧超过 10% 变黄，掉帧超过 25% 变红
                  valueColor: _fps < (refreshRate * 0.75)
                      ? Colors.redAccent
                      : (_fps < (refreshRate * 0.9) ? Colors.orangeAccent : Colors.greenAccent),
                ),
                _buildInfoRow("RSS", _memoryUsage),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: valueColor, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool isSlow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSlow ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isSlow ? Colors.red : Colors.greenAccent),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: isSlow ? Colors.redAccent : Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
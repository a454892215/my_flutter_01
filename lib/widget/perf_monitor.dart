import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'draggable_floating_widget.dart'; // 引入刚才定义的容器
/// flutter devTools 的memory监控中的关键指标及其含义
/// RSS(Resident Set Size):这是操作系统分配给该进程的实际物理内存总量.
///                        它包含了应用运行所需的所有资源：Dart堆内存、Flutter引擎内存、原生平台（Android/iOS）内存、加载的动态库、字体、以及正在解码的图片等
/// Allocated(已分配内存): 这是由 Dart VM 管理的内存总量, 表示 Dart 虚拟机当前占用的内存大小
/// Dart/Flutter：这是当前 Dart 代码中存活对象实际占用的空间。
///               对象类型： 包括你定义的 Widget 实例、State、Model 数据、各种 List、Map 等。
///               Dart/Flutter 必然小于或等于 Allocated。如果这两个值持续上升且不下降，通常意味着 Dart 层存在内存泄漏。
///Dart/Flutter Native（原生关联内存）: 这是指由 Dart 对象引用，但实际上在 C++ 层（原生层）分配的内存
///Raster Layer & Raster Picture（光栅化层与图片缓存）：这两个指标反映了 Flutter 渲染引擎（Raster Thread） 占用的显存/内存。
///               Raster Layer： 指合成渲染层（Layers）时消耗的内存。
///               Raster Picture： 指被缓存的绘制指令（Display Lists）或录制好的图片。
///当前 flutter sdk 版本：3.38.8， profile模式下 无法获取Dart/Flutter内存
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
  // 性能采样配置
  final int _sampleSize = 25;
  final ListQueue<FrameTiming> _timingsWindow = ListQueue();

  double _fps = 60.0;
  String _memoryUsage = "0 MB";
  Timer? _timer;
  double imageMb = 0;
  int cacheImageCount = 0;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateMemoryUsage();
      if (_timingsWindow.isEmpty) {
        setState(() => _fps = _getDeviceRefreshRate());
      }
    });
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _timer?.cancel();
    super.dispose();
  }

  double _getDeviceRefreshRate() => PlatformDispatcher.instance.views.first.display.refreshRate;

  /// 计算屏幕刷新率
  void _onFrameTimings(List<FrameTiming> timings) {
    if (!mounted) return;
    for (var timing in timings) {
      _timingsWindow.addLast(timing);
      if (_timingsWindow.length > _sampleSize) _timingsWindow.removeFirst();
    }
    if (_timingsWindow.isEmpty) return;

    double avgUs = _timingsWindow.fold(0.0, (sum, t) => sum + t.totalSpan.inMicroseconds) / _timingsWindow.length;
    int maxUs = _timingsWindow.map((t) => t.totalSpan.inMicroseconds).reduce((a, b) => a > b ? a : b);

    // 70% 平均 + 30% 最差帧混合算法，兼顾平滑与卡顿监测
    double blendedMs = (avgUs * 0.7 + maxUs * 0.3) / 1000.0;
    double currentFps = 1000.0 / blendedMs;
    double deviceMax = _getDeviceRefreshRate();

    setState(() {
      _fps = currentFps.clamp(0.0, deviceMax);
    });
  }

  /// 更新 rssMb 内存信息
  void _updateMemoryUsage() {
    if (!mounted) return;
    double rssMb = ProcessInfo.currentRss / (1024 * 1024);
    setState((){
      _memoryUsage = "${rssMb.toStringAsFixed(0)} MB";
      imageMb = PaintingBinding.instance.imageCache.currentSizeBytes / (1024 * 1024);
      cacheImageCount = PaintingBinding.instance.imageCache.currentSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final refreshRate = _getDeviceRefreshRate();

    // 使用抽取的包装容器
    return DraggableFloatingWidget(
      width: 110,
      height: 140,
      child: RepaintBoundary(
        child: Material(
          elevation: 10,
          color: Colors.transparent,
          child: Container(
            width: 110,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withAlpha(188),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("FPS", _fps.toStringAsFixed(0), color: _fps < (refreshRate * 0.8) ? Colors.redAccent : Colors.greenAccent),
                _buildInfoRow("RSS", _memoryUsage),
                _buildInfoRow("imageMb", imageMb.toStringAsFixed(1)),
                _buildInfoRow("imgCount", cacheImageCount.toStringAsFixed(0)),
                const Divider(color: Colors.white10, height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color color = Colors.white}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

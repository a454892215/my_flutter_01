import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_comm/util/performance_monitor/ui_perf_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../Log.dart';
import '../exe_timer.dart';
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
/// flutter sdk 版本：3.38.8
///       新建的空项目 RSS内存消耗情况：debug:354M,  profile:226M,  release:192
///当前项目（空页面首页RSS内存消耗情况）：debug:400M->430M,  profile:250M->275M,  release:212
/// flutter 正常的预热与碎片消耗 RSS (物理内存)波动范围是:	5% ~ 12%
class PerfMonitor {
  static OverlayEntry? _entry;

  static void start(BuildContext context) {
    if (_entry != null) return;
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
  String _memoryUsage = "0 MB";
  Timer? _timer;
  double imageMb = 0;
  int cacheImageCount = 0;

  late ExecutionTimer executionTimer;
  UIRenderMetrics? metrics;
  @override
  void initState() {
    super.initState();
    executionTimer = ExecutionTimer();
    UIRenderPerfProvider().start();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      executionTimer.start();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateInfo();
    });
    // 开启常亮
    WakelockPlus.enable();
    Log.d("=====性能监控组件初始化完毕======initState====");
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    executionTimer.stop();
    UIRenderPerfProvider().stop();
    super.dispose();
    WakelockPlus.disable();
    Log.d("=====性能监控组件被销毁？======dispose====");
  }

  void _updateInfo() {
    if (!mounted) return;
    double rssMb = ProcessInfo.currentRss / (1024 * 1024);
    // 这里的计算包含循环，属于 O(n) 操作，放在外部
    final currentMetrics = UIRenderPerfProvider().getAveUIRenderMetrics();
    setState(() {
      _memoryUsage = "${rssMb.toStringAsFixed(0)} MB";
      imageMb = PaintingBinding.instance.imageCache.currentSizeBytes / (1024 * 1024);
      cacheImageCount = PaintingBinding.instance.imageCache.currentSize;
      metrics = currentMetrics;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 使用抽取的包装容器
    return DraggableFloatingWidget(
      width: 180,
      height: 180,
      child: RepaintBoundary(
        child: Material(
          elevation: 10,
          color: Colors.transparent,
          child: Container(
            width: 180,
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${getEnvironmentName()}-${executionTimer.formattedTime}",
                    style: TextStyle(fontSize: 24.w, color: const Color(0xffcccccc), fontWeight: FontWeight.w400),
                  ),
                ),
                const Divider(color: Colors.white10, height: 8),
                _buildInfoRow("RSS", _memoryUsage),
                _buildInfoRow("imageMb", imageMb.toStringAsFixed(1)),
                _buildInfoRow("imgCount", cacheImageCount.toStringAsFixed(0)),
                _buildInfoRow("UI Thread", "${metrics?.uiDurationMs.toStringAsFixed(1)}ms"),
                _buildInfoRow("Raster Thread", "${metrics?.rasterDurationMs.toStringAsFixed(1)}ms"),
                _buildInfoRow(metrics?.getBaseInfo() ?? "", metrics?.getStateMark() ?? "", color: metrics?.getStateColor() ?? Colors.white),
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

  static String getEnvironmentName() {
    if (kReleaseMode) {
      return "Release";
    } else if (kProfileMode) {
      return "Profile";
    } else if (kDebugMode) {
      return "Debug";
    }
    return "unknown";
  }
}

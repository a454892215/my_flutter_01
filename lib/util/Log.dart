import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Log {
  static const String tag = "LLpp:";

  // 1. 自动识别编译模式：Release 模式下不打印 Debug 级别日志
  static bool debugEnable = kDebugMode;

  // 2. 配置 Logger 实例
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      // 内部已通过 getTraceInfo 自定义堆栈，此处设为 0
      errorMethodCount: 8,
      // 错误堆栈层级
      lineLength: 100,
      // 每行宽度
      colors: !Platform.isWindows,
      // Windows 命令行对 ANSI 颜色支持不一，建议关闭以防乱码
      printEmojis: true,
      // 是否打印 Emoji
      printTime: false, // 内部已手动添加时间戳
      noBoxingByDefault: true, // 重要：设置为 true 彻底去掉边框
    ),
  );

  static void d(dynamic msg, {int traceDepth = 1}) {
    if (debugEnable) {
      _print(Level.debug, msg, traceDepth: traceDepth);
    }
  }

  static void i(dynamic msg) {
    _print(Level.info, msg);
  }

  static void w(dynamic msg) {
    _print(Level.warning, msg);
  }

  static void e(dynamic msg, [dynamic error, StackTrace? stackTrace]) {
    _print(Level.error, msg);
    if (error != null || stackTrace != null) {
      _logger.e("$tag Error details:", error: error, stackTrace: stackTrace);
    }
  }

  // 存储每个 Key 上次打印的时间戳
  static final Map<String, int> _lastPrintTimeMap = {};

  // 默认节流时间，例如 1000ms
  static const int defaultThrottleMs = 1000;

  /// 具有节流功能的 Debug 日志
  /// [msg] 日志内容
  /// [throttleKey] 节流的唯一标识，如果不传则使用 msg 本身作为 Key
  /// [throttleMs] 节流时长，单位毫秒
  static void dt(dynamic msg, {String? throttleKey, int throttleMs = defaultThrottleMs, int traceDepth = 0}) {
    if (!debugEnable) return;

    final String key = throttleKey ?? _getAutoThrottleKey();
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int lastPrint = _lastPrintTimeMap[key] ?? 0;

    if (now - lastPrint >= throttleMs) {
      _lastPrintTimeMap[key] = now;
      _print(Level.debug, msg, traceDepth: traceDepth + 1);

      // 清理 Map 防止内存溢出（当 Key 过多时）
      if (_lastPrintTimeMap.length > 100) {
        _lastPrintTimeMap.remove(_lastPrintTimeMap.keys.first);
      }
    }
  }

  /// 核心打印逻辑：兼容 PC 与 移动端
  static void _print(Level level, dynamic msg, {int traceDepth = 1}) {
    String traceInfo = getTraceInfo(level, traceDepth: traceDepth);
    // 构造最终输出字符串
    String text =
        "${DateTime.now().toIso8601String().split('T').last} $traceInfo $tag$msg";
    // API 选择策略：
    // 1. 在 PC 端运行时，debugPrint (stdout) 是最可靠的输出通道
    // 2. logger.log 内部虽然也用 print，但经过 SimplePrinter/PrettyPrinter 处理后更易读
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // 桌面端直接使用 debugPrint，避免 dart:developer.log 在终端失效的问题
      debugPrint(text);
    } else {
      // 移动端使用 logger 库，利用其分段机制防止 Android 系统对单条日志长度（4KB）的限制
      _logger.log(level, text);
    }
  }
  

  /// 跨平台堆栈轨迹解析
  static String getTraceInfo(Level level, {int traceDepth = 1}) {
    try {
      // 获取当前堆栈并标准化格式
      var traceList = StackTrace.current.toString().split("\n");

      String traceInfo = 'Unknown Location';
      List<String> targetTraces = [];

      // 遍历寻找非 Log 类本身的调用层级
      for (int i = 0; i < traceList.length; i++) {
        String line = traceList[i];
        // 过滤掉当前 Log 工具类本身的堆栈信息
        if (!line.contains("Log.") &&
            !line.contains("_print") &&
            line.isNotEmpty) {
          int end = i + traceDepth;
          end = end > traceList.length ? traceList.length : end;

          for (int j = i; j < end; j++) {
            String item = traceList[j];

            // 兼容性截取：PC 端和移动端的 StackTrace 格式不完全一致
            // 寻找 '(' 或 'package:' 标记
            int startIdx = item.indexOf('(package:');
            if (startIdx == -1) startIdx = item.indexOf('package:');

            if (startIdx > -1) {
              item = item.substring(startIdx);
            }
            targetTraces.add(item.trim());
          }
          break;
        }
      }

      // 将深度堆栈组合成字符串输出
      if (targetTraces.isNotEmpty) {
        return targetTraces.join(" \n -> ");
      }
      return traceInfo;
    } catch (e) {
      return "Trace Error: $e";
    }
  }

  /// 核心：自动提取调用者的“类名_方法名”作为节流标识
  static String _getAutoThrottleKey() {
    try {
      // 这里的 traceDepth 需要根据调用层级微调
      // 通常 StackTrace.current.toString() 的第 2 或 3 行是调用处
      var lines = StackTrace.current.toString().split('\n');
      // 过滤掉 Log 类自身的堆栈，找到真正的调用点
      for (var line in lines) {
        if (!line.contains('Log.') && line.contains('package:')) {
          // 简单正则或字符串截取，提取 类名.方法名
          // 示例：#2      AutoScrollUtil._onTick (package:xxx/auto_scroll_list_view.dart:45:5)
          return line.split('(').first.trim();
        }
      }
      return "default_key";
    } catch (e) {
      return "error_key";
    }
  }
}

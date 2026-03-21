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
}


import 'package:flutter/foundation.dart';
import 'package:flutter_comm/util/build_info_manager.dart';
import 'package:logger/logger.dart';
import 'dart:developer' as developer;

class Log {
  static const String tag = "WMP:";

  // 1. 自动识别编译模式：Release 模式下不打印 Debug 级别日志
  static bool isTestBuildMode = BuildInfo.isTestBuildMode();
  static final List<LogItem> _logList = [];
  static LogItem? firstLogItem;
  static List<LogItem> getLogList(){
    return _logList;
  }



  static void d(dynamic msg, {int traceDepth = 1}) {
    if (isTestBuildMode) {
      _print(Level.debug, msg, traceDepth: traceDepth);
    }
  }

  static void i(dynamic msg) {
    _print(Level.info, msg);
  }

  static void i2(dynamic msg) {
    _print(Level.info, msg, force: true);
  }

  static void w(dynamic msg) {
    _print(Level.warning, msg);
  }

  static void e(dynamic msg, [dynamic error, StackTrace? stackTrace]) {
    _print(Level.error, "msg:$msg  error:$error stackTrace:$stackTrace");
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
    if (!isTestBuildMode) return;

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

  static void _handleLogList(Level level, String log, String time) {
    if (!BuildInfo.isUseChuker()) return;
    final String cleanLog = log.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');
    int lastIndex = -1;
    if(_logList.isNotEmpty){
      lastIndex = _logList.last.index;
    }
    final item = LogItem(level, cleanLog, time, ++lastIndex);
    if(_logList.isNotEmpty){
      _logList.last.next = item;
    }else{
      firstLogItem = item;
    }
    _logList.add(item);
    if (_logList.length > 5000) {
      _logList[999].next = null;
      _logList.removeRange(0, 1000);
      firstLogItem = _logList.first;
    }
  }

  static void _print(Level level, dynamic msg, {int traceDepth = 1, bool force = false}) {
    if (!isTestBuildMode && !force) return; // Release 模式彻底关闭，保护性能

    String traceInfo = getTraceInfo(level, traceDepth: traceDepth);
    String text = "$tag$msg";
    final String nowText = _formatMonthDayTime(DateTime.now());

    // 1. 传统的打印（供终端/Logcat使用）
    // 注意：Profile模式下debugPrint可能在IDE控制台不显示，但在adb里有

    // 2. 专门送往 DevTools 的日志
    var fullLog = "$traceInfo $nowText $text";
    _handleLogList(level, "$traceInfo $text", nowText);
    if (level == Level.error) {
      // \x1B[31m 开启红色，\x1B[0m 恢复默认颜色
      fullLog = "\x1B[31m$fullLog\x1B[0m";
      ///  developer.log 无法在终端输出红色的log 所以这里使用 debugPrint，只是 debugPrint 无法输出到调试窗口。
      debugPrint(fullLog);
      return;
    }
    if(kIsWeb){
      debugPrint(fullLog);
      return;
    }
    developer.log(
      fullLog,
      time: DateTime.now(),
      level: _levelToValue(level), // 将 logger 的 Level 转为整数
      name: 'FlutterAppLog',             // DevTools 里的 Tag
      error: null,            // 把堆栈放在 error 字段方便在 DevTools 右侧详情查看
    );
  }

  static String _formatMonthDayTime(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    String three(int v) => v.toString().padLeft(3, '0');
    return "${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}.${three(dt.millisecond)}";
  }

// 映射 Level 到 developer.log 的级别
  static int _levelToValue(Level level) {
    if (level == Level.error) return 1000;
    if (level == Level.warning) return 900;
    return 800; // Info/Debug
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

class LogItem{
  Level level;
  String log;
  String? time;
  LogItem? next;
  int index;
  LogItem(this.level, this.log, this.time, this.index);

  static const _red = '\x1B[31m';
  static const _reset = '\x1B[0m';

  String getDisplayText() {
    var line = '$index $time $log';
    if (level == Level.error) {
      line = '$_red$line$_reset';
    }
    return "$line\n";
  }
}

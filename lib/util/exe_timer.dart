class ExecutionTimer {
  final Stopwatch _stopwatch = Stopwatch();

  /// 开始计时（如果已经在运行，则无效）
  void start() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
    }
  }

  /// 停止计时（停止后，elapsed 时间会固定在停止那一刻）
  void stop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    }
  }

  /// 重置计时（清空累计时间）
  void reset() {
    _stopwatch.reset();
  }

  /// 实时获取当前累计运行时间的格式化字符串
  /// 只要不调用 stop()，每次访问该属性都会计算最新的实时时间
  String get formattedTime => format(_stopwatch.elapsed);

  /// 静态格式化方法：将 Duration 转为 HH:mm:ss
  /// 生产环境代码：处理了 Duration 为负数或极大的边缘情况
  static String format(Duration d) {
    // 确保不处理负值（防止系统时钟微调导致的极端情况）
    final duration = d.abs();

    String twoDigits(int n) => n.toString().padLeft(2, "0");

    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }
}


import 'package:flutter_comm/util/Log.dart';

/// 防止短时间内重复点击同一个入口（例如：按钮连点）。
/// 用例： `if (TapGuard.shouldBlock(key: 'login')) return;`
final class TapGuard {
  TapGuard._();

  static final Map<String, int> _lastTapAtMs = <String, int>{};

  static int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  /// 命中“短时间重复点击”则返回 true（建议直接 `return`），并打印日志。
  static bool shouldBlock({required String key, int intervalMs = 600}) {
    assert(intervalMs >= 0);

    if (key.trim().isEmpty) {
      throw ArgumentError.value(key, 'key', 'TapGuard.shouldBlock requires a non-empty key');
    }

    final now = _nowMs();
    final last = _lastTapAtMs[key];
    if (last != null) {
      final elapsed = now - last;
      if (elapsed < intervalMs) {
        Log.d('TapGuard blocked: key=$key, intervalMs=$intervalMs, elapsedMs=$elapsed');
        return true;
      }
    }

    _lastTapAtMs[key] = now;
    return false;
  }
}


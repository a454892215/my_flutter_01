import 'package:flutter/material.dart';

import '../../util/Log.dart';

class OverlayHelper {
  static final OverlayHelper _instance = OverlayHelper._internal();

  factory OverlayHelper() => _instance;

  OverlayHelper._internal();

  final Map<String, OverlayEntry?> _contentMap = {};

  /// 显示 Overlay
  void show(String key, Widget widget, BuildContext context) {
    if (_contentMap.containsKey(key)) {
      return ;
    }
    final entry = OverlayEntry(builder: (context) => widget);
    try {
      final overlayState = Overlay.of(context);
      overlayState.insert(entry);
      _contentMap[key] = entry;
    } catch (e) {
      Log.d('OverlayHelper Error: $e');
    }
  }

  void close(String key) {
    final OverlayEntry? entry = _contentMap.remove(key);
    if (entry != null) {
      /// 2. 将其从 Overlay 栈中移除 remove() 内部会触发 OverlayState 的重绘
      entry.remove();
    }
  }

  /// 关闭所有 Overlay，通常用于页面销毁或 App 登出
  void closeAll() {
    _contentMap.keys.toList().forEach(close);
    _contentMap.clear();
  }
}

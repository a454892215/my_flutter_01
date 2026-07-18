import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_comm/util/Log.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

/// 原生 splash 移除（幂等），供 Splash / 访客页等兜底调用。
class NativeSplashUtils {
  NativeSplashUtils._();

  static bool _removed = false;

  static bool get isRemoved => _removed;

  static void removeIfNeeded() {
    if (kIsWeb || _removed) return;
    try {
      FlutterNativeSplash.remove();
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
      _removed = true;
      Log.d('====FlutterNativeSplash remove====');
    } catch (e, st) {
      Log.e('FlutterNativeSplash.remove 失败: $e  $st');
    }
  }
}

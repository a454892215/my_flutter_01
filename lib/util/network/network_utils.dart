import 'package:connectivity_plus/connectivity_plus.dart';

/// 基于 [connectivity_plus] 的设备网络通道检测。
///
/// Wi-Fi、蜂窝、以太网、VPN 等任一可用即视为有网络；
/// 仅当结果为 [ConnectivityResult.none]（或列表为空）时视为无网络。
class NetworkUtils {
  NetworkUtils._();

  static final Connectivity _connectivity = Connectivity();

  static const Duration _checkTimeout = Duration(seconds: 1);

  /// 当前是否存在可用网络通道（Wi-Fi / 蜂窝 / 以太网等）。
  ///
  /// 检测异常时返回 `true`，避免误判导致业务被拦截。
  static Future<bool> isNetworkAvailable({Duration during = _checkTimeout}) async {
    try {
      final results = await _connectivity.checkConnectivity().timeout(during);
      return _hasActiveConnection(results);
    } catch (_) {
      return true;
    }
  }

  /// 当前连接类型列表。
  static Future<List<ConnectivityResult>> getConnectivityResults() async {
    try {
      return await _connectivity
          .checkConnectivity()
          .timeout(_checkTimeout);
    } catch (_) {
      return const [ConnectivityResult.none];
    }
  }

  /// 网络通道变化（Wi-Fi / 蜂窝切换、断网等）。
  static Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// 列表中是否包含可用网络（非 [ConnectivityResult.none]）。
  static bool hasActiveConnection(List<ConnectivityResult> results) =>
      _hasActiveConnection(results);

  static bool _hasActiveConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }
}

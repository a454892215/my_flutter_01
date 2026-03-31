import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';

/// 对应 DevTools 中的 Dart/Flutter 内存统计工具
class FlutterMemoryUtil {
  // 单例模式
  static final FlutterMemoryUtil _instance = FlutterMemoryUtil._internal();
  factory FlutterMemoryUtil() => _instance;
  FlutterMemoryUtil._internal();

  vm.VmService? _vmService;
  String? _mainIsolateId;
  bool _isConnecting = false;

  /// 初始化连接 (建议在 App 启动或监控面板开启时调用一次)
  Future<void> _ensureConnected() async {
    if (kReleaseMode || _vmService != null || _isConnecting) return;

    _isConnecting = true;
    try {
      final dev.ServiceProtocolInfo info = await dev.Service.getInfo();
      final Uri? serverUri = info.serverUri;

      if (serverUri != null) {
        // 1. 构造 WebSocket URI (保留所有 Path 和 Token)
        final wsUri = _convertToWebSocketUri(serverUri);

        // 2. 建立长连接 (仅连接一次)
        _vmService = await vmServiceConnectUri(wsUri.toString());

        // 3. 获取主 Isolate ID
        final vmInstance = await _vmService!.getVM();
        _mainIsolateId = vmInstance.isolates?.first.id;

        debugPrint("【MemoryUtil】VM Service 已成功连接: $wsUri");
      }
    } catch (e) {
      debugPrint("【MemoryUtil】连接失败 (请检查 Android 网络权限): $e");
      _vmService = null;
    } finally {
      _isConnecting = false;
    }
  }

  /// 获取当前内存快照
  /// 返回：[TotalMB, ExternalMB, HeapMB]
  Future<List<double>> getMemoryUsage() async {
    if (kReleaseMode) return [0.0, 0.0, 0.0];

    await _ensureConnected();

    if (_vmService == null || _mainIsolateId == null) {
      return [0.0, 0.0, 0.0];
    }

    try {
      final vm.MemoryUsage usage = await _vmService!.getMemoryUsage(_mainIsolateId!);

      // 转换单位为 MB
      double heapUsage = (usage.heapUsage ?? 0) / 1024 / 1024;
      double externalUsage = (usage.externalUsage ?? 0) / 1024 / 1024;
      double total = heapUsage + externalUsage;

      return [total, externalUsage, heapUsage];
    } catch (e) {
      // 发生异常通常是连接断开了，重置状态以便下次重连
      _vmService?.dispose();
      _vmService = null;
      return [0.0, 0.0, 0.0];
    }
  }

  /// 转换 URI 逻辑：确保保留 Auth Token 并支持 Localhost 兼容
  Uri _convertToWebSocketUri(Uri serverUri) {
    // 如果 localhost 不行，换回 127.0.0.1 试试，有些 ROM 屏蔽了 localhost
    return serverUri.replace(
      scheme: serverUri.scheme == 'https' ? 'wss' : 'ws',
      host: '127.0.0.1',
      path: '${serverUri.path}/ws',
    );
  }
  /// 销毁资源
  void dispose() {
    _vmService?.dispose();
    _vmService = null;
  }
}
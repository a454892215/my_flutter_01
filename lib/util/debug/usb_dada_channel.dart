import 'dart:async';
import 'dart:io';

import 'package:flutter_comm/util/Log.dart';

/// Android（App 为 WebSocket 客户端）:
/// 1. adb reverse --remove-all && adb reverse tcp:8080 tcp:8080
/// 2. wscat -l 8080
///
/// iOS 真机无 adb reverse，改为 App 在手机上监听，Mac 通过 iproxy 连入:
/// 1. 先启动 App（监听手机 localhost:8081）
/// 2. 运行 scripts/ios_debug_log_listener_console.sh
///    （iproxy 8081:8081 + wscat -c ws://127.0.0.1:8081）
class UsbDataChannel {
  UsbDataChannel._internal();

  static final UsbDataChannel _instance = UsbDataChannel._internal();
  factory UsbDataChannel() => _instance;

  static const int _androidPort = 8080;
  static const int _iosPort = 8081;

  WebSocket? _socket;
  HttpServer? _iosServer;
  Timer? _pushTimer;

  LogItem? lastSuccessOutputItem;

  Future<void> connect() async {
    try {
      if (Platform.isIOS) {
        await _startIosServer();
      } else {
        await _connectAsClient(_androidPort);
      }
    } catch (e) {
      Log.e("连接失败: $e");
    }
  }

  Future<void> _connectAsClient(int port) async {
    _socket = await WebSocket.connect('ws://localhost:$port');
    Log.d("USB 数据通道连接成功");
    _startPushTimer();
  }

  Future<void> _startIosServer() async {
    _iosServer?.close(force: true);
    _iosServer = await HttpServer.bind(InternetAddress.loopbackIPv4, _iosPort);
    Log.d("USB 数据通道服务已启动 (iOS :$_iosPort)，等待 Mac 连接...");

    _iosServer!.listen((request) {
      if (!WebSocketTransformer.isUpgradeRequest(request)) {
        request.response
          ..statusCode = HttpStatus.notFound
          ..close();
        return;
      }
      WebSocketTransformer.upgrade(request).then((socket) {
        _socket?.close();
        _socket = socket;
        Log.d("USB 数据通道连接成功");
        _startPushTimer();
        socket.done.whenComplete(() {
          if (identical(_socket, socket)) {
            _socket = null;
          }
        });
      });
    });
  }

  void _startPushTimer() {
    _pushTimer ??= Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (_socket == null || _socket!.readyState != WebSocket.open) return;
      if (lastSuccessOutputItem == null) {
        final item = Log.firstLogItem;
        if (item == null) return;
        sendLiveData("${item.time} ${item.log}");
        lastSuccessOutputItem = item;
        return;
      }
      while (lastSuccessOutputItem!.next != null) {
        final item = lastSuccessOutputItem!.next!;
        sendLiveData("${item.time} ${item.log}");
        lastSuccessOutputItem = item;
      }
    });
  }

  void sendLiveData(String data) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      _socket!.add(data);
    }
  }
}

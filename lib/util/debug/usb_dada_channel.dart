import 'dart:async';
import 'dart:io';

import 'package:flutter_comm/util/Log.dart';

/// Android
/// 启动 scripts/android_debug_log_listener_console.sh 脚本接收app 日志
///
/// iOS
/// 启动 scripts/ios_debug_log_listener_console.sh 脚本 接收app日志

class UsbDataChannel {
  UsbDataChannel._internal();

  static final UsbDataChannel _instance = UsbDataChannel._internal();
  factory UsbDataChannel() => _instance;

  static const int _androidPort = 8080;
  static const int _iosPort = 8081;

  static const Duration _pushInterval = Duration(milliseconds: 500);
  static const _keepAliveInterval = Duration(seconds: 12);
  static const _keepAlivePayload = '*';

  WebSocket? _socket;
  HttpServer? _iosServer;
  Timer? _pushTimer;
  DateTime? _lastOutboundAt;
  LogItem? lastSuccessOutputItem;

  Future<void> connect() async {
    try {
      if (Platform.isIOS) {
        await _startIosServer();
      } else if (Platform.isAndroid) {
        unawaited(_connectAndroidWithRetry());
      }
    } catch (e) {
      Log.e("连接失败: $e");
    }
  }

  Future<void> _connectAndroidWithRetry() async {
    while (_socket?.readyState != WebSocket.open) {
      try {
        await _connectAsClient(_androidPort);
        return;
      } catch (e) {
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  Future<void> _connectAsClient(int port) async {
    final socket = await WebSocket.connect('ws://localhost:$port');
    _socket = socket;
    _attachSocket(socket);
    Log.d("android USB 数据通道连接成功");
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
      if (_hasActiveSocket) {
        request.response
          ..statusCode = HttpStatus.serviceUnavailable
          ..close();
        Log.d("IOS USB 数据通道已有连接，拒绝新连接");
        return;
      }
      WebSocketTransformer.upgrade(request).then((socket) {
        if (_hasActiveSocket) {
          socket.close();
          return;
        }
        _socket = socket;
        _attachSocket(socket);
        _lastOutboundAt = DateTime.now();
        Log.d("IOS USB 数据通道连接成功");
        _startPushTimer();
      });
    });
  }

  bool get _hasActiveSocket =>
      _socket != null && _socket!.readyState == WebSocket.open;

  void _attachSocket(WebSocket socket) {
    socket.listen(
          (_) {},
      onDone: () {
        if (!identical(_socket, socket)) return;
        _socket = null;
        if (Platform.isAndroid) {
          unawaited(_connectAndroidWithRetry());
        }
      },
      onError: (error) {
        if (!identical(_socket, socket)) return;
        _socket = null;
        if (Platform.isAndroid) {
          unawaited(_connectAndroidWithRetry());
        }
      },
    );
  }

  void _startPushTimer() {
    _pushTimer ??= Timer.periodic(_pushInterval, (_) {
      if (_socket == null || _socket!.readyState != WebSocket.open) return;
      _flushPendingLogs();
      _sendKeepAliveIfIdle();
    });
  }

  void _sendKeepAliveIfIdle() {
    final last = _lastOutboundAt;
    if (last != null &&
        DateTime.now().difference(last) < _keepAliveInterval) {
      return;
    }
    _rawSend(_keepAlivePayload);
  }

  void _flushPendingLogs() {
    final item = lastSuccessOutputItem == null ? Log.firstLogItem : lastSuccessOutputItem!.next;
    if (item == null) return;
    if (_socket == null || _socket!.readyState != WebSocket.open) return;
    if (lastSuccessOutputItem == null) {
      final item = Log.firstLogItem;
      if (item == null) return;
      final line = item.getDisplayText();
      _rawSend(line);
      lastSuccessOutputItem = item;
      return;
    }
    int loopOutputSize = 0;
    while (lastSuccessOutputItem!.next != null) {
      final item = lastSuccessOutputItem!.next!;
      final line = item.getDisplayText();
      _rawSend(line);
      loopOutputSize += line.length;
      lastSuccessOutputItem = item;
      /// 避免单次输出 数据量太大，造成连接断开
      if(loopOutputSize > 1000){
        break;
      }
    }
  }

  bool _rawSend(String data) {
    final socket = _socket;
    if (socket == null || socket.readyState != WebSocket.open) return false;
    try {
      socket.add(data);
      _lastOutboundAt = DateTime.now();
      return true;
    } catch (e) {
      Log.e('USB 数据通道发送失败: $e');
      return false;
    }
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter_comm/util/Log.dart';
import 'package:logger/logger.dart';

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
  static const _red = '\x1B[31m';
  static const _reset = '\x1B[0m';
  static const _maxPushPerTick = 10;
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
      } else {
        await _connectAsClient(_androidPort);
      }
    } catch (e) {
      Log.e("连接失败: $e");
    }
  }

  Future<void> _connectAsClient(int port) async {
    final socket = await WebSocket.connect('ws://localhost:$port');
    _socket = socket;
    _attachSocket(socket);
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
        _attachSocket(socket);
        Log.d("USB 数据通道连接成功");
        _startPushTimer();
      });
    });
  }

  /// drain 入站帧（含客户端 ping），勿设 pingInterval——经 iproxy 时 pong 易丢失导致断连。
  void _attachSocket(WebSocket socket) {
    _lastOutboundAt = DateTime.now();
    socket.listen(
          (_) {},
      onDone: () {
        if (identical(_socket, socket)) {
          _socket = null;
        }
      },
      onError: (_) {
        if (identical(_socket, socket)) {
          _socket = null;
        }
      },
      cancelOnError: true,
    );
  }

  void _startPushTimer() {
    _pushTimer ??= Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (_socket == null || _socket!.readyState != WebSocket.open) return;
      _flushPendingLogs();
      _sendKeepAliveIfIdle();
    });
  }

  /// 空闲时发轻量数据帧保活 iproxy TCP，比服务端 WebSocket ping 更稳。
  void _sendKeepAliveIfIdle() {
    final last = _lastOutboundAt;
    if (last != null &&
        DateTime.now().difference(last) < _keepAliveInterval) {
      return;
    }
    _rawSend(_keepAlivePayload);
  }

  /// 每 tick 限量推送，避免积压日志突发打满 iproxy/USB 导致 1005 断连。
  void _flushPendingLogs() {
    var pushed = 0;
    while (pushed < _maxPushPerTick) {
      final LogItem? item = lastSuccessOutputItem == null
          ? Log.firstLogItem
          : lastSuccessOutputItem!.next;
      if (item == null) return;
      _pushLogItem(item);
      lastSuccessOutputItem = item;
      pushed++;
    }
  }

  void _pushLogItem(LogItem item) {
    var line = '${item.time} ${item.log}';
    if (item.level == Level.error) {
      line = '$_red$line$_reset';
    }
    sendLiveData(line);
  }

  void sendLiveData(String data) => _rawSend(data);

  void _rawSend(String data) {
    final socket = _socket;
    if (socket == null || socket.readyState != WebSocket.open) return;
    try {
      socket.add(data);
      _lastOutboundAt = DateTime.now();
    } catch (e) {
      // 勿用 Log.e，避免发送失败→写日志→再发送的循环
      print('USB 数据通道发送失败: $e');
    }
  }
}

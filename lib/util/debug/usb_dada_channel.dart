import 'dart:async';
import 'dart:io';

import 'package:flutter_comm/util/Log.dart';

/// Android: 电脑端执行:
/// 1. adb forward --remove-all
/// 2. adb reverse tcp:8080 tcp:8080
/// 3. adb forward --list
/// 4. wscat -l 8080
/// iOS: 电脑端使用 iproxy 8080 8080 （由 libimobiledevice 提供）。
/// 数据链路: Flutter App 只需要往手机本地的 localhost:8080 发送 TCP/WebSocket 数据，数据就会自动通过 USB 线流向电脑的 localhost:8080。
class UsbDataChannel {
  UsbDataChannel._internal();

  static final UsbDataChannel _instance = UsbDataChannel._internal();
  factory UsbDataChannel() => _instance;

  WebSocket? _socket;

  LogItem? lastSuccessOutputItem;


  Future<void> connect() async {
    try {
      // 假设手机作为客户端，连接映射后的本地端口
      _socket = await WebSocket.connect('ws://localhost:8080');
      Log.d("USB 数据通道连接成功");

      Timer.periodic(const Duration(milliseconds: 1000), (t){
        if(lastSuccessOutputItem == null){
          if (_socket == null || _socket!.readyState != WebSocket.open) return;
          final item = Log.firstLogItem;
          if(item == null) return;
          sendLiveData("${item.time} ${item.log}");
          lastSuccessOutputItem = item;
        }
        if (_socket == null || _socket!.readyState != WebSocket.open) return;
        while (lastSuccessOutputItem!.next != null) {
          final item = lastSuccessOutputItem!.next!;
          sendLiveData("${item.time} ${item.log}");
          lastSuccessOutputItem = item;
        }
      });
    } catch (e) {
      Log.e("连接失败: $e");
    }
  }

  void sendLiveData(String data) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      _socket!.add(data);
    }
  }
}
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../widget/auto_scroll_listview.dart';
import '../../../base/base_controller.dart';
import '../entity/entities.dart';

class TabView4ControllerController extends BaseController {
  final rxList = <ChatMessage>[].obs;

  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    rxList.value = getTestData();
  }

  @mustCallSuper
  @override
  void onReady() {
    super.onReady();
  }

  @mustCallSuper
  @override
  void onClose() {
    super.onClose();
  }

  List<ChatMessage> getTestData({int size = 300}) {
    List<ChatMessage> list = [];
    for (int i = 0; i < size; i++) {
      var chatMessage = ChatMessage();
      chatMessage.text = generateRandomChineseString();
      chatMessage.userIcon = "";
      var next1 = Random().nextInt(11);
      var next2 = Random().nextInt(11);
      chatMessage.imgList = ["images/chat/chat$next1.jpg", "images/chat/chat$next2.jpg"];
      list.add(chatMessage);
    }
    return list;
  }

  String generateRandomChineseString() {
    final random = Random();
    final length = random.nextInt(109) + 12; // 生成12到120之间的随机数
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      final unicode = random.nextInt(20901) + 19968;
      final character = String.fromCharCode(unicode);
      buffer.write(character);
    }

    final chineseString = buffer.toString();
    return chineseString;
  }
}

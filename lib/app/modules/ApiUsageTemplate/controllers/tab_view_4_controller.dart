import 'dart:math';

import '../../../base/base_controller.dart';
import '../entity/entities.dart';

class TabView4ControllerController extends BaseController {
  List<ChatMessage> list = [];

  @override
  void onInit() {
    super.onInit();
    list = getTestData();
  }

  List<ChatMessage> getTestData({int size = 300}) {
    List<ChatMessage> result = [];
    for (int i = 0; i < size; i++) {
      var chatMessage = ChatMessage();
      chatMessage.text = generateRandomChineseString();
      chatMessage.userIcon = "";
      var next1 = Random().nextInt(11);
      var next2 = Random().nextInt(11);
      chatMessage.imgList = [
        "assets/images/test/chat/chat$next1.jpg",
        "assets/images/test/chat/chat$next2.jpg",
      ];
      result.add(chatMessage);
    }
    return result;
  }

  String generateRandomChineseString() {
    final random = Random();
    final length = random.nextInt(80) + 8; // 生成8到80之间的随机数
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      final unicode = random.nextInt(2000) + 19968;
      final character = String.fromCharCode(unicode);
      buffer.write(character);
    }

    final chineseString = buffer.toString();
    return chineseString;
  }
}

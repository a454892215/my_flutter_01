import 'package:flutter/material.dart';
import 'package:flutter_comm/screen_info.dart';

const style12 = TextStyle(fontSize: 12);

class AppText extends StatelessWidget {
  const AppText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 12, color: Color(0x99202020)));
  }
}

final defTextStyle = TextStyle(fontSize: 13.w, color: Colors.black, fontWeight: FontWeight.w400);

class TextWidget extends Text {
  const TextWidget(super.data, {super.key});

  TextWidget.def(
    super.data, {
    super.key,
    super.textAlign = TextAlign.center,
    super.maxLines = 1,
    super.overflow = TextOverflow.ellipsis,
  }) : super(style: defTextStyle);
}

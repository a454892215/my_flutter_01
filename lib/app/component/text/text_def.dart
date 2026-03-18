import 'package:flutter/material.dart';

const style12 = TextStyle(fontSize: 12);

class AppText extends StatelessWidget {
  const AppText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 12, color: Color(0x99202020)));
  }
}

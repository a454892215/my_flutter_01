import 'package:flutter/material.dart';
import 'package:flutter_comm/skin/skin_data.dart';
import 'package:flutter_comm/skin/skin_factory.dart';

class SkinRepo {
  static const Map<SkinType, SkinData> configs = {
    SkinType.bright: SkinData(
      textColor1: Colors.black,
      bgColor1: Colors.white,
      headerBgColor: Color(0xffeaeaea),
      headerTextColor: Color(0xff191919),
      assetPath: "assets/skin/bright",
    ),
    SkinType.black: SkinData(
      textColor1: Color(0xffefefef),
      bgColor1: Color(0xff1a1a1a),
      headerBgColor: Color(0xff131313),
      headerTextColor: Color(0xffededed),
      assetPath: "assets/skin/black",
    ),
    SkinType.ocean: SkinData(
      textColor1: Colors.white,
      bgColor1: Colors.blueAccent,
      headerBgColor: Color(0xff284785),
      headerTextColor: Color(0xffededed),
      assetPath: "assets/skin/ocean",
    ),
    SkinType.forest: SkinData(
      textColor1: Color(0xffe0f2f1),
      bgColor1: Color(0xff2e7d32),
      headerBgColor: Color(0xff3a7a2c),
      headerTextColor: Color(0xffededed),
      assetPath: "assets/skin/forest",
    ),
  };
}
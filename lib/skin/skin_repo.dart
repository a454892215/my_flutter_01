import 'package:flutter/material.dart';
import 'package:flutter_comm/skin/skin_data.dart';
import 'package:flutter_comm/skin/skin_factory.dart';

class SkinRepo {
  static const Map<SkinType, SkinData> configs = {
    SkinType.bright: SkinData(
      textColor1: Colors.black,
      bgColor1: Colors.white,
      assetPath: "assets/skin/bright",
    ),
    SkinType.black: SkinData(
      textColor1: Color(0xffefefef),
      bgColor1: Color(0xff1a1a1a),
      assetPath: "assets/skin/black",
    ),
    SkinType.ocean: SkinData(
      textColor1: Colors.white,
      bgColor1: Colors.blueAccent,
      assetPath: "assets/skin/ocean",
    ),
    SkinType.forest: SkinData(
      textColor1: Color(0xffe0f2f1),
      bgColor1: Color(0xff2e7d32),
      assetPath: "assets/skin/forest",
    ),
  };
}
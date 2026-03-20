import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_comm/skin/skin_factory.dart';

import '../util/sp/sp_util.dart';

class SkinManager extends ChangeNotifier {
  SkinManager._();

  static final SkinManager instance = SkinManager._();
  static const String _key = "sp_key_skin_type";

  // 默认初始值为 bright
  SkinType _curSkinType = SkinType.bright;

  SkinType get curSkinType => _curSkinType;

  Future<void> init() async {
    String? typeName = spUtil.getString(_key);
    _curSkinType = SkinType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => SkinType.bright,
    );
  }

  ThemeData get currentTheme => SkinFactory.createTheme(_curSkinType);

  ThemeMode get themeMode =>
      _curSkinType == SkinType.system ? ThemeMode.system : ThemeMode.light;

  void updateSkin(SkinType type) {
    if (_curSkinType == type) return;
    _curSkinType = type;
    spUtil.setString(_key, type.name);
    notifyListeners();
  }
}

import 'package:shared_preferences/shared_preferences.dart';

import 'Log.dart';

SpUtil spUtil = SpUtil();

class SpUtil {
  late SharedPreferences prefs;

  init() async {
    prefs = await SharedPreferences.getInstance();
    Log.d("SharedPreferences 初始化完毕");
  }

  Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await prefs.setStringList(key, value);
  }

  int? getInt(String key) {
    return prefs.getInt(key);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }
}

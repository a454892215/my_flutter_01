import 'package:flutter/cupertino.dart';
import 'package:flutter_comm/util/sp_util.dart';
import 'package:flutter_comm/util/sp_util_key.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

extension StringExtension on String {
  /// 获取Token，拼接到url后面
  String addToken() {
    String token = spUtil.getString(keyLoginToken) ?? "";
    if (token.isNotEmpty) {
      if (contains("?")) {
        return "$this&t=$token";
      } else {
        return "$this?t=$token";
      }
    }
    return this;
  }

  String capitalizeFirstLetter() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String capitalizeFirstLetterOfEachWord() {
    List<String> words = split(" ");
    List<String> capitalizedWords = [];

    for (String word in words) {
      if (word.isNotEmpty) {
        capitalizedWords.add(word[0].toUpperCase() + word.substring(1).toLowerCase());
      }
    }

    return capitalizedWords.join(" ");
  }
}

class AppRxList<T> extends RxList<T> {
  dynamic other;
  String? strExt;

  AppRxList([List<T> initial = const []]) : super(initial);
}

class AppScrollController extends ScrollController {
  AppScrollController({
    double initialScrollOffset = 0.0,
    keepScrollOffset = true,
  }) : super(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
        );

  Callback? callback;

  void addScrollToBottomListener(Callback callback) {
    this.callback = callback;
    addListener(_scrollListener);
  }

  //  滚动监听回调
  Future<void> _scrollListener() async {
    if (offset >= position.maxScrollExtent && !position.outOfRange) {
      if (callback != null) {
        callback!();
      }
    }
  }

  void release() {
    removeListener(_scrollListener);
  }
}

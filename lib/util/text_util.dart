import 'package:flutter/cupertino.dart';
import 'package:flutter_comm/util/app_util.dart';

import 'Log.dart';

class TextMeasureUtil {
  static Size getTextSize({
    required String text,
    required double maxWidth,
    required TextStyle style,
  }) {
    TextSpan span = TextSpan(style: style, text: text);
    TextPainter painter = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    painter.layout(maxWidth: maxWidth);
    // int lines = painter.computeLineMetrics().length; // 文字行数
    // Log.d("textWidth:$textWidth  textHeight:$textHeight - lines:$lines");
    return Size(painter.width, painter.height);
  }
}

/// 复制链接
void copyText(String link) {
  AppUtil.copy(link);
}

String getUrlDecodeStr(String text) {
  return Uri.decodeComponent(text);
}

String getUrlDoubleDecodeStr(String text) {
  try {
    var t1 = getUrlDecodeStr(text);
    text =  getUrlDecodeStr(t1);
  } catch (e, stack) {
    Log.e("$e \n $stack");
  }
  return text;
}
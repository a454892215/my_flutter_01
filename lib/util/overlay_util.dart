import 'package:flutter/cupertino.dart';

class OverlayUtil {
  Map<String, OverlayEntry?> contentMap = {};

  void show(String key, Widget widget, BuildContext context) {
    var value = contentMap[key];
    if(value == null){
      value = OverlayEntry(builder: (context){
        return widget;
      });
      contentMap[key] = value;
    }
    Overlay.of(context).insert(value);
  }

  void close(String key){
    OverlayEntry? entry = contentMap[key];
    if(entry != null){
      entry.remove();
      contentMap[key] = null;
      contentMap.remove(key);
    }
  }
}

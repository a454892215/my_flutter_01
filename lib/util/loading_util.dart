import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class AppLoading {
  static initLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 70.w
      ..radius = 20.w
      ..progressColor = Colors.white
      ..backgroundColor = Colors.black.withOpacity(0.5)
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = false
      ..dismissOnTap = false;
  }
  static show() {
    EasyLoading.show(status: 'loading...');
  }

  static close() {
    EasyLoading.isShow ? EasyLoading.dismiss() : null;
  }
}
import 'package:flutter/material.dart';
import '../../../../../screnn_info.dart';
import '../../../../../widget/dialog/base_dialog.dart';

class LeftSlidingDialog extends BaseDialog {
  @override
  Alignment get alignment => Alignment.centerLeft;

  @override
  Widget buildWidget() {
    return Container(
      width: 300.w,
      height: 300.w,
      padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 0.w, bottom: 0.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xffcccccc),
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xff000000), width: 1.w),
      ),
      child: Text(
        "LeftDialog",
        style: TextStyle(fontSize: 24.w, color: Color(0xffa84242), fontWeight: FontWeight.w400),
      ),
    );
  }
}

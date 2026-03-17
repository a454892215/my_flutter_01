import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.width,
    required this.height,
    required this.text,
    required this.onClick,
    this.colorList = colorList1,
    this.disable = false,
    required this.radius,
    this.textColor = Colors.white,
    this.borderRadius,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  final double width;
  final double height;
  final String text;
  final VoidCallback onClick;
  final List<Color> colorList;
  final double radius;
  final Color textColor;
  final bool disable;
  final BorderRadiusGeometry? borderRadius;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  static const colorList1 = [Color(0xff0ED1F4), Color(0xff1373EF)];
  static const colorList2 = [Color(0xffFFD500), Color(0xffFF9901)];

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: disable ? null : onClick,
      minSize: 0,
      pressedOpacity: 0.8,
      padding: const EdgeInsets.all(0),
      child: Opacity(
        opacity: disable ? 0.6 : 1,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colorList,
              begin: begin,
              end: end,
            ),
            borderRadius: borderRadius ?? BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 28.w,
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

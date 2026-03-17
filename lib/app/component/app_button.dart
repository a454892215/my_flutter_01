import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 通用按钮
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.width,
    this.height,
    this.padding,
    required this.text,
    required this.onClick,
    this.colorList = colorList1,
    this.disable = false,
    this.radius = 0,
    this.textColor = Colors.white,
    this.borderRadius,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
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
      sizeStyle: CupertinoButtonSize.small,
      minimumSize: Size.zero,
      pressedOpacity: 0.8,
      padding: EdgeInsets.zero, // 确保按钮点击区域不带默认边距
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colorList, begin: begin, end: end),
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
        ),
        // 默认的 Alignment.center会大小尽可能充满父组件，所以为了包裹内容 设置alignment=null
        alignment: width == null ? null : Alignment.center,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // 防止文字溢出
          style: TextStyle(
            fontSize: 28.w,
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

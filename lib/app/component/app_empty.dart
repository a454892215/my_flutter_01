import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppEmpty extends StatelessWidget {
  const AppEmpty({
    super.key,
    this.width,
    this.height,
    this.alignment,
  });

  final double? height;
  final double? width;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/empty.webp', width: 192.w),
          Center(
            child: Text('Sem dados', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7), fontSize: 26.w)),
          )
        ],
      ),
    );
  }
}

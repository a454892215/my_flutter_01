import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../util/math_util.dart';

class AppProgress extends StatelessWidget {
  const AppProgress({
    super.key,
    required this.width,
    required this.height,
    required this.progress,
    this.colorList = colorList1,
    required this.radius,
  });

  final double width;
  final double height;
  final num progress;
  final List<Color> colorList;
  final double radius;

  static const colorList1 = [Color(0xff1373EF), Color(0xff0ED1F4)];

  static const colorList2 = [Color(0xff0BE3FF), Color(0xffFFD90C)];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.25),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Stack(
          children: [
            Container(
              width: width * progress / 100,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colorList),
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20.w, top: 2.w),
              alignment: Alignment.centerLeft,
              child: Text(
                "${MathU.getStr2DForce(progress.toString())}%",
                style: TextStyle(
                  fontSize: 24.w,
                  color: const Color(0xffffffff),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

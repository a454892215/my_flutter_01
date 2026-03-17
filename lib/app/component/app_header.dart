import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../app_style.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.isNeedLeftBackArrow = true,
  });

  final String title;
  final bool isNeedLeftBackArrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110.w,
      decoration: BoxDecoration(
        color: headerBgColor,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20.w,
            child: isNeedLeftBackArrow
                ? IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.arrow_back_ios, size: 45.w))
                : const SizedBox(),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 36.w,
            ),
          )
        ],
      ),
    );
  }
}

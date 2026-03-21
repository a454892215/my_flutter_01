import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../skin/app_skin.dart';
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
    return SizedBox(
      width: double.infinity,
      height: 110.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 15.w,
            child: isNeedLeftBackArrow
                ? IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      size: 45.w,
                      color: context.skinData.headerTextColor,
                    ),
                  )
                : const SizedBox(),
          ),
          Text(
            title,
            style: TextStyle(
              color: context.skinData.headerTextColor,
              fontSize: 36.w,
            ),
          ),
        ],
      ),
    );
  }
}

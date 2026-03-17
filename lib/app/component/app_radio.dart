import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppRadio extends StatelessWidget {
  const AppRadio({super.key, this.isCheck = false, this.onClick});

  final isCheck;
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      minSize: 0,
      onPressed: () {
        if (onClick != null) {
          onClick!();
        }
      },
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40.w),
          image: DecorationImage(
            image: isCheck ? const AssetImage("assets/images/i-radio-active.webp") : const AssetImage("assets/images/i-radio-no.webp"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

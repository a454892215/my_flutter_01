import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppRadio extends StatelessWidget {
  const AppRadio({super.key,
    this.isCheck = false,
    this.onClick,
    required this.checkedWidget,
    required this.uncheckedWidget,
  });

  final bool isCheck;
  final Widget checkedWidget;
  final Widget uncheckedWidget;
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
      child: isCheck ?  checkedWidget : uncheckedWidget,
    );
  }
}

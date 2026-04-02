import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../util/input_rules.dart';
import '../../../../../widget/dialog/base_dialog.dart';
import '../../../../../widget/input_field.dart';

class BottomSlidingDialog extends BaseDialog {
  @override
  Alignment get alignment => Alignment.bottomCenter;

  @override
  Widget buildWidget() {
    return DialogWidget();
  }
}

class DialogWidget extends StatefulWidget {
  const DialogWidget({super.key});

  @override
  State<DialogWidget> createState() => _DialogWidgetState();
}

class _DialogWidgetState extends State<DialogWidget> {

  final accountCtrl = AppInputController(regExp: InputRules.usernameReg);

  @override
  void dispose() {
    super.dispose();
    accountCtrl.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600.w,
      height: 300.w,
      padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 0.w, bottom: 0.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xffcccccc),
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xff000000), width: 1.w),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "BottomSlidingDialog",
            style: TextStyle(fontSize: 24.w, color: const Color(0xffcccccc), fontWeight: FontWeight.w400),
          ),
          AppTextField(
            controller: accountCtrl,
            hintText: "请输入用户名/邮箱",
            prefix: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(Icons.person_outline, size: 36.w, color: Colors.grey),
            ),
            customStyle: AppInputStyle(width: 1.sw * 0.7, height: 90.w),
            formatters: InputRules.usernameFormatters,
          ),
        ],
      ),
    );
  }
}

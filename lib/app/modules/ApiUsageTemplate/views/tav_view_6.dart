import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../util/input_rules.dart';
import '../../../../widget/input_field.dart';
import '../../../component/text/text_def.dart';
import '../controllers/tab_view_6_controller.dart';

///
class TabView6 extends StatefulWidget {
  const TabView6({super.key});

  @override
  State<TabView6> createState() => _TabView6State();
}

class _TabView6State extends State<TabView6> {
  @override
  Widget build(BuildContext context) {
    // 只要第一次打开时请求过，数据就会一直保存在这个内存对象中
    return GetBuilder(
      init: TabView6ControllerController(),
      builder: (controller) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xff88b868),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              AppTextField(
                controller: controller.accountCtrl,
                hintText: "请输入用户名/邮箱",
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(Icons.person_outline, size: 36.w, color: Colors.grey,),
                ),
                customStyle: AppInputStyle(width: 1.sw * 0.7, height: 90.w),
                formatters: InputRules.usernameFormatters,
              ),

              SizedBox(height: 32.h),

              // --- 示例 2: 密码输入框 (带眼睛切换) ---
              AppTextField(
                controller: controller.passwordCtrl,
                hintText: "请输入密码",
                isPassword: true,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(Icons.lock_outline, size: 36.w, color: Colors.grey),
                ),
                customStyle: AppInputStyle(width: 1.sw * 0.7, height: 90.w),
                formatters: InputRules.passwordFormatters,
              ),
            ],
          ),
        );
      },
    );
  }
}

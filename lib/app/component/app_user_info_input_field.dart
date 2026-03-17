import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';


import '../../util/Log.dart';
import '../app_style.dart';
import '../widget/input_field.dart';

class UserInfoInputField extends StatelessWidget {
  const UserInfoInputField({
    super.key,
    required this.prefixIcon,
    required this.editNode,
    required this.errText,
    this.isUserName = false,
    this.isPassword = false,
    this.isPhone = false,
    this.isCode = false,
    this.isEmail = false,
    this.isTelegram = false,
    this.isConfirmsPassword = false,
    this.codeSender,
    required this.hint,
    this.radius = 50,
    this.height,
    this.bgColor = Colors.black,
    this.border,
    this.onTextChanged,
    this.prefixIconWidth,
    this.paddingLeft,
    this.paddingRight,
    this.codeName = "Enviar",
    this.editEnable = true,
    this.showErrHeight,
    this.pswEditNode,
    this.confirmPswEditNode,
    this.suffixWidget,
  });

  final String? prefixIcon;
  final dynamic editNode;
  /// 只有确认密码需要配置
  final dynamic pswEditNode;
  /// 只有密码需要配置
  final dynamic confirmPswEditNode;
  final String errText;
  final String hint;
  final bool isUserName;
  final bool isPassword;
  final bool isConfirmsPassword;
  final bool isPhone;
  final bool isCode;
  final bool isEmail;
  final bool isTelegram;
  final dynamic codeSender;
  final double radius;
  final double? height;
  final double? showErrHeight;
  final double? paddingLeft;
  final double? paddingRight;
  final double? prefixIconWidth;
  final Color? bgColor;
  final BoxBorder? border;
  final String codeName;
  final ValueChanged<String>? onTextChanged;
  final bool editEnable;
  final Widget? suffixWidget;

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter>? tarFormatterList = [];
    if (isUserName) {
      tarFormatterList = userNameFormatterList;
    } else if (isPassword || isConfirmsPassword) {
      tarFormatterList = passwordFormatterList;
    } else if (isEmail) {
      tarFormatterList = emailFormatterList;
    } else if (isPhone) {
      tarFormatterList = phoneFormatterList;
    } else if (isCode) {
      tarFormatterList = codeFormatterList;
    }else if (isTelegram) {
      tarFormatterList = telegramUsernameFormatterList;
    }
    return Obx(() {
      double defHeight = 114.w;
      double showHeight = editNode.isDisplayErrHint.value ? showErrHeight ?? defHeight : height ?? defHeight;
        return SizedBox(
          width: double.infinity,
          height: showHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                var eyeIsOPen = !editNode.eyeIsOPen.value;
                return MyInputFiled(
                  width: double.infinity,
                  height: 72.w,
                  hint: hint,
                  border: border,
                  bgColor: bgColor,
                  radius: radius,
                  editEnable: editEnable,
                  obscureText: isPassword || isConfirmsPassword ? eyeIsOPen : false,
                  inputFormatters: tarFormatterList,
                  keyboardType: isEmail ? TextInputType.emailAddress : (isPhone || isCode ? TextInputType.number : TextInputType.text),
                  hintStyle: TextStyle(color: const Color(0xff969799), fontSize: 26.w),
                  textStyle: TextStyle(color: const Color(0xffffffff), fontSize: 26.w),
                  prefix: Padding(
                    padding: EdgeInsets.only(left: paddingLeft ?? 20.w, right: paddingRight ?? 10.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if(prefixIcon != null)
                        Image.asset(prefixIcon!, width: prefixIconWidth ?? 28.w),
                        if (isPhone)
                          Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: Text(
                              "+55",
                              style: TextStyle(
                                fontSize: 26.w,
                                color: const Color(0xff0ED1F4),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                  suffix: suffixWidget ?? SuffixImageWidget(
                    editNode: editNode,
                    isCode: isCode,
                    isPassword: isPassword || isConfirmsPassword,
                    verifyCodeSender: codeSender,
                    userInfoInputField: this,
                  ),
                  onTextChanged: (text) {
                    if (isUserName) {
                      editNode.isDisplayErrHint.value = !usernameRegExp.hasMatch(text);
                    } else if (isPassword || isConfirmsPassword) {
                      editNode.isDisplayErrHint.value = !pswRegExp.hasMatch(text);
                      if(isPassword && confirmPswEditNode != null && confirmPswEditNode!.text.value.isNotEmpty){
                        confirmPswEditNode!.isDisplayErrHint.value = confirmPswEditNode!.text.value != text;
                      }
                      if(isConfirmsPassword && pswEditNode != null){
                        editNode.isDisplayErrHint.value = pswEditNode!.text.value != text;
                      }
                    } else if (isPhone) {
                      editNode.isDisplayErrHint.value = !phoneNumExp.hasMatch(text);
                    } else if (isEmail) {
                      editNode.isDisplayErrHint.value = !emailExp.hasMatch(text);
                    } else if (isCode) {
                      editNode.isDisplayErrHint.value = !codeRegExp.hasMatch(text);
                    } else if (isTelegram) {
                      editNode.isDisplayErrHint.value = !telegramUsernameRegExp.hasMatch(text);
                    }
                    if (onTextChanged != null) {
                      onTextChanged!(text);
                    }
                  },
                  editNode: editNode,
                );
              }),
              Obx(() {
                return editNode.isDisplayErrHint.value
                    ? Padding(
                        padding: EdgeInsets.only(left: 76.w, top: 6.w),
                        child: Text(
                          errText,
                          style: TextStyle(
                            fontSize: 24.w,
                            color: const Color(0xffFF690D),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    : const SizedBox();
              })
            ],
          ),
        );
      }
    );
  }
}

class SuffixImageWidget extends StatelessWidget {
  const SuffixImageWidget({
    super.key,
    this.isPassword = false,
    this.isCode = false,
    required this.editNode,
    this.verifyCodeSender,
    required this.userInfoInputField,
  });

  final bool isPassword;
  final bool isCode;
  final dynamic editNode;
  final dynamic verifyCodeSender;
  final UserInfoInputField userInfoInputField;

  @override
  Widget build(BuildContext context) {
    if (isPassword) {
      return Obx(() {
        String eyeImgPath = editNode.eyeIsOPen.value ? "assets/images/eye-open.webp" : "assets/images/eye-close.webp";
        return CupertinoButton(
          padding: EdgeInsets.only(right: 28.w, top: 12.w, bottom: 12.w, left: 15.w),
          onPressed: () {
            editNode.eyeIsOPen.value = !editNode.eyeIsOPen.value;
          },
          child: Image.asset(
            eyeImgPath,
            width: 28.w,
            gaplessPlayback: true,
          ),
        );
      });
    }
    if (isCode) {
      return CupertinoButton(
        onPressed: () {
          var isCountDown = verifyCodeSender!.countTime.value > 0;
          if (!isCountDown) {
            var inputIsOk = verifyCodeSender!.checkInput();
            if (inputIsOk) {
              verifyCodeSender?.requestSendVerifiedCode();
            }else{
              Log.e("=======输入不合法=========");
            }
          }
        },
        minSize: 0,
        padding: EdgeInsets.zero,
        child: Container(
          width: 130.w,
          height: 46.w,
          margin: EdgeInsets.only(right: 15.w, top: 2.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              gradient: yellowLinearGradient,
              borderRadius: BorderRadius.circular(
                100.w,
              )),
          child: Obx(() {
            var isCountDown = verifyCodeSender!.countTime.value > 0;
            return Text(
              isCountDown ? "${verifyCodeSender!.countTime.value}" : userInfoInputField.codeName,
              style: TextStyle(
                fontSize: 26.w,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            );
          }),
        ),
      );
    }
    return const SizedBox();
  }
}

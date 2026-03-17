import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


//RegExp usernameRegExp = RegExp(r"^[a-zA-Z][a-zA-Z0-9]{4,13}$");
RegExp usernameRegExp = RegExp(r"^[a-zA-Z0-9!#$@%&'*+/=?^_`{|}~.-]{4,64}$");
RegExp pswRegExp = RegExp(r"^[0-9A-Za-z]{4,12}$");
final phoneNumExp = RegExp(r"^[0-9]{8,20}$");
RegExp inviteCodeRegExp = RegExp(r"^[A-Za-z0-9]{6,9}$");
RegExp codeRegExp = RegExp(r"^[0-9]{4}$");
RegExp telegramUsernameRegExp = RegExp(r"^@[a-zA-Z][a-zA-Z0-9_]{3,30}$");
RegExp emailExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
final upperCaseCharExp = RegExp(r"^[A-Z]$");

List<TextInputFormatter>? userNameFormatterList = [
  LengthLimitingTextInputFormatter(64),
  // FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z]')),
];

List<TextInputFormatter>? telegramUsernameFormatterList = [
  LengthLimitingTextInputFormatter(32),
  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_@]')),
];

List<TextInputFormatter>? passwordFormatterList = [
  LengthLimitingTextInputFormatter(20),
  FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z]')),
];

List<TextInputFormatter>? phoneFormatterList = [
  LengthLimitingTextInputFormatter(20),

  /// 手机号输入格式化后带有空格，故正则限制中加入空格，如果不加入空格，光标位置会忽略空格
  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
];

List<TextInputFormatter>? codeFormatterList = [
  LengthLimitingTextInputFormatter(6),
  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
];

List<TextInputFormatter>? emailFormatterList = [
  LengthLimitingTextInputFormatter(64),
];

List<TextInputFormatter>? aliaFormatterList = [
  LengthLimitingTextInputFormatter(20),
  FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z ]')),
];

List<TextInputFormatter>? usdtAddressFormatterList = [
  LengthLimitingTextInputFormatter(40),
];

List<TextInputFormatter>? verifyCodeFormatterList = [
  LengthLimitingTextInputFormatter(4),
];

final FilteringTextInputFormatter pureNumFormatter = FilteringTextInputFormatter.allow(RegExp("[0-9]"));

/// 手机号输入格式化后带有空格，故正则限制中加入空格，如果不加入空格，光标位置会忽略空格
final FilteringTextInputFormatter phoneInputFormatter = FilteringTextInputFormatter.allow(RegExp("[0-9 ]"));

class EditNode {
  late FocusNode focusNode;
  final hasFocus = false.obs;
  late TextEditingController editController;
  late final text = "".obs;
  final enable = false.obs;
  final obscureTextEnable = true.obs;
  final isDisplayErrHint = false.obs;
  final eyeIsOPen = false.obs;
  RegExp? regExp;
  /// 当错误的时候 不再主动校验，确认密码需要设置，因为这两个校验有连带关系，这里简化了校验规则, 否则确认密码和密码不一致也会通过
  final bool isNotVerifyOnErr;

  EditNode({this.regExp, this.isNotVerifyOnErr = false});

  /// 返回输入是否OK
  bool checkInput() {
    /// 如果已经是错误状态，则不再主动校验
    if (isNotVerifyOnErr && isDisplayErrHint.value) {
      return false;
    }
    if (regExp != null) {
      isDisplayErrHint.value = !regExp!.hasMatch(text.value);
    }
    return !isDisplayErrHint.value;
  }

  void reset() {
    text.value = "";
    isDisplayErrHint.value = false;
    eyeIsOPen.value = false;
    hasFocus.value = false;
  }

  _addeventHasFocus() {
    hasFocus.value = focusNode.hasFocus;
  }

  initState() {
    focusNode = FocusNode();
    focusNode.addListener(_addeventHasFocus);
    editController = TextEditingController(text: text.value);
  }

  dispose() {
    focusNode.removeListener(_addeventHasFocus);
    focusNode.dispose();
    editController.dispose();
  }
}

class MyInputFiled extends StatefulWidget {
  const MyInputFiled({
    super.key,
    required this.width,
    required this.height,
    required this.hint,
    this.prefix,
    this.suffix,
    required this.editNode,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.onTextChanged,
    this.bgColor = Colors.black,
    this.radius = 50,
    this.hintStyle,
    this.textStyle,
    this.obscureText = false,
    this.textDirection,
    this.border,
    this.editEnable = true,
  });

  final double width;
  final double height;
  final String hint;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Widget? prefix;
  final Widget? suffix;
  final double radius;
  final Color? bgColor;
  final BoxBorder? border;
  final EditNode editNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onTextChanged;
  final bool obscureText;
  final TextDirection? textDirection;
  final bool editEnable;

  @override
  State<MyInputFiled> createState() => _MyInputFiledState();
}

class _MyInputFiledState extends State<MyInputFiled> {
  _addListener() {
    widget.editNode.text.value = widget.editNode.editController.text;

    if (widget.onTextChanged != null) {
      widget.onTextChanged!(widget.editNode.text.value);
    }
  }

  @override
  void initState() {
    super.initState();
    //  Log.d('============初始化==============');
    widget.editNode.initState();
    widget.editNode.editController.addListener(_addListener);
  }

  @override
  void dispose() {
    widget.editNode.editController.removeListener(_addListener);
    widget.editNode.dispose();
    // Log.d('==============销毁====================');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // borderRadius: BorderRadius.circular(widget.radius),
      child: Stack(
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(color: widget.bgColor, borderRadius: BorderRadius.circular(widget.radius), border: widget.border),
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 8.w),
            child: CupertinoTextField(
              controller: widget.editNode.editController,
              focusNode: widget.editNode.focusNode,
              textDirection: widget.textDirection,
              style: widget.textStyle ?? TextStyle(color: Colors.white, fontSize: 28.w),
              keyboardType: widget.keyboardType,
              decoration: const BoxDecoration(color: Colors.transparent),
              placeholder: widget.hint,
              textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.start,
              placeholderStyle: widget.hintStyle ?? TextStyle(color: const Color.fromRGBO(255, 255, 255, 0.4), fontSize: 28.w),
              cursorColor: Colors.white,
              cursorHeight: 32.w,
              maxLines: 1,
              obscureText: widget.obscureText,
              maxLength: 32,
              prefix: widget.prefix,
              suffix: widget.suffix,
              padding: EdgeInsets.only(left: 10.w),
              // suffix: delView(),
              inputFormatters: widget.inputFormatters,
            ),
          ),
          if (!widget.editEnable)
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.transparent,
            ),
        ],
      ),
    );
  }
}

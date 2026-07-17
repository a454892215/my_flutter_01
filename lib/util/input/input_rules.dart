import 'package:flutter/services.dart';

class InputRules {
  // --- 1. 正则校验规则 (RegExp) ---
  static final RegExp usernameReg = RegExp(r"^[a-zA-Z0-9!#$@%&'*+/=?^_`{|}~.-]{4,64}$");
  static final RegExp passwordReg = RegExp(r"^[0-9A-Za-z]{4,12}$");
  static final RegExp phoneReg = RegExp(r"^[0-9]{8,20}$");
  static final RegExp inviteCodeReg = RegExp(r"^[A-Za-z0-9]{6,9}$");
  static final RegExp codeReg = RegExp(r"^[0-9]{4,6}$"); // 原代码有4位和6位冲突，建议兼容
  static final RegExp telegramReg = RegExp(r"^@[a-zA-Z][a-zA-Z0-9_]{3,30}$");
  static final RegExp emailReg = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

  // --- 2. 输入拦截器 (TextInputFormatter) ---

  // 用户名：只限长度 64
  static List<TextInputFormatter> get usernameFormatters => [
    LengthLimitingTextInputFormatter(64),
  ];

  // 密码：只限长度 20，且只允许数字和字母
  static List<TextInputFormatter> get passwordFormatters => [
    LengthLimitingTextInputFormatter(20),
    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z]')),
  ];

  // 手机号：只限数字，长度 20
  static List<TextInputFormatter> get phoneFormatters => [
    LengthLimitingTextInputFormatter(20),
    FilteringTextInputFormatter.digitsOnly, // 生产环境推荐用这个，更稳定
  ];

  // 电报：允许字母数字下划线和@
  static List<TextInputFormatter> get telegramFormatters => [
    LengthLimitingTextInputFormatter(32),
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_@]')),
  ];

  // 邮箱：长度 64
  static List<TextInputFormatter> get emailFormatters => [
    LengthLimitingTextInputFormatter(64),
  ];

  // 验证码：纯数字 4-6 位
  static List<TextInputFormatter> get codeFormatters => [
    LengthLimitingTextInputFormatter(6),
    FilteringTextInputFormatter.digitsOnly,
  ];
}
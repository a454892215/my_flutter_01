/// 邮箱格式校验工具（常见 ASCII 邮箱；非 RFC 5322 全量实现）
class EmailValidator {
  EmailValidator._();

  /// 整段邮箱（含 `@`）在 RFC 5321 下的上限，与常见服务端、SMTP 限制一致。
  static const int maxTotalLength = 254;

  static final RegExp _pattern = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@'
    r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  /// 是否像合法邮箱（会先 `trim`，空串为 false）
  static bool isValid(String input) {
    final s = input.trim();
    if (s.isEmpty || s.length > maxTotalLength) return false;
    return _pattern.hasMatch(s);
  }
}

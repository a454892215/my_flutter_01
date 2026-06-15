import 'package:flutter/material.dart';
/// 渐变文本颜色组建
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const GradientText(
      this.text, {
        super.key,
        required this.colors,
        this.style,
        this.begin = Alignment.centerLeft,
        final AlignmentGeometry? end, // 默认水平渐变
        this.textAlign,
        this.maxLines,
        this.overflow,
      }) : end = end ?? Alignment.centerRight;

  @override
  Widget build(BuildContext context) {
    // 获取当前上下文中的默认文本样式，并与传入的 style 合并
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effectiveTextStyle = defaultTextStyle.style.merge(style);

    // 强制将 inherit 设为 false，确保合并时不会有冲突（由于我们要自定义 foreground）
    effectiveTextStyle = effectiveTextStyle.copyWith(inherit: false);

    // 1. 使用 TextPainter 在内存中离屏测量文字的实际渲染宽高
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: effectiveTextStyle),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    )..layout(
      // 如果外部限制了最大宽度，这里传入约束，防止长文本测量不准
      maxWidth: MediaQuery.maybeSizeOf(context)?.width ?? double.infinity,
    );

    final double textWidth = textPainter.width;
    final double textHeight = textPainter.height;

    // 2. 根据测量出的宽高，动态创建属于该文本的专属 Rect
    final Rect textRect = Rect.fromLTWH(0.0, 0.0, textWidth, textHeight);

    // 3. 构建带渐变 Shader 的最终 TextStyle
    final TextStyle gradientStyle = effectiveTextStyle.copyWith(
      color: null, // 必须显式将 color 置空，否则会与 foreground 冲突报错
      foreground: Paint()
        ..shader = LinearGradient(
          colors: colors,
          begin: begin,
          end: end,
        ).createShader(textRect),
    );

    return Text(
      text,
      style: gradientStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
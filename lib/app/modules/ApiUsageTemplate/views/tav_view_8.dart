import 'package:flutter/material.dart';
import 'package:flutter_comm/widget/gradient_text.dart';

import '../../../widget/text/text_def.dart';

class TabView8 extends StatelessWidget {
  const TabView8({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xff19a1e8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(text: "8渐变文字颜色"),
          SizedBox(height: 10),
          ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [Colors.blue, Colors.purple, Colors.pink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(Offset.zero & bounds.size);
            },
            // 必须将文字颜色设为白色，因为遮罩会和子组件的颜色进行混合
            child: const Text(
              '这是官方API-ShaderMask实现的渐变文字',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '这是官方API-foreground-Paint轻量级渐变文字',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              // 使用 foreground 属性，注意：设置了 foreground 就不能设置 color 属性
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Colors.orange, Colors.red],
                ).createShader(
                  // 这里需要手动指定渐变的范围区域（Rect）
                  const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                ),
            ),
          ),
          SizedBox(height: 10),
          // 示例 1：默认水平渐变（左右）
          GradientText(
            'GradientText-渐变文字颜色用例1',
            colors: const [Colors.orange, Colors.red],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // 示例 2：斜向多色渐变，并支持限制行数和省略号
          GradientText(
            'GradientText-渐变文字颜色用例2',
            colors: const [Colors.blue, Colors.purple, Colors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

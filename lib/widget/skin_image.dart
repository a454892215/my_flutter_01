import 'package:flutter/cupertino.dart';

import '../skin/app_skin.dart';

class SkinImage extends StatelessWidget {
  final String path; // 只传文件名，如 "ic_user_head.png"
  final double? width;
  final double? height;
  final BoxFit? fit;

  const SkinImage(this.path, {super.key, this.width, this.height, this.fit});

  @override
  Widget build(BuildContext context) {
    // 每次主题更新触发 rebuild，这里的路径就会根据当前的 assetPath 自动变化
    return Image.asset(
      "${context.skinData.assetPath}/$path",
      width: width,
      height: height,
      fit: fit,
    );
  }
}
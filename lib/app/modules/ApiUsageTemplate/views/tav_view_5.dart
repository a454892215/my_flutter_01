import 'package:flutter/material.dart';

import '../../../../screen_info.dart';
import '../../../../widget/asset_image.dart';
import '../../../../widget/banner.dart';
import '../../../widget/text/text_def.dart';

class TabView5 extends StatelessWidget {
  const TabView5({super.key});

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
          AppText(text: "TabView5"),
          CommonBanner(
            width: 1.sw,
            height: 1.sw * 0.4,
            itemCount: 4,
            itemBuilder: (BuildContext context, int index) {
              return AppAssetImage(
                "assets/images/test/banner${index + 1}.webp",
                width: 1.sw,
              );
            },
          ),
        ],
      ),
    );
  }
}

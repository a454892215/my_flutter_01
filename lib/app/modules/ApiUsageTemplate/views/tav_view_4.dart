import 'package:flutter/material.dart';

import '../../../../screen_info.dart';
import '../../../../widget/asset_image.dart';
import '../../../widget/text/text_def.dart';
import '../controllers/tab_view_4_controller.dart';
import '../entity/entities.dart';

class TabView4 extends StatefulWidget {
  const TabView4({super.key});

  @override
  State<TabView4> createState() => _TabView4State();
}

class _TabView4State extends State<TabView4> {
  late final TabView4ControllerController controller;

  @override
  void initState() {
    super.initState();
    controller = TabView4ControllerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xffffffff),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(text: "TabView4"),
          Expanded(
            child: Center(
              child: ListView.builder(
                itemCount: controller.list.length,
                padding: EdgeInsets.all(0),
                physics: const BouncingScrollPhysics(),
                cacheExtent: 800,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  ChatMessage message = controller.list[index];
                  return Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff2e2e2e),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        for (int i = 0; i < message.imgList.length; i++)
                          Center(
                            child: AppAssetImage(
                              message.imgList[i],
                              width: 1.sw * 0.82,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

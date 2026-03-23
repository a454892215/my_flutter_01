import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import '../../../../widget/asset_image.dart';
import '../../../component/text/text_def.dart';
import '../controllers/tab_view_4_controller.dart';
import '../entity/entities.dart';

/// TemplateDrawerController 在父组件中注册，GetView 相比 GetBuilder 不会在页面关闭的时候 主动销毁Controller
class TabView4 extends StatefulWidget {
  const TabView4({super.key});

  @override
  State<TabView4> createState() => _TabView4State();
}

class _TabView4State extends State<TabView4> {
  @override
  Widget build(BuildContext context) {
    // 只要第一次打开时请求过，数据就会一直保存在这个内存对象中
    return GetBuilder(
      init: TabView4ControllerController(),
      builder: (controller) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xffffffff),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText(text: "TabView4",),
              Expanded(child: Center(
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
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Text(
                                    message.text,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:  Color(0xff2e2e2e),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                for (int i = 0; i < message.imgList.length; i++)
                                  Center(
                                    child: AppAssetImage(message.imgList[i], width: 1.sw * 0.82,),
                                  )
                              ],
                            ),
                        );
                      }),
              ))
            ],
          ),
        );
      }
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_comm/app/component/app_button.dart';
import 'package:flutter_comm/widget/toast_util.dart';

import '../../screen_info.dart';
import '../../util/app_util.dart';


class AppUpdate extends StatefulWidget {
  const AppUpdate({super.key, this.appUpgradeData});

  final dynamic appUpgradeData;

  @override
  State<AppUpdate> createState() => _AppUpdateState();
}

class _AppUpdateState extends State<AppUpdate> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 634.w,
        height: 567.w,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(1, 26, 81, 1),
          borderRadius: BorderRadius.circular(20.w),
        ),
        child: Column(
          children: [
            Container(
              height: 248.w,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Color.fromRGBO(75, 67, 254, 1),
                    Color.fromRGBO(178, 64, 255, 1),
                    Color.fromRGBO(237, 58, 194, 1),
                    Color.fromRGBO(255, 62, 85, 1),
                  ],
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 50.w),
                      child: Text(
                        "IN-APP\nUPDATES",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 52.w,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          shadows: const [
                            Shadow(
                              offset: Offset(0.0, 2.2016007900238037),
                              blurRadius: 4.403201580047607,
                              color: Color.fromRGBO(38, 20, 124, 1.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -40.w,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.only(left: 50.w),
                      child: Container(
                        width: 331.w,
                        height: 298.w,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(
                              "assets/images/update.webp",
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 180.w,
              width: double.infinity,
              padding: EdgeInsets.only(left: 40.w, right: 40.w, top: 30.w),
              // 可以滚动
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appUpgradeData?.content ?? "发现现版本 是否更新？",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.w,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: AppButton(
                text: "开始更新",
                width: 580.w,
                height: 90.w,
                onClick: () {
                  // 打开浏览器
                  final url = widget.appUpgradeData?.url ?? "";
                  if (url.isEmpty) {
                    Toast.show("无效的 更新链接！");
                    return;
                  }
                  AppUtil.launch(url);
                },
                radius: 100.w,
              ),
            )
          ],
        ),
      ),
    );
  }
}

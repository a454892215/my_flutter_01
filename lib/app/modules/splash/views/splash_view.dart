import 'package:flutter/material.dart';
import 'package:flutter_comm/screen_info.dart';
import 'package:flutter_comm/util/ui/global_floating_overlay.dart';
import 'package:flutter_comm/widget/toast_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routes/app_pages.dart';
import '../../../widget/app_button.dart';
import '../../../widget/my_app_bar.dart';
import '../controllers/splash_controller.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlobalFloatingOverlay.show(
        Padding(
          padding: const EdgeInsets.all(10),
          child: InkWell(
            radius: 45,
            onTap: () {
              Toast.show("onTap");
            },
            child: Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: Color(0xaa5bff5d),
                borderRadius: BorderRadius.circular(45),
              ),
              child: const SizedBox(),
            ),
          ),
        ),
        context,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(splashControllerProvider);
    return Scaffold(
      appBar: MyAppBar(title: controller.title),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xff84abf6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5),
            AppButton(
              padding: EdgeInsets.all(8),
              text: "去home页面66",
              onClick: () => {
                Navigator.of(context).pushReplacementNamed(Routes.home),
              },
            ),
          ],
        ),
      ),
    );
  }
}

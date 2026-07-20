import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widget/app_button.dart';
import '../../../widget/my_app_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(homeControllerProvider);
    return Scaffold(
      appBar: MyAppBar(title: 'HomeView'),
      body: Container(
        width: double.infinity,
        color: Colors.green,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppButton(
              padding: EdgeInsets.all(12),
              text: "去API使用示列页面",
              onClick: () => {
                Navigator.of(context).pushNamed(Routes.apiUsageTemplate),
              },
            ),
            SizedBox(height: 10),
            //  AppButton(padding: EdgeInsets.all(12), text: "去英语学习页面", onClick: () => {Navigator.of(context).pushNamed(Routes.englishLearn)}),
            AppButton(
              padding: EdgeInsets.all(12),
              text: "去Debug Log",
              onClick: () => {
                Navigator.of(context).pushNamed(Routes.log),
              },
            ),
          ],
        ),
      ),
    );
  }
}

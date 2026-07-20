import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../screen_info.dart';
import '../../../widget/text/text_def.dart';
import '../controllers/api_usage_template_drawer_controller.dart';

/// TemplateDrawerController 由 Riverpod provider 注册
class DrawerApiView extends ConsumerWidget {
  const DrawerApiView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(templateDrawerControllerProvider);
    return Container(
      width: 450.w,
      height: double.infinity,
      color: Color(0xffeca1e8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(text: controller.name),
        ],
      ),
    );
  }
}

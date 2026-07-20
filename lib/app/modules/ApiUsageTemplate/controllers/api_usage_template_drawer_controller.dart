import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../base/base_controller.dart';

class TemplateDrawerController extends BaseController {
  String name = "抽屉页面";
}

final templateDrawerControllerProvider =
    ChangeNotifierProvider.autoDispose<TemplateDrawerController>((ref) {
  return TemplateDrawerController();
});

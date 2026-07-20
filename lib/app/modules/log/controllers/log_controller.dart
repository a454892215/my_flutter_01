import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../base/base_controller.dart';

class LogController extends BaseController {
  int count = 0;

  void increment() {
    count++;
    notifyListeners();
  }
}

final logControllerProvider =
    ChangeNotifierProvider.autoDispose<LogController>((ref) {
  return LogController();
});

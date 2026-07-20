import 'package:flutter_comm/util/Log.dart' show Log;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../base/base_controller.dart';

class EnglishLearnController extends BaseController {
  int count = 0;

  @override
  void onInit() {
    super.onInit();
    Log.d(
      "===========EnglishLearnController===11=======onInit===== PerfMonitor.stop();=======",
    );
  }

  void increment() {
    count++;
    notifyListeners();
  }
}

final englishLearnControllerProvider =
    ChangeNotifierProvider.autoDispose<EnglishLearnController>((ref) {
  return EnglishLearnController();
});

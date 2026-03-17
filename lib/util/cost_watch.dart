import 'Log.dart';

class CostWatch {
  int start = 0;
  int exeIndex = 0;
  CostWatch() {
    start = DateTime.now().millisecondsSinceEpoch;
  }

  void printExeTime({String tag = ''}) {
    int end = DateTime.now().millisecondsSinceEpoch;
    int costTime = end - start;
    Log.d("$tag exeIndex:$exeIndex costTime: $costTime");
    exeIndex++;
  }
}

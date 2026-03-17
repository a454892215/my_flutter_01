import 'package:get/get_rx/src/rx_types/rx_types.dart';

class IndexRxMap{
  final Map<int, Rx<int>?> _indexMap = {};

  Rx<int> getIndexRxByPos(int pos) {
    var posRx = _indexMap[pos];
    if (posRx == null) {
      posRx = 0.obs;
      _indexMap[pos] = posRx;
    }
    return posRx;
  }

  void resetByPos(int pos) {
    _indexMap[pos] = null;
  }

  void clear() {
    _indexMap.clear();
  }
}
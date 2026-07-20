import '../../../../widget/auto_scroll_listview.dart';
import '../../../base/base_controller.dart';

class TabView3ControllerController extends BaseController {
  final List<String> rxList = List.generate(30, (index) => "Item $index");
  late final AutoScrollListViewController autoScrollController;

  @override
  void onInit() {
    super.onInit();
    autoScrollController = AutoScrollListViewController();
  }
}

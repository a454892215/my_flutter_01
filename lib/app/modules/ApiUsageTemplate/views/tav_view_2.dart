import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart'
    show RefreshController;
import '../../../widget/refresh_widget.dart';
import '../controllers/tab_view_2_controller.dart';

/// refresh sample
class TabView2 extends StatefulWidget {
  const TabView2({super.key});

  @override
  State<TabView2> createState() => _TabView2State();
}

class _TabView2State extends State<TabView2> {
  /// 需要回收的 controller 建议定义在 State 中，生命周期与 Widget 严格绑定
  late RefreshController _refreshController;
  late final TabView2ControllerController controller;

  @override
  void initState() {
    super.initState();
    controller = TabView2ControllerController();
    _refreshController = RefreshController();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    controller.dispose();
    super.dispose();
  }

  // 模拟 API 请求
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        controller.listSize = controller.initSize;
      });
    }
  }

  Future<void> _handleLoading() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        controller.listSize += controller.perSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: RefreshWidget(
        refreshController: _refreshController,
        loadmoreEnable: controller.listSize >= controller.perSize,
        onRefresh: _handleRefresh,
        onLoadMore: _handleLoading,
        child: ListView.builder(
          itemCount: controller.listSize,
          // 优化：固定高度使用 itemExtent 提升渲染效率
          itemExtent: 50,
          padding: EdgeInsets.zero,
          // 建议保持默认或按需调整，700 对简单列表而言较高
          cacheExtent: 500,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              width: double.infinity,
              color: index % 2 == 0 ? Colors.blue : Colors.amberAccent,
              child: Center(child: Text("Item $index")),
            );
          },
        ),
      ),
    );
  }
}

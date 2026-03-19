import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class RefreshWidget extends StatefulWidget {
  const RefreshWidget({
    super.key,
    required this.child,
    this.onRefresh,
    this.onLoading,
    required this.refreshController,
    this.scrollController,
    this.physics = const BouncingScrollPhysics(),
    this.refreshEnable = true,
    this.loadmoreEnable = true,
    this.header,
    this.footer,
    this.emptyWidget, // 自定义空状态组件
    this.onEmptyTap, // 点击空状态的回调（通常用于重新加载）
    this.initialRefresh = false, // 是否在加载时自动触发一次刷新
  });

  final Widget child;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoading;
  final RefreshController refreshController;
  final ScrollPhysics? physics;
  final bool refreshEnable;
  final bool loadmoreEnable;
  final Widget? header;
  final Widget? footer;

  // 状态增强参数
//  final bool isEmpty;
  final Widget? emptyWidget;
  final VoidCallback? onEmptyTap;
  final bool initialRefresh;
  final ScrollController? scrollController;

  @override
  State<RefreshWidget> createState() => _RefreshWidgetState();
}

class _RefreshWidgetState extends State<RefreshWidget> {
  @override
  void initState() {
    super.initState();
    // 自动触发初始刷新
    if (widget.initialRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.refreshController.requestRefresh();
      });
    }
  }

  bool isRefreshing = false;
  /// 内部包装刷新逻辑：自动结束状态、异常捕获
  Future<void> _handleRefresh() async {
    if (widget.onRefresh == null) return;
    try {
      await widget.onRefresh!();
      widget.refreshController.refreshCompleted();
      // refreshToIdle 可以避免，刷新结束如果不满一屏幕内容，refreshCompleted后，
      // 如果没有设置enableScrollWhenRefreshCompleted: true 不能马上响应触摸滚动事件
     // widget.refreshController.refreshToIdle();
      //resetNoData 把底部的‘没有更多内容’提示去掉，恢复成可以上拉的状态
      widget.refreshController.resetNoData();
    } catch (e) {
      debugPrint("AppList Refresh Error: $e");
      widget.refreshController.refreshFailed();
    }
  }

  /// 内部包装加载逻辑
  Future<void> _handleLoading() async {
    if (widget.onLoading == null) return;
    try {
      await widget.onLoading!();
      if (widget.refreshController.isLoading) {
        widget.refreshController.loadComplete();
      }
    } catch (e) {
      debugPrint("AppList Loading Error: $e");
      widget.refreshController.loadFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 核心逻辑：如果是空状态，则渲染占位图而非 child
    return SmartRefresher(
      enablePullDown: widget.refreshEnable,
      enablePullUp: widget.loadmoreEnable,
      controller: widget.refreshController,
      scrollController: widget.scrollController,
      onRefresh: _handleRefresh,
      onLoading: _handleLoading,
      physics: widget.physics,
      // 强制开启越界回弹，增强手感
     // header: widget.header ?? _buildDefaultHeader(),
     // footer: widget.footer ?? _buildDefaultFooter(),
      child: widget.child,
    );
  }

  /// 默认 Header 实现
  Widget _buildDefaultHeader() {
    return CustomHeader(
      builder: (context, mode) {
        Widget body;
        if (mode == RefreshStatus.refreshing) {
          body = const CircularProgressIndicator(strokeWidth: 2);
        } else {
          final Map<RefreshStatus, String> statusMap = {
            RefreshStatus.idle: "下拉刷新...",
            RefreshStatus.canRefresh: "释放刷新...",
            RefreshStatus.failed: "刷新失败...",
            RefreshStatus.completed: "刷新成功...",
          };
          body = Text(
            statusMap[mode] ?? "",
            style: TextStyle(fontSize: 13, color: Color(0x33333333)),
          );
        }
        return SizedBox(
          height: 60,
          child: Center(
            child: body,
          ),
        );
      },
    );
  }

  /// 默认 Footer 实现
  Widget _buildDefaultFooter() {
    return CustomFooter(
      builder: (context, mode) {
        Widget body;
        switch (mode) {
          case LoadStatus.loading:
            body = const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
            break;
          case LoadStatus.failed:
            body = const Text("加载失败，点击重试");
            break;
          case LoadStatus.noMore:
            body = const Text("—— 我是有底线的 ——");
            break;
          default:
            body = const Text("上拉加载更多");
            break;
        }
        return SizedBox(
          height: 60.h,
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
              child: body,
            ),
          ),
        );
      },
    );
  }
}

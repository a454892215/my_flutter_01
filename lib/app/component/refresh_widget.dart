import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于触感反馈
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class RefreshWidget extends StatefulWidget {
  const RefreshWidget({
    super.key,
    required this.child,
    this.onRefresh,
    this.onLoading,
    required this.refreshController,
    this.enablePullDown = true,
    this.enablePullUp = true,
    this.header,
    this.footer,
    this.isEmpty = false, // 是否显示空状态
    this.emptyWidget, // 自定义空状态组件
    this.onEmptyTap, // 点击空状态的回调（通常用于重新加载）
    this.initialRefresh = false, // 是否在加载时自动触发一次刷新
  });

  final Widget child;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoading;
  final RefreshController refreshController;
  final bool enablePullDown;
  final bool enablePullUp;
  final Widget? header;
  final Widget? footer;

  // 状态增强参数
  final bool isEmpty;
  final Widget? emptyWidget;
  final VoidCallback? onEmptyTap;
  final bool initialRefresh;

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

  /// 内部包装刷新逻辑：处理震动、自动结束状态、异常捕获
  Future<void> _handleRefresh() async {
    if (widget.onRefresh == null) return;

    // 模拟原生下拉到临界点的震动反馈
    HapticFeedback.lightImpact();

    try {
      widget.refreshController.resetNoData();
      await widget.onRefresh!();
      widget.refreshController.refreshCompleted();
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
      // 注意：loadComplete 通常由外部根据分页数据量决定是否调用 loadNoData()
      // 这里仅做兜底结束，防止加载动画卡死
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
    Widget content = widget.isEmpty ? _buildEmptyView() : widget.child;

    return SmartRefresher(
      enablePullDown: widget.enablePullDown,
      enablePullUp: widget.enablePullUp && !widget.isEmpty, // 空状态时禁用上拉
      controller: widget.refreshController,
      onRefresh: _handleRefresh,
      onLoading: _handleLoading,
      physics: const BouncingScrollPhysics(), // 强制开启越界回弹，增强手感
      header: widget.header ?? _buildDefaultHeader(),
      footer: widget.footer ?? _buildDefaultFooter(),
      child: content,
    );
  }

  /// 构建空状态 UI
  Widget _buildEmptyView() {
    return GestureDetector(
      onTap: widget.onEmptyTap ?? () => widget.refreshController.requestRefresh(),
      child: widget.emptyWidget ??
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 100.h),
            child: Column(
              children: [
                Icon(Icons.inbox, size: 80.w, color: Colors.grey[300]),
                SizedBox(height: 16.h),
                Text(
                  "暂无数据，点击重试",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
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
            RefreshStatus.idle: "下拉刷新",
            RefreshStatus.canRefresh: "释放以刷新",
            RefreshStatus.failed: "刷新失败",
            RefreshStatus.completed: "刷新成功",
          };
          body = Text(statusMap[mode] ?? "");
        }
        return SizedBox(
          height: 60.h,
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              child: body,
            ),
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

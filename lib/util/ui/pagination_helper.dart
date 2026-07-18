import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../Log.dart';

/// 分页助手：适用于按页码分页的列表请求。
///
/// 与 [RefreshWidget] 配合示例：
/// ```dart
/// final helper = PaginationHelper(perPageSize: 20);
///
/// Future<void> onRefresh() async {
///   helper.reset();
///   final list = await api.fetch(page: helper.requestPageIndex);
///   await helper.onRequestSuccess(list.length);
/// }
///
/// Future<void> onLoadMore() async {
///   if (helper.hasRequestedAllData) return;
///   final list = await api.fetch(page: helper.requestPageIndex);
///   await helper.onRequestSuccess(list.length);
/// }
///
/// ValueListenableBuilder<bool>(
///   valueListenable: helper.enableLoadMore,
///   builder: (_, enable, child) => RefreshWidget(
///     refreshController: helper.refreshController,
///     scrollController: helper.scrollController,
///     loadmoreEnable: enable,
///     onRefresh: onRefresh,
///     onLoadMore: onLoadMore,
///     child: child!,
///   ),
///   child: listView,
/// );
/// ```
class PaginationHelper {
  /// 内部起始页。实际请求页码为 [curPageIndex] + 1（从 1 开始）。
  static const int defPageIndex = 0;

  /// 每页期望条数，用于判断是否已加载完全部数据。
  final int perPageSize;

  /// 数据渲染后再更新 [enableLoadMore] 的延迟，避免内容不满一屏时误触发加载。
  final Duration renderDelay;

  int _curPageIndex = defPageIndex;
  bool _isRequestedAllData = false;

  /// 是否启用上拉加载。用 [ValueListenableBuilder] 监听即可，无需 GetX。
  final ValueNotifier<bool> enableLoadMore = ValueNotifier(false);

  final RefreshController refreshController = RefreshController();
  final ScrollController scrollController = ScrollController();

  PaginationHelper({
    required this.perPageSize,
    this.renderDelay = const Duration(milliseconds: 100),
  }) : assert(perPageSize > 0, 'perPageSize must be > 0');

  /// 当前已成功请求的页游标（未请求过为 [defPageIndex]）。
  int get curPageIndex => _curPageIndex;

  /// 下次请求应使用的页码（从 1 开始）。
  int get requestPageIndex => _curPageIndex + 1;

  /// 是否已加载完全部数据。
  bool get hasRequestedAllData => _isRequestedAllData;

  /// 当前是否处于「刷新 / 第一页」请求阶段。
  bool get isFirstPageRequest => _curPageIndex <= defPageIndex;

  /// 获取当前需要请求的页码（同 [requestPageIndex]）。
  int getCurRequestPageIndex() => requestPageIndex;

  /// 是否已请求完全部数据。
  bool isHasRequestedAllData() {
    if (_isRequestedAllData) {
      Log.d('所有数据请求完毕');
    }
    return _isRequestedAllData;
  }

  /// 请求成功后调用，传入本次返回的条目数。
  ///
  /// - 若 [itemCount] < perPageSize，视为已无更多数据。
  /// - 会短暂延迟后再更新 enableLoadMore，保证列表已渲染。
  Future<void> onRequestSuccess(int itemCount) async {
    if (_isRequestedAllData) return;

    _isRequestedAllData = itemCount < perPageSize;
    _curPageIndex++;

    await Future<void>.delayed(renderDelay);
    enableLoadMore.value = !_isRequestedAllData;

    if (_isRequestedAllData) {
      Log.d('所有数据请求完毕, page=$_curPageIndex, lastCount=$itemCount');
    }
  }

  /// 兼容旧命名，等同于 [onRequestSuccess]。
  Future<void> onRequestDataOk(int itemListSize) =>
      onRequestSuccess(itemListSize);

  /// 请求失败时调用，同步结束 [refreshController] 的刷新 / 加载状态。
  ///
  /// 若配合 [RefreshWidget] 使用，通常只需在回调里 `throw`，由 Widget 处理失败态；
  /// 本方法适合自行控制 [RefreshController] 的场景。
  void onRequestFailed({bool? isRefresh}) {
    final refresh = isRefresh ?? isFirstPageRequest;
    if (refresh) {
      refreshController.refreshFailed();
    } else {
      refreshController.loadFailed();
    }
  }

  /// 标记无更多数据，并结束当前加载态（若有）。
  void markNoMoreData() {
    _isRequestedAllData = true;
    enableLoadMore.value = false;
    if (refreshController.isLoading) {
      refreshController.loadNoData();
    }
  }

  /// 下拉刷新前调用，重置分页状态。
  void reset({bool jumpToTop = false}) {
    _curPageIndex = defPageIndex;
    _isRequestedAllData = false;
    enableLoadMore.value = false;
    if (jumpToTop && scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  /// 释放控制器与监听器，在 State.dispose 中调用。
  void dispose() {
    enableLoadMore.dispose();
    refreshController.dispose();
    scrollController.dispose();
  }
}

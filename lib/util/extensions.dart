import 'package:flutter/cupertino.dart';
import 'package:flutter_comm/util/sp/sp_util.dart';
import 'package:flutter_comm/util/sp/sp_util_key.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

extension StringExtension on String {

  String capitalizeFirstLetter() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

class AppRxList<T> extends RxList<T> {
  dynamic other;
  String? strExt;

  AppRxList([List<T>? initial]) : super(initial ?? <T>[]);
}

class AppScrollController extends ScrollController {
  AppScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset = true,
  });

  // 修改：将 Callback 设为可空，便于销毁
  VoidCallback? _bottomCallback;

  // 修改：增加标记位，防止重复触发（针对异步操作）
  bool _isLoading = false;

  /// 设置触底监听
  /// [callback] 触底后的业务逻辑
  void setScrollToBottomListener(VoidCallback callback) {
    _bottomCallback = callback;
    // 修改：避免重复添加同一个监听器
    removeListener(_scrollListener);
    addListener(_scrollListener);
  }

  void _scrollListener() {
    // 优化 1：使用更严谨的触底判断逻辑
    // pixels >= maxScrollExtent 是标准的触底判断
    if (position.pixels >= position.maxScrollExtent && !position.outOfRange) {
      _triggerCallback();
    }
  }

  void _triggerCallback() {
    if (_bottomCallback != null && !_isLoading) {
      _isLoading = true;
      _bottomCallback!();

      // 注意：这里 _isLoading 的重置通常需要配合业务逻辑（如请求结束）
      // 如果是简单的回调，可以直接重置，或由外部控制
    }
  }

  /// 修改：重置加载状态，供外部在数据加载完成后调用
  void resetLoadingState() {
    _isLoading = false;
  }

  // 修改：重写 dispose 而不是自定义 release，符合 Flutter 生命周期规范
  @override
  void dispose() {
    removeListener(_scrollListener);
    _bottomCallback = null; // 释放引用，防止内存泄漏
    super.dispose();
  }
}
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../util/Log.dart';

class BaseController extends GetxController {
  /// 存储当前 Controller 下所有的 CancelToken
  /// Key 可以是请求的 URL、方法名或者自定义的 Tag
  final Map<String, CancelToken> _cancelTokens = {};

  @override
  void onInit() {
    super.onInit();
    Log.d(" ======= $runtimeType onInit ========");
  }

  @override
  void onReady() {
    super.onReady();
    Log.d(" ======= $runtimeType onReady ========");
  }

  @override
  void onClose() {
    // Controller 销毁时，遍历并取消所有注册在内的请求
    _cancelTokens.forEach((tag, token) {
      if (!token.isCancelled) {
        token.cancel("请求取消  $tag disposed");
      }
    });
    _cancelTokens.clear();
    super.onClose();
    Log.d(" ======= $runtimeType onClose ======== ");
  }

  /// 获取或创建一个 CancelToken： 对于大多数随页面销毁而销毁的请求，直接使用默认 tag：
  /// [tag] 默认为 'default'，如果一个页面有多个独立请求，可以传入不同的 tag
  /// CancelToken 可以被多次调用 cancel()，但只有第一次生效，后续调用会被忽略。
  CancelToken getCancelToken([String tag = 'default']) {
    tag = _getTag(tag);
    var token = _cancelTokens[tag];
    // 最小改动：如果 token 存在且没被取消，直接用；否则（不存在或已取消）就覆盖并返回新的
    if (token != null && !token.isCancelled) {
      return token;
    }

    // 只要上面不符合，就直接新建并存入 Map
    final newToken = CancelToken();
    _cancelTokens[tag] = newToken;
    return newToken;
  }

  /// 手动取消特定的请求
  void cancelRequest(String tag) {
    tag = _getTag(tag);
    if (_cancelTokens.containsKey(tag)) {
      _cancelTokens[tag]?.cancel("User manually cancelled: $tag");
      _cancelTokens.remove(tag);
    }
  }

  String _getTag(String tag){
    return "$runtimeType-$tag";
  }
}

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_comm/app_running_info.dart';
import 'package:flutter_comm/util/Log.dart';
import 'package:flutter_comm/widget/toast_util.dart';


/// H5 深链统一入口
class DeepLinkLaunchUri {
  DeepLinkLaunchUri._();

  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;
  static bool isHomeHasInitState = false;
  static DeepLinkTask? curDeepLinkTask;

  /// 初始化监听（冷启动 + 热启动）。
  static Future<void> init() async {
    if (kIsWeb) return;
    await _sub?.cancel();
    _sub = _appLinks.uriLinkStream.listen(
      (uri){
        _onReceivedUri(uri);
      },
      onError: (Object e, StackTrace st) => Log.d('深链监听异常: $e $st'),
    );
  }


  static List<String> pathSegments(Uri uri) =>
      uri.pathSegments.where((s) => s.isNotEmpty).toList();

  /// 是否为 H5 约定的 custom scheme 深链。
  static bool isH5DeepLink(Uri uri) => uri.scheme == 'appBasePay' && uri.host == 'open';

  /// GoRouter 是否应拦截此次导航（平台自动深链，非应用内 `go`/`push`）。
  // static bool shouldBlockGoRouterNavigation(GoRouterState next) {
  //   final uri = next.uri;
  //   Log.d("shouldBlockGoRouterNavigation========next.uri:$uri");
  //   if (isH5DeepLink(uri)) {
  //     return true;
  //   }
  //   return false;
  // }

  static void _onReceivedUri(Uri uri) {
    if (!isH5DeepLink(uri)) return;
    handleDeepLink(uri);
  }

  static const String sceneKey = "scene";
  static const String payloadKey = "payload";

  static void handleDeepLink(Uri uri) {
    final scene = uri.queryParameters[sceneKey];
    String payload = uri.queryParameters[payloadKey] ?? "";
    Log.d('======== 深链 scene==:$scene');
    Log.d('======== 深链 payload==:$payload');
    double diffTimeOfReceivedTsToAppStartTs = AppRunningInfo.getDurationFromAppStartTsToCurTs();
    curDeepLinkTask = DeepLinkTask(createTs: DateTime.now().millisecondsSinceEpoch, uri: uri, diffTimeOfReceivedTsToAppStartTs: diffTimeOfReceivedTsToAppStartTs);
    ///  如果此时  home 页面已经初始化完毕 表示是热启动, 在这里 直接 处理深链
    if(isHomeHasInitState){
      checkAndHandleDeepLinkTask();
    }
  }

  /// 读取单个 query（H5 须对 value 做 [Uri.encodeComponent]）。
  static String? queryParam(Uri uri, String key) => uri.queryParameters[key];


  static Future<void> checkAndHandleDeepLinkTask({bool isOk = false}) async {
    if(curDeepLinkTask != null){
      final uri = curDeepLinkTask!.uri;

      final scene = uri.queryParameters[sceneKey];
      String payload = uri.queryParameters[payloadKey] ?? "";
      if(scene == 'merchant-transfer'){
        /// 这里要先判断用户是否已经实名认证了 和是否绑定了手机号或邮箱

        curDeepLinkTask = null;

        if(isOk){
          Toast.error(msg: "深链跳转目标页面的条件不满足");
          return;
        }
        if(payload.isNotEmpty){
         // toMerchantTransferPage(payload, ref);
        } else {
          Log.e("======= curDeepLinkTask 深链的payload 是空？=============");
        }
      } else {
        curDeepLinkTask = null;
        Log.d("为定义的深链 DeepLinkTask scene 直接清空任务");
      }
    } else {
      Log.d("没有检测到 深链 DeepLinkTask 任务");
     // ToastUtils.show(msg: "没有检测到 深链 DeepLinkTask 任务");
    }
  }
}

class DeepLinkTask{
  Uri uri;
  int createTs;
  double diffTimeOfReceivedTsToAppStartTs;
  DeepLinkTask({required this.uri, required this.createTs, required this.diffTimeOfReceivedTsToAppStartTs});

  /// 收到任务的时间 距离启动时间 小于2秒 算冷启动
  bool isColdStart(){
    return diffTimeOfReceivedTsToAppStartTs < 2;
  }
}

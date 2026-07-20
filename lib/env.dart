import 'package:flutter/foundation.dart';
import 'package:flutter_comm/util/Log.dart';
import 'package:flutter_comm/util/build_info_manager.dart';
import 'package:flutter_comm/util/network/domain_rotation.dart';
import 'package:flutter_comm/util/sp/secure_token_storage.dart';
import 'package:flutter_comm/util/sp/sp_util.dart';
import 'package:flutter_comm/util/sp/sp_util_key.dart';

import 'app_running_info.dart';

class Env {
  static String basePath = "/api/";
  static String baseUrl = "";
  static List<String> backupProdBaseUrlList = ['https://baidu12345.vip'];

  /// 开发内部使用 发布 变动频繁
  static void setLocalTestEvn() {
    baseUrl = "http://192.168.6.100:8080";
  }

  /// 正宗 测试环境
  static void setTestEvn() {
    baseUrl = "https://api.baidu87878.vs";
  }

  static void setProductionEvn() {
    baseUrl = backupProdBaseUrlList[0];
  }

  static void setBaseUrl(String baseUrl) {
    Env.baseUrl = baseUrl;
  }

  static String getFullUrl(String path) {
    return "${Env.baseUrl}$basePath$path";
  }
  static String getH5BaseUrl() {
    return Env.baseUrl;
  }

  static void setupDefaultBaseUrl(){
    var appEnv = BuildInfo.getCurUseEnv();
    switch (appEnv) {
      case testEnvName:
        setTestEvn();
        break;
      case localTestEnvName:
        setLocalTestEvn();
        break;
      case proEnvName:
      case proTestEnvName:
        setProductionEvn();
        break;
      default:
        setProductionEvn();
        break;
    }
    Log.d("==setupDefaultBaseUrl===appEnv：$appEnv====baseUrl=>$baseUrl====kDebugMode:$kDebugMode====");
  }

  /// 返回是否第一个请求 成功， 只有生产环境会根据实际情况返回
  static Future<bool> initEnv(List<String> remoteUrlList) async {
    bool isFirstApiRequestSuccess = false;
    var appEnv = BuildInfo.getCurUseEnv();
    Log.d("==initEnv===appEnv：$appEnv========remoteUrlList:$remoteUrlList=========");
    switch (appEnv) {
      case testEnvName:
        setTestEvn();
        isFirstApiRequestSuccess = true;
        break;
      case localTestEnvName:
        setLocalTestEvn();
        isFirstApiRequestSuccess = true;
        break;
      case proEnvName:
      case proTestEnvName:
      /// 以免覆盖splash 页面设置的最近请求成功的baseUrl
        if(baseUrl.isEmpty){
          setProductionEvn();
        }
        // 探测路径必须用真实 API 路径，避免 '/' 返回 403/404 也被当作“可用域名”
        final domainCheckApi = "app-version/check?currVersion=${AppRunningInfo.info?.version}";
        isFirstApiRequestSuccess = await setReachableBaseUrl(
          candidatesUrlList: remoteUrlList,
          probePath: "${Env.basePath}$domainCheckApi",
        );
        break;
      default:
        setProductionEvn();
        isFirstApiRequestSuccess = true;
        break;
    }

    /// 初始化环境完毕后，要获取保存到本地的环境名字，如果环境发生变化，清除本地的所有数据缓存，包含token等， 然后重新保存最新的环境名字到本地
    await _syncPersistedEnvAndClearIfNeeded(appEnv);
    Log.d("======当前环境信息=====：${BuildInfo.getInfo()}");
    return isFirstApiRequestSuccess;
  }

  static Future<void> _syncPersistedEnvAndClearIfNeeded(String currentEnvName) async {
    try {
      final lastEnvName = spUtil.getString(PrefKeys.strLastEnvName, def: '') ?? '';
      bool isEnvDiff = lastEnvName.isNotEmpty && lastEnvName != currentEnvName;
      if (isEnvDiff) {
        // 环境发生变化：清空本地缓存（含 token 等）。
        spUtil.clear();
        await SecureTokenStorage.clearAll();
        // AuthMemoryCache.clear();
        if (BuildInfo.isTestBuildMode()) {
          /// 恢复测试模式下 设置的环境
          await spUtil.setString(BuildInfo.curEnvKeyOfDev, currentEnvName);
        }
      }
      Log.d("当前环境和缓存的旧环境是否改变 isEnvDiff：$isEnvDiff ");
      // 保存最新环境名（无论是否变化）。
      await spUtil.setString(PrefKeys.strLastEnvName, currentEnvName);
    } catch (e) {
      Log.e("环境初始化异常：$e");
    }
  }

  /// 启动时设置可达 baseUrl（防域名封锁）：
  /// - 默认优先从本地缓存读取候选域名列表

  static Future<bool> setReachableBaseUrl({
    List<String>? candidatesUrlList,
    String probePath = '/',
  }) async {
    final cachedBaseUrlList = DomainRotation.loadCachedCandidates();
    Log.d("域名轮训前 已经缓存的域名有$cachedBaseUrlList");
    final lastGood = DomainRotation.loadLastGood();
    /// 优先级：1.最近OK域名  2.缓存域名列表 3.写死的域名。4.服务器返回的最新域名
    var candidates = _dedupeCandidates(<String>[
      if (lastGood.isNotEmpty) lastGood,
      ...?candidatesUrlList,
      ...cachedBaseUrlList,
      ...backupProdBaseUrlList,
    ]);
    candidates = DomainRotation.normalizeAndDeduplicateBaseUrls(candidates);
    Log.d("=======参与竞选的所有域名是:$candidates lastGood=$lastGood ");
    String? reachableUrl = await DomainRotation.pickFirstReachable(
      tarBaseUrlList: candidates,
      probePath: probePath,
      timeout: const Duration(seconds: 4),
      concurrency: 3,
      globalDeadline: const Duration(seconds: 18),
    );
    if (reachableUrl == null || reachableUrl.isEmpty) {
      Log.e("域名轮询未找到可达域名（候选=${candidates.length}）");
      return false;
    }
    Env.setBaseUrl(reachableUrl);
    Log.d("最终设置的生产环境域名是 setup BaseUrl=>：$reachableUrl");
    return true;
  }


  static List<String> _dedupeCandidates(Iterable<String> input) {
    final result = <String>[];
    final seen = <String>{};
    for (final raw in input) {
      final v = raw.trim();
      if (v.isEmpty) continue;
      if (seen.add(v)) result.add(v);
    }
    return result;
  }
}

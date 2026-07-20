import 'dart:async';

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_comm/app_running_info.dart';
import 'package:flutter_comm/http/core/log_interceptor.dart';
import 'package:flutter_comm/util/Log.dart';
import 'package:flutter_comm/util/build_info_manager.dart';
import 'package:flutter_comm/util/sp/sp_util.dart';

import 'bootstrap/app_dada_cache.dart';


/// 域名轮询工具：
/// - 传入多个候选域名（可带/不带 scheme）
/// - 合并本地缓存的候选域名，优先探测“最近成功域名”
/// - 返回第一个可用的 baseUrl（可用于 Env.baseUrl）
class DomainRotation {
  DomainRotation._();

  static const int _maxPersistedCandidates = 30;
  static const int _defaultConcurrency = 4;
  static const Duration _defaultGlobalDeadline = Duration(seconds: 3);

  static const apiDomainCandidateListKey = 'ApiDomainCandidateListKey';
  static const apiBaseUrlLastGoodKey = 'ApiBaseUrlLastGoodKey';
  static bool _sameList(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// 规范化 baseurl 然后 去除重复
  static List<String> normalizeAndDeduplicateBaseUrls(List<String> input) {
    final result = <String>[];
    final seen = <String>{};
    for (final raw in input) {
      final v = _normalizeBaseUrl(raw);
      if (v.isEmpty) continue;
      /// 去重复后加入
      if (seen.add(v)) result.add(v);
    }
    return result;
  }

  /// 规范化 baseUrl：
  /// - 去空格
  /// - 不带 scheme 的默认补 `https://`
  /// - 去掉末尾 `/`
  static String _normalizeBaseUrl(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return '';

    String url = v;
    if (!(url.startsWith('http://') || url.startsWith('https://'))) {
      url = 'https://$url';
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  /// 读取本地缓存的候选域名（已规范化、去重）。
  static List<String> _loadPersistedCandidates() {
    try {
      final list = spUtil.getStringList(apiDomainCandidateListKey) ?? const <String>[];
      return normalizeAndDeduplicateBaseUrls(list);
    } catch (_) {
      return const <String>[];
    }
  }

  /// 对外：读取本地缓存的候选域名列表（已规范化、去重）。
  static List<String> loadCachedCandidates() => _loadPersistedCandidates();

  /// 保存候选域名到本地（会自动规范化、去重、裁剪长度）。
  static Future<void> _persistCandidates(List<String> candidates) async {
    final normalized = normalizeAndDeduplicateBaseUrls(candidates);
    final clipped = normalized.take(_maxPersistedCandidates).toList(growable: false);
    try {
      final old = spUtil.getStringList(apiDomainCandidateListKey) ?? const <String>[];
      final oldNormalized = normalizeAndDeduplicateBaseUrls(old);
      if (_sameList(oldNormalized, clipped)) {
        Log.d("域名候选未变化，跳过写入本地：count=${clipped.length}");
        return;
      }
      await spUtil.setStringList(apiDomainCandidateListKey, clipped);
      Log.d("保存到本地的域名数目是：${clipped.length}  list: $clipped");
    } catch (e, s) {
      Log.e('保存候选域名列表失败：$e', e, s);
    }
  }

  /// 对外：更新并保存本地域名候选列表（StringList）。
  /// 常见用法：拿到可达 baseUrl 后，请求“备份域名列表”接口，再把最新列表写回本地。
  static Future<void> saveCandidates(List<String> candidates) => _persistCandidates(candidates);

  /// 保存最近一次探测成功的 baseUrl。
  static Future<void> _persistLastGood(String baseUrl) async {
    final v = _normalizeBaseUrl(baseUrl);
    if (v.isEmpty) return;
    try {
      final old = _normalizeBaseUrl(spUtil.getString(apiBaseUrlLastGoodKey));
      if (old == v) {
        Log.d("lastGood 未变化，跳过写入本地LastGood BaseUrl：$v");
        return;
      }
      await spUtil.setString(apiBaseUrlLastGoodKey, v);
      Log.d("写入本地的 LastGood BaseUrl=>：$v");
    } catch (e, s) {
      Log.e('保存最近一次可用域名失败：$e', e, s);
    }
  }

  static String loadLastGood() {
    try {
      return _normalizeBaseUrl(spUtil.getString(apiBaseUrlLastGoodKey));
    } catch (_) {
      return '';
    }
  }

  /// 探测某个 baseUrl 是否可用。
  ///
  /// [probePath] 建议传一个“稳定且轻量”的路径（例如健康检查/配置接口等）。
  /// 若不传，默认探测 `/`。
  static Future<bool> _probeReachable(
    String baseUrl, {
    String probePath = '/',
    Duration timeout = const Duration(seconds: 2),
  }) async {
    return _probeReachableCancellable(
      baseUrl,
      probePath: probePath,
      timeout: timeout,
      cancelToken: null,
    );
  }

  static Future<bool> _probeReachableCancellable(
    String baseUrl, {
    required String probePath,
    required Duration timeout,
    CancelToken? cancelToken,
    int? requestIndex,
  }) async {
    final normalized = _normalizeBaseUrl(baseUrl);
    if (normalized.isEmpty) return false;

    final path = probePath.trim().isEmpty ? '/' : probePath.trim();
    final url = path.startsWith('/') ? '$normalized$path' : '$normalized/$path';

    BaseOptions options = BaseOptions(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      responseType: ResponseType.plain,
      validateStatus: (status) => status != null && status < 600,
      followRedirects: true,
      maxRedirects: 3,
    );
    final dio = Dio(options);
    dio.interceptors.add(SingleLogInterceptor("域名轮训"));
    if(BuildInfo.isUseChuker()){
      dio.interceptors.add(ChuckerDioInterceptor());
    }
    final info = AppRunningInfo.info;
    options.headers["Platform"] = AppRunningInfo.platform();
    options.headers["Version"] = info?.version ?? "";
    options.headers["BuildNumber"] = info?.buildNumber ?? "";
    try {
      Log.d('开始 域名探测：requestIndex:$requestIndex  $url');
      final resp = await dio.get<dynamic>(url, cancelToken: cancelToken);
      final code = resp.statusCode;
      // 启动期“选用域名”必须保证 API 可用，不能把 403/404 当成可用域名，否则会把“能连上但不可用”的域名持久化成 lastGood。
      // 这里按「成功响应」判定：2xx/3xx 视为可用。
      final ok = code != null && code >= 200 && code < 400;
      Log.d('域名探测 结果：requestIndex:$requestIndex $url 状态码=$code 可用=$ok');
      if (ok) {
        AppDataCache.save(AppDataCache.appVersionCheckKey, resp.data);
      }
      return ok;
    } catch (e) {
      if(e is DioException){
        if(e.type == DioExceptionType.cancel){
          return false;
        }
      }
      Log.d('域名探测失败：$url 错误=$e');
      return false;
    } finally {
      dio.close(force: true);
    }
  }

  /// 轮询选取一个可用域名并返回（返回值为规范化后的 baseUrl）。
  /// - 会优先探测“最近成功域名”
  /// - 探测成功后会更新本地缓存：最近成功域名 + 合并后的候选列表
  static Future<String?> pickFirstReachable({
    required List<String> tarBaseUrlList,
    String probePath = '/',
    Duration timeout = const Duration(seconds: 6),
    int concurrency = _defaultConcurrency,
    Duration globalDeadline = _defaultGlobalDeadline,
  }) async {
    int curTs = DateTime.now().millisecondsSinceEpoch;
    if (tarBaseUrlList.isEmpty) return null;
    AppDataCache.clear();
    Log.d('域名轮询开始：候选数量=${tarBaseUrlList.length}');
    final int limit = concurrency <= 0 ? 1 : concurrency;
    final deadlineAt = DateTime.now().add(globalDeadline);
    final tokens = <CancelToken>[];
    bool picked = false;
    int requestIndex = 0;
    Future<String?> runBatch(List<String> batch) async {
      final completer = Completer<String?>();
      int completed = 0;
      void tryCompleteNull() {
        if (!completer.isCompleted && completed >= batch.length) {
          completer.complete(null);
        }
      }
      for (final baseUrl in batch) {
        if (picked) break;
        final token = CancelToken();
        tokens.add(token);
        // batch 内并发探测；任意成功则立刻完成。
        // ignore: unawaited_futures
        _probeReachableCancellable(
          baseUrl,
          probePath: probePath,
          timeout: timeout,
          cancelToken: token,
          requestIndex: requestIndex++,
        ).then((ok) {
          completed += 1;
          if (picked) return;
          if (ok && !completer.isCompleted) {
            completer.complete(baseUrl);
            return;
          }
          tryCompleteNull();
        }).catchError((_) {
          completed += 1;
          tryCompleteNull();
        });
      }

      return completer.future;
    }

    String? chosen;
    for (int i = 0; i < tarBaseUrlList.length; i += limit) {
      if (DateTime.now().isAfter(deadlineAt)) {
        Log.d('域名轮询达到截止时间（本批次开始前）');
        break;
      }
      final batch = tarBaseUrlList.sublist(i, (i + limit).clamp(0, tarBaseUrlList.length));
      final remain = deadlineAt.difference(DateTime.now());
      if (remain <= Duration.zero) break;
      try {
        chosen = await runBatch(batch).timeout(remain);
      } catch (_) {
        chosen = null;
      }

      if (chosen != null && chosen.isNotEmpty) {
        picked = true;
        break;
      }
    }

    if (picked && chosen != null) {
      for (final t in tokens) {
        if (!t.isCancelled) {
          t.cancel('已选出可用域名，取消其它探测 chosen：$chosen');
        }
      }
      Log.d('===========域名探测完毕 轮询选中：$chosen  耗时：${AppRunningInfo.getDurationFromTarTsToCurTs(curTs)}');
      // 持久化不阻塞启动：下次冷启动仍可从内存中的 Env.baseUrl 与已有缓存读取。
      unawaited(_persistLastGood(chosen));
      return chosen;
    }

    // 超时/全失败：取消仍在进行的探测
    for (final t in tokens) {
      if (!t.isCancelled) {
        t.cancel('域名轮询超时/失败，取消探测');
      }
    }

    Log.d('域名轮询失败：没有可用域名');
    return null;
  }
}


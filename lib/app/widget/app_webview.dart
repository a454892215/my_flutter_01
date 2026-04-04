import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../app_style.dart';
import 'app_header.dart';

enum ProgressIndicatorType { circular, linear }

/// [AppWebView] 通用网页容器组件
///
/// ### 核心功能：
/// 1. **混合集成渲染**：基于 `flutter_inappwebview`
/// 2. **自定义进度反馈**：提供线性 (Linear) 和圆形 (Circular) 两种加载进度展示。
/// 3. **动态 AppBar 交互**：支持 AppBar 的显示隐藏控制，适配沉浸式状态栏。
/// 4. **URL 拦截机制**：支持特定 Scheme (如 `brazilapp://`) 的深度链接拦截与业务处理。
/// 5. **物理返回键适配**：集成 `PopScope` 拦截 Android 物理返回键，实现「优先网页回退，无历史记录再退出页面」的逻辑。
class AppWebView extends StatefulWidget {
  const AppWebView({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  final GlobalKey _webViewKey = GlobalKey();
  late final InAppWebViewController? _webViewController;

  // 使用 ValueNotifier 替代 setState 刷新整个页面，仅局部刷新进度条
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);


  @override
  void dispose() {
    // 及时释放监听器，防止内存泄漏
    _progressNotifier.dispose();
    super.dispose();
  }

  /// 封装加载进度指示器，减少 build 方法冗余
  Widget _buildProgressIndicator(ProgressIndicatorType type) {
    return ValueListenableBuilder<double>(
      valueListenable: _progressNotifier,
      builder: (context, progress, child) {
        if (progress >= 1.0) return const SizedBox.shrink();

        if (type == ProgressIndicatorType.circular) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white.withAlpha(70),
              ),
              child: const CircularProgressIndicator(),
            ),
          );
        }

        return SizedBox(
          height: 2,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff011A51)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Android 原生开发者习惯：处理物理返回键拦截
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final controller = _webViewController;
        if (controller != null && await controller.canGoBack()) {
          await controller.goBack();
        } else {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(0, 10, 30, 1),
        // 优化 AppBar 高度计算，直接使用系统自动处理，除非有特殊动态隐藏需求
        appBar: widget.title.isNotEmpty
            ? AppBar(
          titleSpacing: 0,
          leadingWidth: 0,
          backgroundColor: appStyle.headerBgColor,
          title: AppHeader(title: widget.title),
          // 如果需要高度动画，保留 PreferredSize，否则直接使用 AppBar
        )
            : null,
        // 去掉多余的 Column/Expanded 嵌套，直接使用 Stack 铺满 Body
        body: Stack(
          children: [
            InAppWebView(
              key: _webViewKey,
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                // 性能与基础配置
                useShouldOverrideUrlLoading: true,
                useOnDownloadStart: true,
                mediaPlaybackRequiresUserGesture: false,
                javaScriptCanOpenWindowsAutomatically: true,
                transparentBackground: true,
                // 开启缓存加速，类似 Android WebSettings.LOAD_DEFAULT
                cacheMode: CacheMode.LOAD_DEFAULT,
                supportZoom: true,

                // iOS 配置
                allowsInlineMediaPlayback: true,
                isFraudulentWebsiteWarningEnabled: false,

                // Android 配置
                useHybridComposition: true, // 6.x 对混合集成已稳定，建议开启处理层级渲染
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onProgressChanged: (controller, progress) {
                // 局部更新进度，不触发 Widget build
                _progressNotifier.value = progress / 100.0;
              },
              onConsoleMessage: (controller, consoleMessage) {
                debugPrint("WebView Console: ${consoleMessage.message}");
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url;
                if (uri != null && uri.scheme == 'dzmbxxxapp') {
                  // 告诉webView 取消加载
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
            ),
            // 将进度条置于顶层
            _buildProgressIndicator(ProgressIndicatorType.linear),
          ],
        ),
      ),
    );
  }
}
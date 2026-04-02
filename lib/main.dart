import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_comm/screnn_info.dart';
import 'package:flutter_comm/skin/skin_factory.dart';
import 'package:flutter_comm/skin/skin_manager.dart';
import 'package:flutter_comm/util/Log.dart';
import 'package:flutter_comm/widget/loading_util.dart';
import 'package:flutter_comm/util/sp/sp_util.dart';
import 'package:flutter_comm/util/system_util.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/observers/route_observer.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'app/routes/app_pages.dart';
import 'app_config.dart';
import 'err_page.dart';
import 'globe_exception_catch.dart';
import 'navigator/observer.dart';

void main() async {
  GlobeExceptionHandler().init(() async {
    // WidgetsFlutterBinding.ensureInitialized(); // 保证 WidgetsBindingObserver使用时候，已经初始化
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await spUtil.init();
    await SkinManager.instance.init();
    await SysUtil.init();
    if (Platform.isAndroid) {
      /// 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Color.fromRGBO(3, 11, 29, 1),
        ),
      );
    }
    runApp(
      ListenableBuilder(
        listenable: SkinManager.instance,
        builder: (context, child) {
          return GetMaterialAppConfig();
        },
      ),
    );
  });
  //FlutterChain.capture(() => runApp(buildScreenUtilInit(child: getRootWidget())));
}

class RefreshConfigurationWidget extends StatelessWidget {
  const RefreshConfigurationWidget(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      headerBuilder: () => const ClassicHeader(
        //  refreshStyle: RefreshStyle.Follow,
        completeDuration: Duration(milliseconds: 0),
        refreshingIcon: CupertinoActivityIndicator(),
      ),
      footerBuilder: () =>
          const ClassicFooter(loadingIcon: CupertinoActivityIndicator()),

      /// 回收刷新头过程 会回收越界 隐藏部分头部内容，然后再次上滚显示隐藏的内容 造成了回弹，通过springDescription调整，消除回收越界
      springDescription: const SpringDescription(
        mass: 1.5, // 质量，越大 惯性越大
        stiffness: 120, // 刚度越大，拉力/推力越强
        damping: 30, // 阻尼越大，能量耗散越快
      ),

      /// Header 最大可以被拉出的越界距离
      maxOverScrollExtent: 380,

      /// 底部加载更多 越界多少算触底
      bottomHitBoundary: 0,

      /// 关键：刷新结束后，允许在回弹时即刻触发下次滚动
      enableScrollWhenRefreshCompleted: true,

      /// 下拉刷新触发距离
      headerTriggerDistance: 80,

      /// 加载更多触发距离
      footerTriggerDistance: 20,

      ///阻尼系数。手动拖动时的速度比例，数值越大拖动越轻松，默认 1.0
      dragSpeedRatio: 0.8,

      /// 当内容不满一页时，Footer 是紧跟在内容后面，还是固定在底部
      shouldFooterFollowWhenNotFull: (LoadStatus? status) {
        return false;
      },
      hideFooterWhenNotFull: false,

      /// enableBallisticLoad 是否启动惯性滑动 加载更多
      enableBallisticLoad: true,

      /// 是否启动惯性滑动 刷新? 无效--需要配合BouncingScrollPhysics才能触发惯性滚动
      enableBallisticRefresh: true,
      child: Builder(
        builder: (context) {
          Log.d("===RefreshConfigurationWidget 根页面重构？===Builder========");
          return child;
        },
      ),
    );
  }
}

class GetMaterialAppConfig extends StatelessWidget {
  const GetMaterialAppConfig({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenInfo.init(context);
    AppLoading.initLoading();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      /// 仅在非 Release 模式（即 Debug 或 Profile）下显示:!kReleaseMode
      showPerformanceOverlay: false,// 性能图层
      enableLog: false,
      /// title 只对Android生效，ios种，任务视图名称取的是 Info.pList 文件中的CFBundleDisplayName或CFBundleName
      title: "LB88",
      /// 4. Theme.of方法可以获取当前的 ThemeData，MaterialDesign种有些样式不能自定义，比如导航栏高度
// 始终将当前计算出的皮肤给 theme
      theme: SkinManager.instance.currentTheme,
      // 只有在模式为 system 时，才需要提供暗色兜底，否则只看 theme 即可
      darkTheme: SkinFactory.createTheme(SkinType.black),
      themeMode: SkinManager.instance.themeMode,
      // 自动同步系统主题或手动锁定
      // 将 Transition.noTransition 改为以下之一：
      defaultTransition: Transition.native,
      // 自动适配平台原生效果
      // defaultTransition: Transition.rightToLeft, // 强制左右滑动
      /// routes 路由配置：对象是Map<String, WidgetBuilder>
      // routes: [], 这种方式配置路由，defaultTransition 不能生效
      getPages: AppPages.routes,

      /// 与 routes 中的 / 效果基本一致， 指定应用的第一个显示页面
      /// /// home 与 routes配置的 / 互斥 同时配置会抛异常
      initialRoute: AppPages.INITIAL,
      initialBinding: AppInitBinding(context),

      /// 配置404页面: 如果路由不存在则跳到该页面
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (BuildContext context) => const ErrPage(),
        );
      },
      builder: EasyLoading.init(
        builder: (context, widget) {
          return RefreshConfigurationWidget(
            MediaQuery(
              ///设置文字大小不随系统设置改变
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: FlutterSmartDialog.init()(context, widget),
            ),
          );
        },
      ),

      /// 配置页面离开和进入的监听
      navigatorObservers: [
        MyNavigatorObserver(),
        routeObserver,
        FlutterSmartDialog.observer,
        appNavigatorObserver,
      ],
      routingCallback: (Routing? routing) {},
    );
  }
}

import 'package:flutter/material.dart';

import '../modules/ApiUsageTemplate/views/api_usage_template_view.dart';
import '../modules/english_learn/views/english_learn_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/log/views/log_view.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final Map<String, WidgetBuilder> routes = {
    _Paths.SPLASH: (_) => const SplashView(),
    _Paths.HOME: (_) => const HomeView(),
    _Paths.API_USAGE_TEMPLATE: (_) => const ApiUsageTemplateView(),
    _Paths.ENGLISH_LEARN: (_) => const EnglishLearnView(),
    _Paths.LOG: (_) => const LogView(),
  };
}

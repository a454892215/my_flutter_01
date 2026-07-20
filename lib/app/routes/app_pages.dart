import 'package:flutter/material.dart';

import '../modules/ApiUsageTemplate/views/api_usage_template_view.dart';
import '../modules/english_learn/views/english_learn_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/log/views/log_view.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final Map<String, WidgetBuilder> routes = {
    Routes.splash: (_) => const SplashView(),
    Routes.home: (_) => const HomeView(),
    Routes.apiUsageTemplate: (_) => const ApiUsageTemplateView(),
    Routes.englishLearn: (_) => const EnglishLearnView(),
    Routes.log: (_) => const LogView(),
  };
}

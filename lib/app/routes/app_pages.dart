import 'package:get/get.dart';

import '../modules/ApiUsageTemplate/bindings/api_usage_template_binding.dart';
import '../modules/ApiUsageTemplate/views/api_usage_template_view.dart';
import '../modules/english_learn/bindings/english_learn_binding.dart';
import '../modules/english_learn/views/english_learn_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/log/bindings/log_binding.dart';
import '../modules/log/views/log_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.API_USAGE_TEMPLATE,
      page: () => ApiUsageTemplateView(),
      binding: ApiUsageTemplateBinding(),
    ),
    GetPage(
      name: _Paths.ENGLISH_LEARN,
      page: () => const EnglishLearnView(),
      binding: EnglishLearnBinding(),
    ),
    GetPage(
      name: _Paths.LOG,
      page: () => const LogView(),
      binding: LogBinding(),
    ),
  ];
}

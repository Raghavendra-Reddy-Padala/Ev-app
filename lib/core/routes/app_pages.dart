import 'package:get/get.dart';
import 'package:mjollnir/features/authentication/views/auth_view.dart';
import 'package:mjollnir/features/authentication/views/register_view.dart';
import 'package:mjollnir/features/main_page.dart';

import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => AuthView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => SignupScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => MainPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}

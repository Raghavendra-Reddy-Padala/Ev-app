import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bolt_ui_kit/bolt_kit.dart';
import 'core/api/api_constants.dart';
import 'core/di/dependency_injection.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart' as own;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final ApiService apiService = ApiService(ApiConstants.baseUrl);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppColors.initialize(
    primary: Colors.green,
    accent: Colors.red,
  );
  await BoltKit.initialize(
    primaryColor: AppColors.primary,
    accentColor: AppColors.accent,
    fontFamily: 'Poppins',
    navigatorKey: navigatorKey,
  );
  await setupDependencies();
  final LocalStorage localStorage = Get.find();
  localStorage.setBool('useDummyToken', false);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localStorage = Get.find<LocalStorage>();
    final String initialRoute =
        localStorage.isLoggedIn() ? Routes.HOME : Routes.LOGIN;
    return BoltKit.builder(
      designSize: const Size(391, 852),
      
      builder: () {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: own.AppTheme.lightTheme(),
          darkTheme: own.AppTheme.darkTheme(),
          themeMode: ThemeMode.system,
          navigatorKey: navigatorKey,
          title: 'Mjollnir',
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
          initialRoute: initialRoute,
          getPages: AppPages.routes,
          defaultTransition: Transition.fadeIn,
          translationsKeys: {},
          locale: Get.deviceLocale,
          fallbackLocale: const Locale('en', 'US'),
        );
      },
    );
  }
}

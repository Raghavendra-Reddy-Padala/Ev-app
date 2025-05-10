import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bolt_ui_kit/bolt_kit.dart';

import 'core/api/api_constants.dart';
import 'core/di/dependency_injection.dart';
import 'features/authentication/views/splash.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final ApiService apiService = ApiService(ApiConstants.baseUrl);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BoltKit.initialize(
    primaryColor: AppColors.primary,
    accentColor: AppColors.accent,
    fontFamily: 'Poppins',
    navigatorKey: navigatorKey,
  );
  await setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(391, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.lightTheme(),
          themeMode: ThemeMode.light,
          navigatorKey: navigatorKey,
          title: 'Mjollnir',
          builder: (context, child) {
            ScreenUtil.init(context);
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
          home: child,
        );
      },
      child: const Splash(),
    );
  }
}

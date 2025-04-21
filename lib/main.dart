import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mjollnir/app/utils/helpers.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Controllers().initControllers();
  await BoltKit.initialize(
    primaryColor: Color(0xFFFF9330),
    accentColor: Color(0xFFFFE8CE),
    fontFamily: 'Poppins',
    navigatorKey: navigatorKey,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return BoltKit.builder(
      designSize: const Size(393, 852),
      builder: () => GetMaterialApp(
        title: 'Mjollnir',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        defaultTransition: Transition.fadeIn,
        translationsKeys: {},
        locale: Get.deviceLocale,
        fallbackLocale: Locale('en', 'US'),
      ),
    );
  }
}

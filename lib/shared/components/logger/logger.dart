import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static const String _tag = '🌟 App';

  static void i(String message) {
    if (kDebugMode) {
      print('$_tag [INFO] $message');
    }
  }

  static void d(String message) {
    if (kDebugMode) {
      print('$_tag [DEBUG] $message');
    }
  }

  static void w(String message) {
    if (kDebugMode) {
      print('$_tag [WARNING] $message');
    }
  }

  static void e(String message) {
    if (kDebugMode) {
      print('$_tag [ERROR] $message');
    }
  }
}

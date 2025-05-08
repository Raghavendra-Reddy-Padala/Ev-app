import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = navigatorKey;

  static Future<T?> pushTo<T>(Widget newRoute) {
    return navigatorKey.currentState!.push<T>(
      MaterialPageRoute(builder: (context) => newRoute),
    );
  }

  static Future<T?> pushReplacementTo<T, TO>(Widget newRoute) {
    return navigatorKey.currentState!.pushReplacement<T, TO>(
      MaterialPageRoute(builder: (context) => newRoute),
    );
  }

  static void pop<T>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }

  static Future<T?> pushAndRemoveUntil<T>(
      Widget newRoute, bool Function(Route<dynamic>) predicate) {
    return navigatorKey.currentState!.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (context) => newRoute),
      predicate,
    );
  }

  static void popUntil(bool Function(Route<dynamic>) predicate) {
    navigatorKey.currentState?.popUntil(predicate);
  }

  static Future<T?> pushToWithCallback<T>(
      Widget newRoute, VoidCallback onReturn) {
    return navigatorKey.currentState!
        .push<T>(MaterialPageRoute(builder: (context) => newRoute))
        .then((result) {
      onReturn();
      return result;
    });
  }

  static Future<T?> pushNamedTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed<T>(routeName, arguments: arguments);
  }
}

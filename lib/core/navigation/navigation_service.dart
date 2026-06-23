import 'package:flutter/material.dart';

class NavigationService {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static void navigateToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }
}

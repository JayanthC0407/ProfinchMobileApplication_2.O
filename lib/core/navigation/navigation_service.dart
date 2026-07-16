import 'package:flutter/material.dart';

/// Gives non-widget code (e.g. [SessionManager]'s session-expiry handling)
/// a way to navigate, since it has no BuildContext of its own. Attach this
/// key to [MaterialApp.navigatorKey] in main.dart.
class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
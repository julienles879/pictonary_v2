import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _prefix = '🎮 PICTONARY';

  // Couleurs pour les différents types de logs
  static void auth(String message) {
    debugPrint('$_prefix 🔐 [AUTH] $message');
  }

  static void api(String message) {
    debugPrint('$_prefix 🌐 [API] $message');
  }

  static void game(String message) {
    debugPrint('$_prefix 🎯 [GAME] $message');
  }

  static void challenge(String message) {
    debugPrint('$_prefix 🎨 [CHALLENGE] $message');
  }

  static void navigation(String message) {
    debugPrint('$_prefix 📱 [NAV] $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('$_prefix ❌ [ERROR] $message');
    if (error != null) {
      debugPrint('$_prefix ❌ [ERROR] Details: $error');
    }
    if (stackTrace != null) {
      debugPrint('$_prefix ❌ [ERROR] Stack: $stackTrace');
    }
  }

  static void success(String message) {
    debugPrint('$_prefix ✅ [SUCCESS] $message');
  }

  static void info(String message) {
    debugPrint('$_prefix ℹ️  [INFO] $message');
  }

  static void debug(String message) {
    debugPrint('$_prefix 🔍 [DEBUG] $message');
  }
}

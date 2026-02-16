import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(Object? message, {String? tag}) {
    if (kReleaseMode) return; // Ne rien logger en production
    final prefix = tag != null ? '[$tag] ' : '';
    // use debugPrint to avoid truncation in long messages
    debugPrint('$prefix${message.toString()}');
  }

  static void error(Object? message, {String? tag}) {
    if (kReleaseMode) return;
    final prefix = tag != null ? '[ERROR][$tag] ' : '[ERROR] ';
    debugPrint('$prefix${message.toString()}');
  }
}

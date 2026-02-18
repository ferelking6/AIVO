import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static File? _logFile;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final appCacheDir = await getTemporaryDirectory();
      final logsDir = Directory('${appCacheDir.path}/AIVO/logs');

      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toString().replaceAll(RegExp(r'[^0-9-]'), '-').substring(0, 19).replaceAll('-', '_');
      _logFile = File('${logsDir.path}/aivo_$timestamp.log');
      _isInitialized = true;

      debugPrint('[AppLogger] Logging initialized at: ${_logFile!.path}');
    } catch (e) {
      debugPrint('[AppLogger] Failed to initialize logging: $e');
    }
  }

  static String _getTimestamp() {
    return DateTime.now().toIso8601String();
  }

  static Future<void> _writeToFile(String message) async {
    try {
      if (_logFile != null) {
        await _logFile!.writeAsString('$message\n', mode: FileMode.append);
      }
    } catch (e) {
      debugPrint('[AppLogger] Failed to write to log file: $e');
    }
  }

  static void log(Object? message, {String? tag}) {
    final timestamp = _getTimestamp();
    final prefix = tag != null ? '[$tag]' : '';
    final formattedMessage = '$timestamp $prefix ${message.toString()}';

    if (!kReleaseMode) {
      debugPrint(formattedMessage);
    }

    _writeToFile(formattedMessage);
  }

  static void error(Object? message, {String? tag}) {
    final timestamp = _getTimestamp();
    final prefix = tag != null ? '[ERROR][$tag]' : '[ERROR]';
    final formattedMessage = '$timestamp $prefix ${message.toString()}';

    if (!kReleaseMode) {
      debugPrint(formattedMessage);
    }

    _writeToFile(formattedMessage);
  }
}

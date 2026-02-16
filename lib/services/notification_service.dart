import 'dart:async';
import 'package:aivo/utils/app_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<Map<String, dynamic>> _notificationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStreamController.stream;

  /// Initialize Local Notifications
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosInitializationSettings =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationTap(response.payload);
        },
      );

      AppLogger.log('Notifications initialized', tag: 'NotificationService');
    } catch (e) {
      AppLogger.error('Error initializing notifications: $e', tag: 'NotificationService');
    }
  }

  /// Handle local notification tap
  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      AppLogger.log('Notification tapped with payload: $payload', tag: 'NotificationService');
      _notificationStreamController.add({'payload': payload});
    }
  }

  /// Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic> payload = const {},
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'aivo_channel',
      'AIVO Notifications',
      channelDescription: 'AIVO e-commerce notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload.toString(),
    );
  }

  /// Dispose resources
  void dispose() {
    _notificationStreamController.close();
  }
}

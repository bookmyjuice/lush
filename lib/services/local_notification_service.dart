import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// BR-060/061/062: Local notification service for displaying notifications
/// received via FCM server push. Uses flutter_local_notifications to show
/// notifications on the device when the app is in the foreground.
/// Triggered by FirebaseNotificationService on receiving FCM messages.
class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service and timezone. Call once at app startup.
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
    _initialized = true;
  }

  /// Show an immediate notification (e.g., payment failed).
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'bookmyjuice_channel',
      'BookMyJuice',
      channelDescription: 'Notifications for orders, subscriptions, and payments',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      id:id,
      title: title,
      body: body,notificationDetails: 
      notificationDetails,
      payload: payload,
    );
  }

  /// Cancel a previously scheduled or shown notification.
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id:id);
  }

  /// Cancel all notifications.
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:lush/services/local_notification_service.dart';

/// BR-060/061/062 extension: FCM push notification service.
/// Acts as a secondary layer on top of LocalNotificationService.
///
/// Responsibilities:
/// 1. Request notification permission from the OS
/// 2. Obtain & upload FCM token to bmjServer (called externally)
/// 3. Handle foreground messages → display via LocalNotificationService
/// 4. Register background / terminated message handlers
class FirebaseNotificationService {
  static final FirebaseNotificationService instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotifications =
      LocalNotificationService();

  String? _fcmToken;
  bool _initialized = false;

  /// The last obtained FCM token.
  String? get fcmToken => _fcmToken;

  /// Initialize the FCM service.
  /// Call once after Firebase.initializeApp() in main().
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Request notification permission (Android 13+)
      final NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        debugPrint(
            '📬 FCM permission: ${settings.authorizationStatus}');
      }

      // 2. Get the FCM token
      _fcmToken = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('📬 FCM token obtained: ${_fcmToken?.substring(0, 20)}...');
      }

      // 3. Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        if (kDebugMode) {
          debugPrint(
              '📬 FCM token refreshed: ${newToken.substring(0, 20)}...');
        }
        // TODO: Upload new token to bmjServer when authenticated
      });

      // 4. Handle foreground messages → show local notification
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('📩 Foreground message received: ${message.messageId}');
          debugPrint('   Title: ${message.notification?.title}');
          debugPrint('   Body: ${message.notification?.body}');
        }

        final notification = message.notification;
        if (notification != null) {
          _localNotifications.showNotification(
            id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
            title: notification.title ?? 'BookMyJuice',
            body: notification.body ?? '',
            payload: message.data['type'] as String?,
          );
        }
      });

      // 5. Handle notification tap when app opened from terminated/background
      //    This is handled in main.dart via getInitialMessage().
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FCM initialization error: $e');
      }
      // Don't crash — FCM is a secondary layer
    }
  }

  /// Handle notification that launched the app from a terminated state.
  /// Call this in main.dart after Firebase.initializeApp().
  Future<RemoteMessage?> getInitialMessage() async {
    try {
      return await _messaging.getInitialMessage();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FCM getInitialMessage error: $e');
      }
      return null;
    }
  }

  /// Set up background message handler.
  /// This must be called at the top level, outside of any class,
  /// before runApp(). We provide a static init function for that.
  static void setupBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  }

  /// Static background message handler.
  /// Runs in a separate isolate — cannot access instance state.
  @pragma('vm:entry-point')
  static Future<void> _onBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('📩 Background message received: ${message.messageId}');
    }
    // For background messages on Android, the system UI automatically
    // shows the notification. We don't need to do anything here unless
    // we want custom handling.
  }

  /// Upload the current FCM token to bmjServer.
  /// Should be called after authentication, when the user is logged in.
  Future<bool> uploadTokenToServer(String authToken) async {
    if (_fcmToken == null) return false;
    // This would make an API call to bmjServer:
    // POST /api/auth/fcm-token { "fcmToken": _fcmToken }
    // For now we just return true as a placeholder.
    if (kDebugMode) {
      debugPrint('📬 Would upload FCM token to server');
    }
    return true;
  }
}

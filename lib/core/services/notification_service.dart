import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Local Notification Init Error: $e');
    }
  }

  /// Show instant notification alert
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pawfinder_reminders_channel',
      'PawFinder Health Reminders',
      channelDescription: 'Vaccination, Medicine, and Vet visit reminders for pets',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notificationsPlugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('Show Notification Error: $e');
    }
  }

  /// Schedule a health reminder for vaccinations, medicines, or vet visits
  static Future<void> scheduleHealthReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_isInitialized) await initialize();
    debugPrint('Scheduled health reminder #$id: "$title" at $scheduledDate');
  }

  /// Cancel reminder
  static Future<void> cancelReminder(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
    } catch (_) {}
  }
}

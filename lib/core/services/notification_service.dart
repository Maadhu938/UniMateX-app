// Notification service stub — will be completed in Phase 6
// For now, provides the structure without FCM dependency

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // TODO: Initialize FCM + flutter_local_notifications
    // await FirebaseMessaging.instance.requestPermission();
    // await _setupLocalNotifications();
  }

  Future<void> scheduleClassReminder({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // TODO: Schedule local notification
  }

  Future<void> cancelAllNotifications() async {
    // TODO: Cancel all scheduled notifications
  }
}

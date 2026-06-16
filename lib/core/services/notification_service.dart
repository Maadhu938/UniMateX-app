import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Channel identifiers (kept stable so we can manage them explicitly).
  static const String _taskChannelId = 'unimatex_class_reminders';
  static const String _taskChannelName = 'Task Reminders';
  static const String _weeklyChannelId = 'unimatex_weekly_classes';
  static const String _weeklyChannelName = 'Class Reminders';

  Future<void> init() async {
    if (_initialized) return;

    // 1. Load the timezone database AND set the device's local timezone.
    // Without setting tz.local, it defaults to UTC and every scheduled
    // notification fires at the wrong time (the classic "notifications
    // don't work" bug).
    tz.initializeTimeZones();
    try {
      final String localTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimeZone));
    } catch (e) {
      debugPrint('Could not resolve local timezone, defaulting to UTC: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    await _createChannels();
    _initialized = true;
  }

  /// Explicitly create notification channels so they exist with the correct
  /// importance even before the first notification is posted.
  Future<void> _createChannels() async {
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    const taskChannel = AndroidNotificationChannel(
      _taskChannelId,
      _taskChannelName,
      description: 'Reminders for upcoming assignment deadlines',
      importance: Importance.high,
    );
    const weeklyChannel = AndroidNotificationChannel(
      _weeklyChannelId,
      _weeklyChannelName,
      description: 'Reminders 15 minutes before your classes start',
      importance: Importance.high,
    );

    await android.createNotificationChannel(taskChannel);
    await android.createNotificationChannel(weeklyChannel);
  }

  /// Requests the POST_NOTIFICATIONS runtime permission (Android 13+ / iOS).
  /// Returns whether notifications are permitted.
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  /// Picks the safest Android schedule mode. Uses exact alarms only when the
  /// OS has granted permission (Android 12+ gates SCHEDULE_EXACT_ALARM behind
  /// a runtime grant); otherwise falls back to an inexact alarm that does not
  /// require special permission and keeps us compliant with Play policy.
  Future<AndroidScheduleMode> _resolveScheduleMode() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return AndroidScheduleMode.inexactAllowWhileIdle;

    final canExact = await android.canScheduleExactNotifications() ?? false;
    return canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> scheduleClassReminder({
    required String title,
    required String body,
    required DateTime scheduledTime,
    int? id,
  }) async {
    await init();

    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) return;

    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.from(scheduledTime, tz.local);
    final notificationId =
        id ?? scheduledTime.millisecondsSinceEpoch.remainder(100000);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _taskChannelId,
      _taskChannelName,
      channelDescription: 'Reminders for upcoming assignment deadlines',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: await _resolveScheduleMode(),
      );
      debugPrint('Scheduled notification "$title" at $scheduledDate');
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  Future<void> scheduleWeeklyClassReminder({
    required String className,
    required String room,
    required int dayOfWeek, // 1=Mon ... 7=Sun
    required int startMinutes, // minutes from midnight
    int? id,
  }) async {
    await init();

    final now = tz.TZDateTime.now(tz.local);
    final hour = startMinutes ~/ 60;
    final minute = startMinutes % 60;

    // Remind 15 minutes before the class starts.
    var remindHour = hour;
    var remindMinute = minute - 15;
    if (remindMinute < 0) {
      remindMinute += 60;
      remindHour -= 1;
    }
    if (remindHour < 0) {
      // Class is just after midnight; skip the reminder rather than wrap to
      // the previous day which would be confusing.
      return;
    }

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      remindHour,
      remindMinute,
    );
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    final notificationId = id ?? (dayOfWeek * 10000 + startMinutes);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _weeklyChannelId,
      _weeklyChannelName,
      channelDescription: 'Reminders 15 minutes before your classes start',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final roomText = room.trim().isEmpty ? '' : ' at $room';

    try {
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        'Upcoming Class: $className',
        'Starts in 15 mins$roomText.',
        scheduledDate,
        details,
        androidScheduleMode: await _resolveScheduleMode(),
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      debugPrint('Scheduled weekly reminder for $className on $scheduledDate');
    } catch (e) {
      debugPrint('Failed to schedule weekly notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Whether the OS currently allows this app to post notifications.
  Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? true;
    }
    return true;
  }

  /// On Android 12+, asks the OS to allow exact alarms (improves reminder
  /// timing accuracy). Safe to call repeatedly; no-op where not needed.
  Future<void> requestExactAlarmPermissionIfNeeded() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canExact = await android?.canScheduleExactNotifications() ?? true;
    if (!canExact) {
      await android?.requestExactAlarmsPermission();
    }
  }
}

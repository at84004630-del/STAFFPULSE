import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import '../config/app_config.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _notifications = FlutterLocalNotificationsPlugin();

  static const int dailyPulseNotificationId = 1001;
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyReminderHour = 'reminder_hour';
  static const String keyReminderMinute = 'reminder_minute';

  Future<void> initialize() async {
    if (kIsWeb) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);

    // Request notification permissions for Android 13+ (API 33+)
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    // Auto-schedule daily reminder if enabled
    await autoScheduleFromPreferences();
  }

  Future<void> autoScheduleFromPreferences() async {
    if (kIsWeb) return;
    try {
      final box = Hive.isBoxOpen(AppConfig.settingsBox)
          ? Hive.box(AppConfig.settingsBox)
          : await Hive.openBox(AppConfig.settingsBox);

      final isEnabled = box.get(keyNotificationsEnabled, defaultValue: true) as bool;
      if (isEnabled) {
        final hour = box.get(keyReminderHour, defaultValue: AppConfig.defaultReminderHour) as int;
        final minute = box.get(keyReminderMinute, defaultValue: AppConfig.defaultReminderMinute) as int;
        await scheduleDailyPulseReminder(hour: hour, minute: minute, savePreference: false);
      }
    } catch (e) {
      debugPrint('NotificationService: auto-schedule error: $e');
    }
  }

  Future<void> scheduleDailyPulseReminder({
    required int hour,
    required int minute,
    bool savePreference = true,
  }) async {
    if (savePreference) {
      try {
        final box = Hive.isBoxOpen(AppConfig.settingsBox)
            ? Hive.box(AppConfig.settingsBox)
            : await Hive.openBox(AppConfig.settingsBox);
        await box.put(keyNotificationsEnabled, true);
        await box.put(keyReminderHour, hour);
        await box.put(keyReminderMinute, minute);
      } catch (e) {
        debugPrint('NotificationService: error saving preference: $e');
      }
    }

    await _notifications.cancel(dailyPulseNotificationId);

    final scheduledTime = _nextInstanceOfTime(hour, minute);

    await _notifications.zonedSchedule(
      dailyPulseNotificationId,
      '💚 Time for your daily pulse check-in!',
      'How are you feeling today? It only takes 10 seconds.',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_pulse',
          'Daily Pulse Reminder',
          channelDescription: 'Daily check-in reminder',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    try {
      final box = Hive.isBoxOpen(AppConfig.settingsBox)
          ? Hive.box(AppConfig.settingsBox)
          : await Hive.openBox(AppConfig.settingsBox);
      await box.put(keyNotificationsEnabled, false);
    } catch (e) {
      debugPrint('NotificationService: error saving cancel preference: $e');
    }
    await _notifications.cancel(dailyPulseNotificationId);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> showBurnoutAlert(String teamName) async {
    await _notifications.show(
      2001,
      '⚠️ Burnout Alert: $teamName',
      'Your team wellbeing score dropped below 40%. Take action now.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'burnout_alerts',
          'Burnout Alerts',
          channelDescription: 'Critical team wellbeing alerts for managers',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
    );
  }
}

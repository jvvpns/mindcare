import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/planner_entry.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(settings: initSettings);
  }

  Future<void> scheduleTaskReminder(PlannerEntry entry) async {
    if (entry.reminderOffset == null || entry.isCompleted) return;

    final scheduleTime = entry.dueDate.subtract(Duration(minutes: entry.reminderOffset!));
    if (scheduleTime.isBefore(DateTime.now())) return; // Already passed

    final id = entry.id.hashCode;

    await _plugin.zonedSchedule(
      id: id,
      title: 'Upcoming: ${entry.title}',
      body: 'Starts in ${entry.reminderOffset} minutes',
      scheduledDate: tz.TZDateTime.from(scheduleTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'hilway_reminders',
          'Academic Reminders',
          channelDescription: 'Reminders for clinical duties and exams',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(String entryId) async {
    await _plugin.cancel(id: entryId.hashCode);
  }

  Future<void> scheduleDailyRefuelReminders() async {
    const androidDetails = AndroidNotificationDetails(
      'hilway_refuel',
      'Clinical Refuel Reminders',
      channelDescription: 'Reminders to log your meals and stay resilient',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    // 1. Breakfast @ 7:00 AM
    await _scheduleDaily(
      id: 1001,
      title: 'Time for Breakfast 🍳',
      body: 'Fuel up for your clinical duty. Don\'t forget to log it!',
      hour: 7,
      minute: 0,
      details: notificationDetails,
    );

    // 2. Lunch @ 11:30 AM
    await _scheduleDaily(
      id: 1002,
      title: 'Lunch Break 🍱',
      body: 'Take a moment to refuel and recharge.',
      hour: 11,
      minute: 30,
      details: notificationDetails,
    );

    // 3. Dinner @ 7:00 PM
    await _scheduleDaily(
      id: 1003,
      title: 'Time for Dinner 🥗',
      body: 'Shift is almost over or done. Keep your resilience up!',
      hour: 19,
      minute: 0,
      details: notificationDetails,
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required NotificationDetails details,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // This makes it daily
    );
  }
}

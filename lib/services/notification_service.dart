import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import '../data/models/item_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'naruh_dimana_reminders';
  static const String _channelName = 'Pengingat Barang';
  static const String _channelDescription =
      'Notifikasi pengingat untuk barang-barang Anda';

  static const int _notificationIdBase = 1000;

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Payload handling is done in main.dart via the global navigator key
  }

  Future<bool> requestPermission() async {
    if (await Permission.notification.isGranted) return true;

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> scheduleNotification(Item item) async {
    if (item.reminderTime == null) return;

    final reminderDt = DateTime.tryParse(item.reminderTime!);
    if (reminderDt == null) return;

    if (reminderDt.isBefore(DateTime.now())) return;

    final tzLocation = tz.local;
    final reminderTime = tz.TZDateTime.from(reminderDt, tzLocation);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: false,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('view', 'Lihat'),
      ],
    );

    final details = NotificationDetails(
      android: androidDetails,
    );

    final notificationId = _notificationIdBase + (item.id ?? 0);

    RepeatInterval? repeatInterval;
    switch (item.reminderRepeat) {
      case 'daily':
        repeatInterval = RepeatInterval.daily;
        break;
      case 'weekly':
        repeatInterval = RepeatInterval.weekly;
        break;
      default:
        repeatInterval = null;
    }

    await _notifications.zonedSchedule(
      id: notificationId,
      title: item.name,
      body: 'Di mana? → ${item.location}',
      scheduledDate: reminderTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: repeatInterval != null
          ? (repeatInterval == RepeatInterval.daily
              ? DateTimeComponents.time
              : DateTimeComponents.dayOfWeekAndTime)
          : null,
      payload: item.id.toString(),
    );
  }

  Future<void> cancelNotification(int itemId) async {
    final notificationId = _notificationIdBase + itemId;
    await _notifications.cancel(id: notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> showInstantNotification(Item item) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
    );

    final notificationId = _notificationIdBase + (item.id ?? 0);

    await _notifications.show(
      id: notificationId,
      title: item.name,
      body: 'Di mana? → ${item.location}',
      notificationDetails: details,
      payload: item.id.toString(),
    );
  }
}

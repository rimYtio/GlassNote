import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class LocalNotificationService {
  LocalNotificationService._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static Future<LocalNotificationService> create() async {
    tz_data.initializeTimeZones();
    final plugin = FlutterLocalNotificationsPlugin();
    final service = LocalNotificationService._(plugin);
    await service._initialize();
    return service;
  }

  final _notificationTapController =
      StreamController<NotificationPayload>.broadcast();

  Stream<NotificationPayload> get onNotificationTap =>
      _notificationTapController.stream;

  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<int> schedule({
    required String title,
    required String body,
    required DateTime triggerTime,
    required String payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'glassnote_reminders',
      '提醒',
      channelDescription: '笔记和任务的提醒通知',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationId =
        triggerTime.millisecondsSinceEpoch.remainder(1000000000);

    final scheduledDate = tz.TZDateTime.from(triggerTime, tz.local);

    await _plugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    debugPrint('Scheduled notification $notificationId for $triggerTime');
    return notificationId;
  }

  Future<void> cancel(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _notificationTapController
          .add(NotificationPayload.fromString(payload));
    }
  }

  void dispose() {
    _notificationTapController.close();
  }
}

class NotificationPayload {
  NotificationPayload({required this.targetType, required this.targetId});

  factory NotificationPayload.fromString(String payload) {
    final parts = payload.split(':');
    return NotificationPayload(
      targetType: parts.isNotEmpty ? parts[0] : '',
      targetId: parts.length > 1 ? parts.sublist(1).join(':') : '',
    );
  }

  final String targetType;
  final String targetId;

  String serialize() => '$targetType:$targetId';
}

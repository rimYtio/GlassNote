import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../../domain/entities/reminder.dart';

class LocalNotificationService {
  LocalNotificationService._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static Future<LocalNotificationService> create() async {
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

    tz_data.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
      debugPrint('[NotificationService] local timezone=$timezoneName');
    } catch (e) {
      debugPrint('[NotificationService] timezone setup failed: $e');
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    }

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

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
            AndroidNotificationChannel(
              'glassnote_reminders_v2',
              '提醒',
              description: '笔记和任务的提醒通知',
              importance: Importance.max,
              enableVibration: true,
              vibrationPattern: Int64List.fromList([0, 200, 100, 300]),
              playSound: true,
            ),
          );
        }

    try {
      final canExact = await androidPlugin?.canScheduleExactNotifications();
      debugPrint('[NotificationService] canScheduleExactNotifications=$canExact');
    } catch (e) {
      debugPrint('[NotificationService] exact alarm check failed: $e');
    }

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

  Future<ScheduleResult> schedule({
    required int notificationId,
    required String title,
    required String body,
    required DateTime triggerTime,
    required String payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'glassnote_reminders_v2',
      '提醒',
      channelDescription: '笔记和任务的提醒通知',
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 200, 100, 300]),
      playSound: true,
      category: AndroidNotificationCategory.reminder,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = tz.TZDateTime.from(triggerTime, tz.local);

    AndroidScheduleMode usedMode = AndroidScheduleMode.exactAllowWhileIdle;
    ScheduleStatus status;

    try {
      await _plugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      status = ScheduleStatus.scheduled;
      debugPrint('Scheduled notification $notificationId for $triggerTime (exact)');
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        try {
          await _plugin.zonedSchedule(
            notificationId,
            title,
            body,
            scheduledDate,
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: payload,
          );
          usedMode = AndroidScheduleMode.inexactAllowWhileIdle;
          status = ScheduleStatus.scheduledInexact;
          debugPrint('Scheduled notification $notificationId (inexact fallback) for $triggerTime');
        } catch (fallbackError) {
          debugPrint('[NotificationService] schedule fallback failed: $fallbackError');
          status = ScheduleStatus.failed;
        }
      } else {
        debugPrint('[NotificationService] schedule failed: $e');
        status = ScheduleStatus.failed;
      }
    } catch (e) {
      debugPrint('[NotificationService] schedule failed: $e');
      status = ScheduleStatus.failed;
    }

    await debugPrintPendingNotifications('after schedule');

    return ScheduleResult(status: status, mode: usedMode);
  }

  Future<void> debugPrintPendingNotifications(String tag) async {
    final pending = await _plugin.pendingNotificationRequests();
    debugPrint('[NotificationService][$tag] pending count=${pending.length}');
    for (final p in pending) {
      debugPrint('[NotificationService][$tag] pending id=${p.id} title=${p.title}');
    }
  }

  Future<void> cancel(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  Future<void> reschedule(
      Future<List<Reminder>> Function() pendingFetcher) async {
    final reminders = await pendingFetcher();
    for (final reminder in reminders) {
      try {
        await schedule(
          notificationId: reminder.notificationId,
          title: 'GlassNote 提醒',
          body: '${reminder.targetType}: ${reminder.targetId}',
          triggerTime: reminder.triggerTime,
          payload: '${reminder.targetType}:${reminder.targetId}',
        );
      } catch (e) {
        debugPrint('[NotificationService] reschedule failed for ${reminder.id}: $e');
        // Continue with next reminder
      }
    }
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

enum ScheduleStatus { scheduled, scheduledInexact, failed }

class ScheduleResult {
  final ScheduleStatus status;
  final AndroidScheduleMode mode;
  const ScheduleResult({required this.status, required this.mode});
  bool get isOk => status != ScheduleStatus.failed;
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

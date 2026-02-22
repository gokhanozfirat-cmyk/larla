import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool _initialized = false;

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  // Ezan bildirim kanalı ID'leri
  static const int _fajrNotificationId = 1001;
  static const int _dhuhrNotificationId = 1002;
  static const int _asrNotificationId = 1003;
  static const int _maghribNotificationId = 1004;
  static const int _ishaNotificationId = 1005;

  Future<void> initialize() async {
    try {
      if (_initialized) return;
      tz_data.initializeTimeZones();
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );

      // Request permissions for Android 13+
      try {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } catch (e) {
        print('Android notification permission request failed: $e');
      }

      // Request permissions for iOS
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      _initialized = true;
    } catch (e) {
      print('Error initializing notifications: $e');
      rethrow;
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await initialize();
  }

  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {}

  Future<void> scheduleNoonNotification(
      String journeyId, String prayerTitle, int dailyCount) async {
    try {
      await _ensureInitialized();
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, 12, 0);

      // If it's already past noon today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tz.TZDateTime tzScheduledDate =
          tz.TZDateTime.from(scheduledDate, tz.local);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        journeyId.hashCode,
        'Dua Hatırlatması',
        'Bugünkü tekrarlarını unutma! 📖\n$prayerTitle - $dailyCount kez oku',
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'dua_reminder',
            'Dua Hatırlatmaları',
            channelDescription: 'Günlük dua hatırlatmaları',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotification(String journeyId) async {
    try {
      await _ensureInitialized();
      await flutterLocalNotificationsPlugin.cancel(journeyId.hashCode);
    } catch (e) {
      print('Error canceling notification: $e');
    }
  }

  // Ezan vakti bildirimi zamanla
  Future<void> scheduleEzanNotification({
    required int id,
    required String prayerName,
    required String time, // "HH:mm" formatında
  }) async {
    try {
      await _ensureInitialized();
      final parts = time.split(':');
      if (parts.length != 2) return;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

      // Eğer vakit geçmişse yarın için planla
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tz.TZDateTime tzScheduledDate =
          tz.TZDateTime.from(scheduledDate, tz.local);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        '$prayerName Vakti',
        '$prayerName vakti girdi. Haydi namaza! 🕌',
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'ezan_channel',
            'Ezan Bildirimleri',
            channelDescription: 'Namaz vakti bildirimleri',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            // Özel ezan sesi eklemek için:
            // sound: RawResourceAndroidNotificationSound('ezan'),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            // Özel ezan sesi eklemek için:
            // sound: 'ezan.aiff',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Her gün tekrarla
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Ezan bildirimi planlandı: $prayerName - $time');
    } catch (e) {
      print('Error scheduling ezan notification: $e');
    }
  }

  // Tüm ezan bildirimlerini planla
  Future<void> scheduleAllEzanNotifications({
    String? fajrTime,
    String? dhuhrTime,
    String? asrTime,
    String? maghribTime,
    String? ishaTime,
  }) async {
    // Önce tüm ezan bildirimlerini iptal et
    await _ensureInitialized();
    await cancelAllEzanNotifications();

    if (fajrTime != null && fajrTime.isNotEmpty) {
      await scheduleEzanNotification(
        id: _fajrNotificationId,
        prayerName: 'Sabah',
        time: fajrTime,
      );
    }
    if (dhuhrTime != null && dhuhrTime.isNotEmpty) {
      await scheduleEzanNotification(
        id: _dhuhrNotificationId,
        prayerName: 'Öğle',
        time: dhuhrTime,
      );
    }
    if (asrTime != null && asrTime.isNotEmpty) {
      await scheduleEzanNotification(
        id: _asrNotificationId,
        prayerName: 'İkindi',
        time: asrTime,
      );
    }
    if (maghribTime != null && maghribTime.isNotEmpty) {
      await scheduleEzanNotification(
        id: _maghribNotificationId,
        prayerName: 'Akşam',
        time: maghribTime,
      );
    }
    if (ishaTime != null && ishaTime.isNotEmpty) {
      await scheduleEzanNotification(
        id: _ishaNotificationId,
        prayerName: 'Yatsı',
        time: ishaTime,
      );
    }
  }

  // Tüm ezan bildirimlerini iptal et
  Future<void> cancelAllEzanNotifications() async {
    try {
      await _ensureInitialized();
      await flutterLocalNotificationsPlugin.cancel(_fajrNotificationId);
      await flutterLocalNotificationsPlugin.cancel(_dhuhrNotificationId);
      await flutterLocalNotificationsPlugin.cancel(_asrNotificationId);
      await flutterLocalNotificationsPlugin.cancel(_maghribNotificationId);
      await flutterLocalNotificationsPlugin.cancel(_ishaNotificationId);
    } catch (e) {
      print('Error canceling ezan notifications: $e');
    }
  }
}

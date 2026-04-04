import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../l10n/app_strings.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool _initialized = false;
  bool _timezoneInitialized = false;

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
      await _initializeLocalTimezone();
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

      _initialized = true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await initialize();
  }

  Future<void> _initializeLocalTimezone() async {
    if (_timezoneInitialized) return;
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
      _timezoneInitialized = true;
    } catch (e) {
      _timezoneInitialized = true;
    }
  }

  String _normalizeTimeText(String time) {
    var normalized = time.trim();
    if (normalized.isEmpty) return '';

    const digitMap = <String, String>{
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
      '۰': '0',
      '۱': '1',
      '۲': '2',
      '۳': '3',
      '۴': '4',
      '۵': '5',
      '۶': '6',
      '۷': '7',
      '۸': '8',
      '۹': '9',
    };
    digitMap.forEach((from, to) {
      normalized = normalized.replaceAll(from, to);
    });

    normalized = normalized
        .replaceAll('：', ':')
        .replaceAll('٫', ':')
        .replaceAll('.', ':');

    final match = RegExp(r'(\d{1,2})\s*:\s*(\d{1,2})').firstMatch(normalized);
    if (match == null) return '';

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return '';
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return '';

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String normalizeTimeText(String time) {
    return _normalizeTimeText(time);
  }

  DateTime? _parseTimeToDate(String time) {
    final sanitized = _normalizeTimeText(time);
    if (sanitized.isEmpty) return null;
    final parts = sanitized.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Bildirim iznini kontrol eder. İzin yoksa ister.
  /// Döndürülen değer: true = izin var, false = izin reddedildi
  Future<bool> requestAndCheckPermission() async {
    await _ensureInitialized();

    if (kIsWeb) return true;

    // Android izin kontrolü ve isteği
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return false;

      // Önce mevcut durumu kontrol et
      final alreadyEnabled = await androidPlugin.areNotificationsEnabled();
      if (alreadyEnabled == true) return true;

      // İzin yoksa iste
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS izin kontrolü ve isteği
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin == null) return true;

      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {}

  Future<void> scheduleNoonNotification(
      String journeyId, String prayerTitle, int dailyCount) async {
    try {
      final t = AppStrings.fromPlatform();
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
        t.prayerReminderTitle,
        t.prayerReminderBody(prayerTitle, dailyCount),
        tzScheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'dua_reminder',
            t.prayerReminderChannelName,
            channelDescription: t.prayerReminderChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Bildirim planlanamadı
    }
  }

  Future<void> cancelNotification(String journeyId) async {
    try {
      await _ensureInitialized();
      await flutterLocalNotificationsPlugin.cancel(journeyId.hashCode);
    } catch (e) {
      // Bildirim iptal edilemedi
    }
  }

  // Ezan vakti bildirimi zamanla
  Future<bool> scheduleEzanNotification({
    required int id,
    required String prayerName,
    required String time, // "HH:mm" formatında
  }) async {
    try {
      final t = AppStrings.fromPlatform();
      await _ensureInitialized();
      final scheduledDate = _parseTimeToDate(time);
      if (scheduledDate == null) {
        debugPrint('[EZAN_NOTIFY] Geçersiz saat formatı: "$time"');
        return false;
      }

      final tz.TZDateTime tzScheduledDate =
          tz.TZDateTime.from(scheduledDate, tz.local);

      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'ezan_channel',
          t.ezanChannelName,
          channelDescription: t.ezanChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          t.prayerTimeTitle(prayerName),
          t.prayerTimeTitle(prayerName),
          tzScheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time, // Her gün tekrarla
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        // Bazı cihazlarda `inexactAllowWhileIdle` fallback gerektirebilir.
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          t.prayerTimeTitle(prayerName),
          t.prayerTimeTitle(prayerName),
          tzScheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexact,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      return true;
    } catch (e) {
      debugPrint('[EZAN_NOTIFY] scheduleEzanNotification HATA: $e');
      return false;
    }
  }

  // Tüm ezan bildirimlerini planla
  // Döndürülen değer: 'success', 'no_permission', 'no_times', 'schedule_failed'
  Future<String> scheduleAllEzanNotifications({
    String? fajrTime,
    String? dhuhrTime,
    String? asrTime,
    String? maghribTime,
    String? ishaTime,
  }) async {
    final t = AppStrings.fromPlatform();
    await _ensureInitialized();

    // İzni kontrol et ve gerekiyorsa iste
    final hasPermission = await requestAndCheckPermission();
    if (!hasPermission) return 'no_permission';

    final normalizedFajr = _normalizeTimeText(fajrTime ?? '');
    final normalizedDhuhr = _normalizeTimeText(dhuhrTime ?? '');
    final normalizedAsr = _normalizeTimeText(asrTime ?? '');
    final normalizedMaghrib = _normalizeTimeText(maghribTime ?? '');
    final normalizedIsha = _normalizeTimeText(ishaTime ?? '');

    // En az bir geçerli vakit var mı kontrol et
    final times = [
      normalizedFajr,
      normalizedDhuhr,
      normalizedAsr,
      normalizedMaghrib,
      normalizedIsha
    ];
    final hasAnyTime = times.any((t) => t.isNotEmpty);
    if (!hasAnyTime) return 'no_times';

    await cancelAllEzanNotifications();
    var scheduledCount = 0;

    if (normalizedFajr.isNotEmpty) {
      final ok = await scheduleEzanNotification(
        id: _fajrNotificationId,
        prayerName: t.prayerNameFajr(),
        time: normalizedFajr,
      );
      if (ok) scheduledCount++;
    }
    if (normalizedDhuhr.isNotEmpty) {
      final ok = await scheduleEzanNotification(
        id: _dhuhrNotificationId,
        prayerName: t.prayerNameDhuhr(),
        time: normalizedDhuhr,
      );
      if (ok) scheduledCount++;
    }
    if (normalizedAsr.isNotEmpty) {
      final ok = await scheduleEzanNotification(
        id: _asrNotificationId,
        prayerName: t.prayerNameAsr(),
        time: normalizedAsr,
      );
      if (ok) scheduledCount++;
    }
    if (normalizedMaghrib.isNotEmpty) {
      final ok = await scheduleEzanNotification(
        id: _maghribNotificationId,
        prayerName: t.prayerNameMaghrib(),
        time: normalizedMaghrib,
      );
      if (ok) scheduledCount++;
    }
    if (normalizedIsha.isNotEmpty) {
      final ok = await scheduleEzanNotification(
        id: _ishaNotificationId,
        prayerName: t.prayerNameIsha(),
        time: normalizedIsha,
      );
      if (ok) scheduledCount++;
    }

    return scheduledCount > 0 ? 'success' : 'schedule_failed';
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
      // Ezan bildirimleri iptal edilemedi
    }
  }
}

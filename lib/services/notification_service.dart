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

  // Ezan bildirim ID aralıkları:
  // Gün 0 (bugün): 1001-1005
  // Gün 1 (yarın): 1011-1015
  // Gün N: 10N1-10N5 (N=0..14)
  static const int _baseId = 1000;

  // Vakit indeksleri
  static const int _fajrIndex = 1;
  static const int _dhuhrIndex = 2;
  static const int _asrIndex = 3;
  static const int _maghribIndex = 4;
  static const int _ishaIndex = 5;

  /// Gün ve vakit indeksinden bildirim ID'si hesapla
  static int _notificationId(int dayOffset, int prayerIndex) {
    return _baseId + (dayOffset * 10) + prayerIndex;
  }

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
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
      '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
      '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
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

  Future<bool> requestAndCheckPermission() async {
    await _ensureInitialized();
    if (kIsWeb) return true;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return false;
      final alreadyEnabled = await androidPlugin.areNotificationsEnabled();
      if (alreadyEnabled == true) return true;
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin == null) return true;
      final granted = await iosPlugin.requestPermissions(
        alert: true, badge: true, sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {}

  /// 15 günlük vakitleri kullanarak TÜM bildirimleri exact tarih/saatle planla.
  /// matchDateTimeComponents KULLANMAZ — her gün ayrı bildirim.
  Future<String> scheduleMultiDayEzanNotifications({
    required Map<String, Map<String, String>> multiDayTimes,
  }) async {
    final t = AppStrings.fromPlatform();
    await _ensureInitialized();

    final hasPermission = await requestAndCheckPermission();
    if (!hasPermission) return 'no_permission';

    if (multiDayTimes.isEmpty) return 'no_times';

    // Önce tüm eski bildirimleri iptal et
    await cancelAllEzanNotifications();

    var scheduledCount = 0;
    final now = DateTime.now();

    // Tarihleri sırala
    final sortedDates = multiDayTimes.keys.toList()..sort();

    for (var dayOffset = 0; dayOffset < sortedDates.length; dayOffset++) {
      final dateKey = sortedDates[dayOffset];

      // Tarihi parse et
      DateTime targetDate;
      try {
        targetDate = DateTime.parse(dateKey);
      } catch (_) {
        continue;
      }

      // Geçmiş günleri atla
      if (targetDate.isBefore(DateTime(now.year, now.month, now.day))) {
        continue;
      }

      final dayTimes = multiDayTimes[dateKey]!;

      // Her vakit için ayrı exact bildirim planla
      final prayerEntries = [
        (_fajrIndex, 'fajr', t.prayerNameFajr()),
        (_dhuhrIndex, 'dhuhr', t.prayerNameDhuhr()),
        (_asrIndex, 'asr', t.prayerNameAsr()),
        (_maghribIndex, 'maghrib', t.prayerNameMaghrib()),
        (_ishaIndex, 'isha', t.prayerNameIsha()),
      ];

      for (final entry in prayerEntries) {
        final prayerIndex = entry.$1;
        final timeKey = entry.$2;
        final prayerName = entry.$3;
        final timeStr = _normalizeTimeText(dayTimes[timeKey] ?? '');

        if (timeStr.isEmpty) continue;

        final parts = timeStr.split(':');
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == null || minute == null) continue;

        final scheduledDateTime = DateTime(
          targetDate.year, targetDate.month, targetDate.day,
          hour, minute,
        );

        // Geçmiş saatleri atla
        if (scheduledDateTime.isBefore(now)) continue;

        final tzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
        final notifId = _notificationId(dayOffset, prayerIndex);

        try {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            notifId,
            t.prayerTimeTitle(prayerName),
            t.prayerTimeTitle(prayerName),
            tzDateTime,
            NotificationDetails(
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
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          scheduledCount++;
        } catch (e) {
          // exactAllowWhileIdle desteklenmiyorsa fallback
          try {
            await flutterLocalNotificationsPlugin.zonedSchedule(
              notifId,
              t.prayerTimeTitle(prayerName),
              t.prayerTimeTitle(prayerName),
              tzDateTime,
              NotificationDetails(
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
              ),
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
            scheduledCount++;
          } catch (_) {}
        }
      }
    }

    debugPrint('[EZAN_NOTIFY] $scheduledCount bildirim planlandı (${sortedDates.length} gün)');
    return scheduledCount > 0 ? 'success' : 'schedule_failed';
  }

  /// Eski stil — tek gün planlama (geriye uyumluluk)
  Future<String> scheduleAllEzanNotifications({
    String? fajrTime,
    String? dhuhrTime,
    String? asrTime,
    String? maghribTime,
    String? ishaTime,
  }) async {
    await _ensureInitialized();

    final hasPermission = await requestAndCheckPermission();
    if (!hasPermission) return 'no_permission';

    final normalizedFajr = _normalizeTimeText(fajrTime ?? '');
    final normalizedDhuhr = _normalizeTimeText(dhuhrTime ?? '');
    final normalizedAsr = _normalizeTimeText(asrTime ?? '');
    final normalizedMaghrib = _normalizeTimeText(maghribTime ?? '');
    final normalizedIsha = _normalizeTimeText(ishaTime ?? '');

    final times = [normalizedFajr, normalizedDhuhr, normalizedAsr, normalizedMaghrib, normalizedIsha];
    if (!times.any((t) => t.isNotEmpty)) return 'no_times';

    // Bugünün tarihini kullanarak tek günlük multiDay formatına çevir
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final tomorrowDate = now.add(const Duration(days: 1));
    final tomorrowKey = '${tomorrowDate.year}-${tomorrowDate.month.toString().padLeft(2, '0')}-${tomorrowDate.day.toString().padLeft(2, '0')}';

    final dayTimes = <String, String>{};
    if (normalizedFajr.isNotEmpty) dayTimes['fajr'] = normalizedFajr;
    if (normalizedDhuhr.isNotEmpty) dayTimes['dhuhr'] = normalizedDhuhr;
    if (normalizedAsr.isNotEmpty) dayTimes['asr'] = normalizedAsr;
    if (normalizedMaghrib.isNotEmpty) dayTimes['maghrib'] = normalizedMaghrib;
    if (normalizedIsha.isNotEmpty) dayTimes['isha'] = normalizedIsha;

    // Bugün ve yarın için aynı vakitlerle planla (stok yoksa fallback)
    return scheduleMultiDayEzanNotifications(
      multiDayTimes: {
        todayKey: dayTimes,
        tomorrowKey: dayTimes,
      },
    );
  }

  Future<void> scheduleNoonNotification(
      String journeyId, String prayerTitle, int dailyCount) async {
    try {
      final t = AppStrings.fromPlatform();
      await _ensureInitialized();
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, 12, 0);

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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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

  /// Tüm ezan bildirimlerini iptal et (15 gün x 5 vakit = 75 bildirim)
  Future<void> cancelAllEzanNotifications() async {
    try {
      await _ensureInitialized();
      for (var day = 0; day < 15; day++) {
        for (var prayer = 1; prayer <= 5; prayer++) {
          await flutterLocalNotificationsPlugin
              .cancel(_notificationId(day, prayer));
        }
      }
      // Eski stil ID'leri de temizle (geriye uyumluluk)
      for (final oldId in [1001, 1002, 1003, 1004, 1005]) {
        await flutterLocalNotificationsPlugin.cancel(oldId);
      }
    } catch (e) {
      // Ezan bildirimleri iptal edilemedi
    }
  }
}

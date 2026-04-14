class PrayerTimes {
  int sabah;
  int ogle;
  int ikindi;
  int aksam;

  // Bugünkü ezan vakitleri (saat:dakika formatında)
  String? fajrTime; // İmsak/Sabah
  String? sunriseTime; // Güneş
  String? dhuhrTime; // Öğle
  String? asrTime; // İkindi
  String? maghribTime; // Akşam
  String? ishaTime; // Yatsı

  // Ezan bildirimi açık mı?
  bool ezanNotificationEnabled;

  // 15 günlük vakit stoku: { "2026-04-14": { "fajr": "04:52", ... }, ... }
  Map<String, Map<String, String>> multiDayTimes;

  // Son stok güncelleme tarihi
  String? lastStockUpdate;

  PrayerTimes({
    this.sabah = 0,
    this.ogle = 0,
    this.ikindi = 0,
    this.aksam = 0,
    this.fajrTime,
    this.sunriseTime,
    this.dhuhrTime,
    this.asrTime,
    this.maghribTime,
    this.ishaTime,
    this.ezanNotificationEnabled = false,
    this.multiDayTimes = const {},
    this.lastStockUpdate,
  });

  /// Bugünün tarihini YYYY-MM-DD formatında döner
  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Belirli bir günün vakitlerini döner
  Map<String, String>? getTimesForDate(String dateKey) {
    return multiDayTimes[dateKey];
  }

  /// Bugünün vakitlerini stoktan güncelle
  void applyTodayFromStock() {
    final todayTimes = multiDayTimes[_todayKey()];
    if (todayTimes != null) {
      fajrTime = todayTimes['fajr'] ?? fajrTime;
      sunriseTime = todayTimes['sunrise'] ?? sunriseTime;
      dhuhrTime = todayTimes['dhuhr'] ?? dhuhrTime;
      asrTime = todayTimes['asr'] ?? asrTime;
      maghribTime = todayTimes['maghrib'] ?? maghribTime;
      ishaTime = todayTimes['isha'] ?? ishaTime;
    }
  }

  /// Kaç günlük stok kaldı (bugünden itibaren)
  int get remainingStockDays {
    final now = DateTime.now();
    int count = 0;
    for (final dateKey in multiDayTimes.keys) {
      try {
        final date = DateTime.parse(dateKey);
        if (!date.isBefore(DateTime(now.year, now.month, now.day))) {
          count++;
        }
      } catch (_) {}
    }
    return count;
  }

  /// Stok yenilenmesi gerekiyor mu? (5 günden az kaldıysa)
  bool get needsStockRefresh => remainingStockDays < 5;

  Map<String, dynamic> toJson() => {
        'sabah': sabah,
        'ogle': ogle,
        'ikindi': ikindi,
        'aksam': aksam,
        'fajrTime': fajrTime,
        'sunriseTime': sunriseTime,
        'dhuhrTime': dhuhrTime,
        'asrTime': asrTime,
        'maghribTime': maghribTime,
        'ishaTime': ishaTime,
        'ezanNotificationEnabled': ezanNotificationEnabled,
        'multiDayTimes': multiDayTimes.map(
          (k, v) => MapEntry(k, Map<String, String>.from(v)),
        ),
        'lastStockUpdate': lastStockUpdate,
      };

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    // multiDayTimes parse
    final rawMultiDay = json['multiDayTimes'];
    final multiDay = <String, Map<String, String>>{};
    if (rawMultiDay is Map) {
      for (final entry in rawMultiDay.entries) {
        if (entry.value is Map) {
          multiDay[entry.key.toString()] = Map<String, String>.from(
            (entry.value as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
          );
        }
      }
    }

    return PrayerTimes(
      sabah: json['sabah'] ?? 0,
      ogle: json['ogle'] ?? 0,
      ikindi: json['ikindi'] ?? 0,
      aksam: json['aksam'] ?? 0,
      fajrTime: json['fajrTime'],
      sunriseTime: json['sunriseTime'],
      dhuhrTime: json['dhuhrTime'],
      asrTime: json['asrTime'],
      maghribTime: json['maghribTime'],
      ishaTime: json['ishaTime'],
      ezanNotificationEnabled: json['ezanNotificationEnabled'] ?? false,
      multiDayTimes: multiDay,
      lastStockUpdate: json['lastStockUpdate'],
    );
  }
}

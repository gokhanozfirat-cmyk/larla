class PrayerTimes {
  int sabah;
  int ogle;
  int ikindi;
  int aksam;

  // Ezan vakitleri (saat:dakika formatında)
  String? fajrTime; // İmsak/Sabah
  String? sunriseTime; // Güneş
  String? dhuhrTime; // Öğle
  String? asrTime; // İkindi
  String? maghribTime; // Akşam
  String? ishaTime; // Yatsı

  // Ezan bildirimi açık mı?
  bool ezanNotificationEnabled;

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
  });

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
      };

  factory PrayerTimes.fromJson(Map<String, dynamic> json) => PrayerTimes(
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
      );
}

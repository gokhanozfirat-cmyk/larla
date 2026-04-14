
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class PrayerTimeApiService {
  // Aladhan API - Diyanet İşleri Başkanlığı metodu (method=13)
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  // Konum izni al ve konumu getir
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  // Tek gün namaz vakitlerini çek (mevcut — geriye uyumluluk)
  static Future<Map<String, String>?> getPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final url = Uri.parse(
        '$_baseUrl/timings/$timestamp?latitude=$latitude&longitude=$longitude&method=13',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        return {
          'fajr': timings['Fajr'] ?? '',
          'sunrise': timings['Sunrise'] ?? '',
          'dhuhr': timings['Dhuhr'] ?? '',
          'asr': timings['Asr'] ?? '',
          'maghrib': timings['Maghrib'] ?? '',
          'isha': timings['Isha'] ?? '',
        };
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// 15 günlük namaz vakitlerini çek.
  /// Dönen Map: { "2026-04-14": { "fajr": "04:52", ... }, "2026-04-15": {...}, ... }
  static Future<Map<String, Map<String, String>>?> getMultiDayPrayerTimes({
    required double latitude,
    required double longitude,
    int days = 15,
  }) async {
    try {
      final now = DateTime.now();
      final results = <String, Map<String, String>>{};

      // Aladhan calendar API — aylık veri çeker
      // İki ay çekmemiz gerekebilir (ay sonuna yakınsak)
      final monthsToFetch = <String>{};
      for (var i = 0; i < days; i++) {
        final date = now.add(Duration(days: i));
        monthsToFetch.add('${date.month}-${date.year}');
      }

      for (final monthYear in monthsToFetch) {
        final parts = monthYear.split('-');
        final month = parts[0];
        final year = parts[1];

        final url = Uri.parse(
          '$_baseUrl/calendar/$year/$month?latitude=$latitude&longitude=$longitude&method=13',
        );

        final response = await http.get(url).timeout(
          const Duration(seconds: 15),
          onTimeout: () => http.Response('timeout', 408),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final daysList = data['data'] as List?;

          if (daysList != null) {
            for (final dayData in daysList) {
              final timings = dayData['timings'];
              final dateInfo = dayData['date'];
              final gregorian = dateInfo['gregorian'];
              final dateStr = gregorian['date']; // "DD-MM-YYYY"

              // "DD-MM-YYYY" -> "YYYY-MM-DD"
              final dateParts = (dateStr as String).split('-');
              if (dateParts.length == 3) {
                final normalizedDate =
                    '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';

                results[normalizedDate] = {
                  'fajr': _cleanTime(timings['Fajr'] ?? ''),
                  'sunrise': _cleanTime(timings['Sunrise'] ?? ''),
                  'dhuhr': _cleanTime(timings['Dhuhr'] ?? ''),
                  'asr': _cleanTime(timings['Asr'] ?? ''),
                  'maghrib': _cleanTime(timings['Maghrib'] ?? ''),
                  'isha': _cleanTime(timings['Isha'] ?? ''),
                };
              }
            }
          }
        }
      }

      // Sadece bugünden itibaren 15 gün
      final filtered = <String, Map<String, String>>{};
      for (var i = 0; i < days; i++) {
        final date = now.add(Duration(days: i));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        if (results.containsKey(dateStr)) {
          filtered[dateStr] = results[dateStr]!;
        }
      }

      return filtered.isNotEmpty ? filtered : null;
    } catch (e) {
      return null;
    }
  }

  /// API'den gelen vakit string'ini temizle ("05:23 (EET)" -> "05:23")
  static String _cleanTime(String time) {
    final match = RegExp(r'(\d{1,2}:\d{2})').firstMatch(time);
    return match?.group(1) ?? time.trim();
  }

  // Konum al ve tek gün vakitlerini getir
  static Future<Map<String, String>?>
      fetchPrayerTimesForCurrentLocation() async {
    final position = await getCurrentLocation();
    if (position == null) return null;

    return await getPrayerTimes(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  // Konum al ve 15 günlük vakitleri getir
  static Future<Map<String, Map<String, String>>?>
      fetchMultiDayPrayerTimesForCurrentLocation({int days = 15}) async {
    final position = await getCurrentLocation();
    if (position == null) return null;

    return await getMultiDayPrayerTimes(
      latitude: position.latitude,
      longitude: position.longitude,
      days: days,
    );
  }
}

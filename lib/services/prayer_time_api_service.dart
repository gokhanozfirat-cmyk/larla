
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class PrayerTimeApiService {
  // Aladhan API - Diyanet İşleri Başkanlığı metodu (method=13)
  static const String _baseUrl = 'https://api.aladhan.com/v1/timings';

  // Konum izni al ve konumu getir
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum servisi açık mı kontrol et
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    // İzin kontrolü
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    // Konumu al
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  // Namaz vakitlerini API'den çek
  static Future<Map<String, String>?> getPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final url = Uri.parse(
        '$_baseUrl/$timestamp?latitude=$latitude&longitude=$longitude&method=13',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        return {
          'fajr': timings['Fajr'] ?? '', // İmsak/Sabah
          'sunrise': timings['Sunrise'] ?? '', // Güneş
          'dhuhr': timings['Dhuhr'] ?? '', // Öğle
          'asr': timings['Asr'] ?? '', // İkindi
          'maghrib': timings['Maghrib'] ?? '', // Akşam
          'isha': timings['Isha'] ?? '', // Yatsı
        };
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Konum al ve namaz vakitlerini getir (tek fonksiyon)
  static Future<Map<String, String>?>
      fetchPrayerTimesForCurrentLocation() async {
    final position = await getCurrentLocation();
    if (position == null) return null;

    return await getPrayerTimes(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

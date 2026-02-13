import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/prayer.dart';
import '../models/journey.dart';
import '../models/prayer_times.dart';
import '../services/supabase_service.dart';

class AppProvider with ChangeNotifier {
  double _fontSize = 18.0;
  List<Prayer> _prayers = [];
  List<Journey> _journeys = [];
  late PrayerTimes _prayerTimes;
  final SupabaseService _supabaseService = SupabaseService();
  StreamSubscription? _prayersSubscription;

  double get fontSize => _fontSize;
  List<Prayer> get prayers => _prayers;
  List<Journey> get journeys => _journeys;
  PrayerTimes get prayerTimes => _prayerTimes;

  AppProvider() {
    _prayerTimes = PrayerTimes();
    _loadData();
    // Realtime listener'ı çok gecikmeli başlat - Supabase hazır olsun
    Future.delayed(const Duration(seconds: 5), () {
      _listenToPrayers();
    });
  }

  // Realtime dinleme - Supabase'deki değişiklikleri anında alır
  void _listenToPrayers() {
    try {
      _prayersSubscription?.cancel();
      final stream = _supabaseService.watchPrayers();
      _prayersSubscription = stream.listen(
        (prayers) {
          if (prayers.isNotEmpty) {
            print('Prayers updated from Supabase: ${prayers.length} items');
            _prayers = prayers;
            notifyListeners();
          }
        },
        onError: (error) {
          print('Realtime error: $error');
          // Hata durumunda 10 saniye sonra yeniden bağlan
          Future.delayed(const Duration(seconds: 10), () {
            _listenToPrayers();
          });
        },
      );
    } catch (e) {
      print('Error setting up realtime listener: $e');
    }
  }

  // Manuel yenileme metodu
  Future<void> refreshPrayers() async {
    try {
      final supabasePrayers = await _supabaseService.getPrayers();
      if (supabasePrayers.isNotEmpty) {
        _prayers = supabasePrayers;
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing prayers: $e');
    }
  }

  @override
  void dispose() {
    _prayersSubscription?.cancel();
    super.dispose();
  }

  void increaseFontSize() {
    _fontSize += 2.0;
    notifyListeners();
    _saveFontSize();
  }

  void decreaseFontSize() {
    if (_fontSize > 12.0) {
      _fontSize -= 2.0;
      notifyListeners();
      _saveFontSize();
    }
  }

  void addPrayer(Prayer prayer) async {
    // Supabase'e ekle
    final success = await _supabaseService.addPrayer(prayer);
    if (!success) {
      // Offline fallback - yerel kaydet
      _prayers.add(prayer);
      notifyListeners();
      _savePrayers();
    }
  }

  void startJourney(Journey journey) {
    // Do not force the journey's current day. Keep it at 0 until the user records a read.
    _journeys.add(journey);
    notifyListeners();
    _saveJourneys();
  }

  void removePrayer(String id) async {
    // Supabase'den sil
    final success = await _supabaseService.deletePrayer(id);
    if (!success) {
      // Offline fallback
      _prayers.removeWhere((p) => p.id == id);
      notifyListeners();
      _savePrayers();
    }
  }

  void removeJourney(String id) {
    _journeys.removeWhere((j) => j.id == id);
    notifyListeners();
    _saveJourneys();
  }

  void updateJourney(Journey journey) {
    final index = _journeys.indexWhere((j) => j.id == journey.id);
    if (index != -1) {
      _journeys[index] = journey;
      notifyListeners();
      _saveJourneys();
    }
  }

  void updatePrayerTimes(PrayerTimes prayerTimes) {
    _prayerTimes = prayerTimes;
    notifyListeners();
    _savePrayerTimes();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('fontSize') ?? 18.0;

    final prayersJson = prefs.getStringList('prayers') ?? [];
    _prayers = prayersJson
        .map((json) {
          try {
            return Prayer.fromJson(jsonDecode(json));
          } catch (e) {
            print('Error parsing prayer: $e');
            return null;
          }
        })
        .whereType<Prayer>()
        .toList();

    final journeysJson = prefs.getStringList('journeys') ?? [];
    _journeys = journeysJson
        .map((json) {
          try {
            return Journey.fromJson(jsonDecode(json));
          } catch (e) {
            print('Error parsing journey: $e');
            return null;
          }
        })
        .whereType<Journey>()
        .toList();

    // Load prayer times
    final prayerTimesJson = prefs.getString('prayerTimes');
    if (prayerTimesJson != null) {
      try {
        final decoded = jsonDecode(prayerTimesJson);
        _prayerTimes = PrayerTimes.fromJson(decoded);
      } catch (e) {
        print('Error loading prayer times: $e');
      }
    }

    // Yerel veriler boşsa varsayılan duaları yükle
    if (_prayers.isEmpty) {
      await _loadDefaultPrayers();
    }

    // UI'ı hemen göster - BEKLEMEDEN
    notifyListeners();

    // Supabase'den duaları TAMAMEN ARKA PLANDA yükle - await YOK
    _loadSupabasePrayersInBackground();
  }

  // Supabase'den duaları arka planda yükle
  void _loadSupabasePrayersInBackground() {
    Future.delayed(const Duration(seconds: 3), () async {
      try {
        final supabasePrayers = await _supabaseService.getPrayers();
        if (supabasePrayers.isNotEmpty) {
          _prayers = supabasePrayers;
          notifyListeners();
        }
      } catch (e) {
        print('Error loading prayers from Supabase: $e');
      }
    });
  }
  Future<void> _loadDefaultPrayers() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/prayers.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _prayers = jsonList.map((json) => Prayer.fromJson(json)).toList();
      _savePrayers();
    } catch (e) {
      print('Error loading default prayers: $e');
      // If loading assets fails, do not inject hardcoded sample prayers.
      // Leave `_prayers` as-is (empty) so app data reflects real data.
    }
  }

  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', _fontSize);
  }

  Future<void> _savePrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final prayersJson = _prayers.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('prayers', prayersJson);
  }

  Future<void> _saveJourneys() async {
    final prefs = await SharedPreferences.getInstance();
    final journeysJson = _journeys.map((j) => jsonEncode(j.toJson())).toList();
    await prefs.setStringList('journeys', journeysJson);
  }

  Future<void> _savePrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final prayerTimesJson = jsonEncode(_prayerTimes.toJson());
    await prefs.setString('prayerTimes', prayerTimesJson);
  }
}

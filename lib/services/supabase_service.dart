import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prayer.dart';
import '../main.dart' show isSupabaseInitialized;

class SupabaseService {
  SupabaseClient? get _client {
    try {
      if (!isSupabaseInitialized) return null;
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }

  // Tüm duaları getir (timeout ile)
  Future<List<Prayer>> getPrayers() async {
    if (_client == null) {
      print('Supabase not ready yet');
      return [];
    }
    try {
      final response = await _client!
          .from('prayers')
          .select()
          .order('created_at', ascending: true)
          .timeout(const Duration(seconds: 10));

      return (response as List)
          .map((json) => Prayer(
                id: json['id'],
                title: json['title'] ?? '',
                description: json['description'] ?? '',
                arabicContent: json['arabic_content'] ?? '',
                content: json['content'] ?? '',
                hasCondition: json['has_condition'] ?? false,
                days: json['days'],
                timesPerDay: json['times_per_day'],
              ))
          .toList();
    } catch (e) {
      print('Error fetching prayers: $e');
      return [];
    }
  }

  // Dua ekle
  Future<bool> addPrayer(Prayer prayer) async {
    if (_client == null) return false;
    try {
      await _client!.from('prayers').insert({
        'title': prayer.title,
        'description': prayer.description,
        'arabic_content': prayer.arabicContent,
        'content': prayer.content,
        'has_condition': prayer.hasCondition,
        'days': prayer.days,
        'times_per_day': prayer.timesPerDay,
      });
      return true;
    } catch (e) {
      print('Error adding prayer: $e');
      return false;
    }
  }

  // Dua sil
  Future<bool> deletePrayer(String id) async {
    if (_client == null) return false;
    try {
      await _client!.from('prayers').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting prayer: $e');
      return false;
    }
  }

  // Dua güncelle
  Future<bool> updatePrayer(Prayer prayer) async {
    if (_client == null) return false;
    try {
      await _client!.from('prayers').update({
        'title': prayer.title,
        'description': prayer.description,
        'arabic_content': prayer.arabicContent,
        'content': prayer.content,
        'has_condition': prayer.hasCondition,
        'days': prayer.days,
        'times_per_day': prayer.timesPerDay,
      }).eq('id', prayer.id);
      return true;
    } catch (e) {
      print('Error updating prayer: $e');
      return false;
    }
  }

  // Realtime değişiklikleri dinle
  Stream<List<Prayer>> watchPrayers() {
    if (_client == null) {
      print('Supabase not ready for realtime');
      return Stream.value(<Prayer>[]);
    }
    try {
      return _client!
          .from('prayers')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: true)
          .map((data) {
            print('Realtime update received: ${data.length} prayers');
            return data
                .map((json) => Prayer(
                      id: json['id'],
                      title: json['title'] ?? '',
                      description: json['description'] ?? '',
                      arabicContent: json['arabic_content'] ?? '',
                      content: json['content'] ?? '',
                      hasCondition: json['has_condition'] ?? false,
                      days: json['days'],
                      timesPerDay: json['times_per_day'],
                    ))
                .toList();
          })
          .handleError((error) {
            print('Realtime stream error: $error');
            return <Prayer>[];
          });
    } catch (e) {
      print('Error setting up realtime stream: $e');
      return Stream.value(<Prayer>[]);
    }
  }

  // Manuel yenileme için
  Future<void> refreshPrayers() async {
    // Bu metod çağrıldığında stream otomatik güncellenir
  }
}

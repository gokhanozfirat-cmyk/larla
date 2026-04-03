import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prayer.dart';

class SupabaseService {
  static bool isInitialized = false;

  SupabaseClient? get _client {
    try {
      if (!isInitialized) return null;
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }

  // Tüm duaları getir (timeout ile)
  Future<List<Prayer>> getPrayers() async {
    if (_client == null) return [];
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
      return false;
    }
  }

  // Realtime değişiklikleri dinle
  Stream<List<Prayer>> watchPrayers() {
    if (_client == null) return Stream.value(<Prayer>[]);
    try {
      return _client!
          .from('prayers')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: true)
          .map((data) => data
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
              .toList())
          .handleError((error) => <Prayer>[]);
    } catch (e) {
      return Stream.value(<Prayer>[]);
    }
  }

  // Manuel yenileme için
  Future<void> refreshPrayers() async {
    // Bu metod çağrıldığında stream otomatik güncellenir
  }
}

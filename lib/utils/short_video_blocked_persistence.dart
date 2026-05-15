import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShortVideoBlockedPersistence {
  ShortVideoBlockedPersistence._();

  static const String _key = 'short_video_blocked_ids_v1';
  static const int _maxItems = 2000;

  static Future<Set<String>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <String>{};
      }
      return decoded.whereType<String>().toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> add(String videoId) async {
    final current = await loadAll();
    current.add(videoId);
    if (current.length > _maxItems) {
      final trimmed = current.take(_maxItems).toSet();
      await _save(trimmed);
      return;
    }
    await _save(current);
  }

  static Future<void> remove(String videoId) async {
    final current = await loadAll();
    current.remove(videoId);
    await _save(current);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _save(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(ids.toList(growable: false)));
  }
}

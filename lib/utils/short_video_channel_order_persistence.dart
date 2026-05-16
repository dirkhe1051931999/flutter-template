import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShortVideoChannelOrderPersistence {
  ShortVideoChannelOrderPersistence._();

  static const String _key = 'short_video_channel_order_v1';

  static Future<List<String>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return null;
      }
      return decoded.whereType<String>().toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(ids));
  }
}

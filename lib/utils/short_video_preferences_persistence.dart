import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShortVideoPreferencesSnapshot {
  const ShortVideoPreferencesSnapshot({
    required this.recordWatchHistory,
    required this.autoPlayNextVideo,
  });

  final bool recordWatchHistory;
  final bool autoPlayNextVideo;
}

class ShortVideoPreferencesPersistence {
  ShortVideoPreferencesPersistence._();

  static const _key = 'short_video_preferences_v1';

  static Future<void> save({
    required bool recordWatchHistory,
    required bool autoPlayNextVideo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{
      'recordWatchHistory': recordWatchHistory,
      'autoPlayNextVideo': autoPlayNextVideo,
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  static Future<ShortVideoPreferencesSnapshot?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final recordRaw = decoded['recordWatchHistory'];
      final autoPlayRaw = decoded['autoPlayNextVideo'];
      return ShortVideoPreferencesSnapshot(
        recordWatchHistory: recordRaw is bool ? recordRaw : true,
        autoPlayNextVideo: autoPlayRaw is bool ? autoPlayRaw : true,
      );
    } catch (_) {
      return null;
    }
  }
}

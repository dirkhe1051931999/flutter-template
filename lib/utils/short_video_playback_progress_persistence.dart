import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShortVideoPlaybackProgressEntry {
  const ShortVideoPlaybackProgressEntry({
    required this.videoId,
    required this.positionMillis,
    required this.durationMillis,
    required this.updatedAtMillis,
  });

  final String videoId;
  final int positionMillis;
  final int durationMillis;
  final int updatedAtMillis;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'videoId': videoId,
      'positionMillis': positionMillis,
      'durationMillis': durationMillis,
      'updatedAtMillis': updatedAtMillis,
    };
  }

  static ShortVideoPlaybackProgressEntry? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return null;
    }

    final videoId = json['videoId'];
    final positionMillis = json['positionMillis'];
    final durationMillis = json['durationMillis'];
    final updatedAtMillis = json['updatedAtMillis'];

    if (videoId is! String ||
        positionMillis is! int ||
        durationMillis is! int ||
        updatedAtMillis is! int) {
      return null;
    }

    return ShortVideoPlaybackProgressEntry(
      videoId: videoId,
      positionMillis: positionMillis,
      durationMillis: durationMillis,
      updatedAtMillis: updatedAtMillis,
    );
  }
}

class ShortVideoPlaybackProgressPersistence {
  ShortVideoPlaybackProgressPersistence._();

  static const String _key = 'short_video_playback_progress_v1';
  static const int _maxItems = 1000;

  static Future<ShortVideoPlaybackProgressEntry?> load(String videoId) async {
    final map = await _loadMap();
    return map[videoId];
  }

  static Future<void> save(ShortVideoPlaybackProgressEntry entry) async {
    final map = await _loadMap();
    map[entry.videoId] = entry;

    if (map.length > _maxItems) {
      final sorted = map.values.toList(growable: false)
        ..sort((a, b) => b.updatedAtMillis.compareTo(a.updatedAtMillis));
      final trimmed = sorted.take(_maxItems);
      final next = <String, ShortVideoPlaybackProgressEntry>{
        for (final item in trimmed) item.videoId: item,
      };
      await _saveMap(next);
      return;
    }

    await _saveMap(map);
  }

  static Future<void> remove(String videoId) async {
    final map = await _loadMap();
    map.remove(videoId);
    await _saveMap(map);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<Map<String, ShortVideoPlaybackProgressEntry>> _loadMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <String, ShortVideoPlaybackProgressEntry>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <String, ShortVideoPlaybackProgressEntry>{};
      }

      final entries = decoded
          .map(ShortVideoPlaybackProgressEntry.fromJson)
          .whereType<ShortVideoPlaybackProgressEntry>();

      return <String, ShortVideoPlaybackProgressEntry>{
        for (final entry in entries) entry.videoId: entry,
      };
    } catch (_) {
      return <String, ShortVideoPlaybackProgressEntry>{};
    }
  }

  static Future<void> _saveMap(
    Map<String, ShortVideoPlaybackProgressEntry> map,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(
      map.values.map((entry) => entry.toJson()).toList(growable: false),
    );
    await prefs.setString(_key, raw);
  }
}

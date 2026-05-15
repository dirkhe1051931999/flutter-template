import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShortVideoOfflineCacheEntry {
  const ShortVideoOfflineCacheEntry({
    required this.videoId,
    required this.title,
    required this.updateTime,
    required this.coverUrl,
    required this.videoUrl,
    required this.savedAtMillis,
    this.source,
  });

  final String videoId;
  final String title;
  final String updateTime;
  final String coverUrl;
  final String videoUrl;
  final String? source;
  final int savedAtMillis;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'videoId': videoId,
      'title': title,
      'updateTime': updateTime,
      'coverUrl': coverUrl,
      'videoUrl': videoUrl,
      'source': source,
      'savedAtMillis': savedAtMillis,
    };
  }

  static ShortVideoOfflineCacheEntry? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return null;
    }

    final videoId = json['videoId'];
    final title = json['title'];
    final updateTime = json['updateTime'];
    final coverUrl = json['coverUrl'];
    final videoUrl = json['videoUrl'];
    final source = json['source'];
    final savedAtMillis = json['savedAtMillis'];

    if (videoId is! String ||
        title is! String ||
        coverUrl is! String ||
        videoUrl is! String ||
        savedAtMillis is! int) {
      return null;
    }

    return ShortVideoOfflineCacheEntry(
      videoId: videoId,
      title: title,
      updateTime: updateTime is String ? updateTime : '',
      coverUrl: coverUrl,
      videoUrl: videoUrl,
      source: source is String ? source : null,
      savedAtMillis: savedAtMillis,
    );
  }
}

class ShortVideoOfflineCachePersistence {
  ShortVideoOfflineCachePersistence._();

  static const String _key = 'short_video_offline_cache_v1';
  static const int _maxItems = 500;

  static Future<List<ShortVideoOfflineCacheEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const <ShortVideoOfflineCacheEntry>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <ShortVideoOfflineCacheEntry>[];
      }

      final entries = decoded
          .map(ShortVideoOfflineCacheEntry.fromJson)
          .whereType<ShortVideoOfflineCacheEntry>()
          .toList(growable: false)
        ..sort((a, b) => b.savedAtMillis.compareTo(a.savedAtMillis));

      return entries;
    } catch (_) {
      return const <ShortVideoOfflineCacheEntry>[];
    }
  }

  static Future<void> save(ShortVideoOfflineCacheEntry entry) async {
    final existing = await loadAll();
    final merged = <ShortVideoOfflineCacheEntry>[entry];
    for (final item in existing) {
      if (item.videoId == entry.videoId) {
        continue;
      }
      merged.add(item);
      if (merged.length >= _maxItems) {
        break;
      }
    }
    await _saveAll(merged);
  }

  static Future<void> remove(String videoId) async {
    final existing = await loadAll();
    final next = existing
        .where((entry) => entry.videoId != videoId)
        .toList(growable: false);
    await _saveAll(next);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _saveAll(List<ShortVideoOfflineCacheEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(_key, raw);
  }
}

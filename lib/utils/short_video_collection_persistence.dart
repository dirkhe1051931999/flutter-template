import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShortVideoCollectionEntry {
  const ShortVideoCollectionEntry({
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

  DateTime get savedAt => DateTime.fromMillisecondsSinceEpoch(savedAtMillis);

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

  static ShortVideoCollectionEntry? fromJson(Object? json) {
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

    return ShortVideoCollectionEntry(
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

class ShortVideoCollectionPersistence {
  const ShortVideoCollectionPersistence._(this._key);

  static const ShortVideoCollectionPersistence favorites =
      ShortVideoCollectionPersistence._('short_video_favorites_v1');
  static const ShortVideoCollectionPersistence watchLater =
      ShortVideoCollectionPersistence._('short_video_watch_later_v1');

  static const int _maxItems = 500;

  final String _key;

  Future<List<ShortVideoCollectionEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const <ShortVideoCollectionEntry>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <ShortVideoCollectionEntry>[];
      }
      final entries = decoded
          .map(ShortVideoCollectionEntry.fromJson)
          .whereType<ShortVideoCollectionEntry>()
          .toList(growable: false);
      entries.sort((a, b) => b.savedAtMillis.compareTo(a.savedAtMillis));
      return entries;
    } catch (_) {
      return const <ShortVideoCollectionEntry>[];
    }
  }

  Future<bool> contains(String videoId) async {
    final entries = await loadAll();
    return entries.any((entry) => entry.videoId == videoId);
  }

  Future<void> save(ShortVideoCollectionEntry entry) async {
    final existing = await loadAll();
    final merged = <ShortVideoCollectionEntry>[entry];
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

  Future<void> remove(String videoId) async {
    final existing = await loadAll();
    final next = existing
        .where((entry) => entry.videoId != videoId)
        .toList(growable: false);
    await _saveAll(next);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _saveAll(List<ShortVideoCollectionEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(_key, raw);
  }
}

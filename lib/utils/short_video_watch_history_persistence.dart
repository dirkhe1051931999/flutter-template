import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShortVideoWatchHistoryEntry {
  const ShortVideoWatchHistoryEntry({
    required this.videoId,
    required this.title,
    required this.updateTime,
    required this.coverUrl,
    required this.videoUrl,
    required this.watchedAtMillis,
    this.source,
    this.type = 'phvideo',
    this.commentsUrl,
    this.commentsCount = '0',
  });

  final String videoId;
  final String title;
  final String updateTime;
  final String coverUrl;
  final String videoUrl;
  final String? source;
  final String type;
  final String? commentsUrl;
  final String commentsCount;
  final int watchedAtMillis;

  DateTime get watchedAt => DateTime.fromMillisecondsSinceEpoch(watchedAtMillis);

  ShortVideoWatchHistoryEntry copyWith({
    String? videoId,
    String? title,
    String? updateTime,
    String? coverUrl,
    String? videoUrl,
    String? source,
    String? type,
    String? commentsUrl,
    String? commentsCount,
    int? watchedAtMillis,
  }) {
    return ShortVideoWatchHistoryEntry(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      updateTime: updateTime ?? this.updateTime,
      coverUrl: coverUrl ?? this.coverUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      source: source ?? this.source,
      type: type ?? this.type,
      commentsUrl: commentsUrl ?? this.commentsUrl,
      commentsCount: commentsCount ?? this.commentsCount,
      watchedAtMillis: watchedAtMillis ?? this.watchedAtMillis,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'videoId': videoId,
      'title': title,
      'updateTime': updateTime,
      'coverUrl': coverUrl,
      'videoUrl': videoUrl,
      'source': source,
      'type': type,
      'commentsUrl': commentsUrl,
      'commentsCount': commentsCount,
      'watchedAtMillis': watchedAtMillis,
    };
  }

  static ShortVideoWatchHistoryEntry? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return null;
    }

    final videoId = json['videoId'];
    final title = json['title'];
    final updateTime = json['updateTime'];
    final coverUrl = json['coverUrl'];
    final videoUrl = json['videoUrl'];
    final source = json['source'];
    final type = json['type'];
    final commentsUrl = json['commentsUrl'];
    final commentsCount = json['commentsCount'];
    final watchedAtMillis = json['watchedAtMillis'];

    if (videoId is! String ||
        title is! String ||
        coverUrl is! String ||
        videoUrl is! String ||
        watchedAtMillis is! int) {
      return null;
    }

    return ShortVideoWatchHistoryEntry(
      videoId: videoId,
      title: title,
      updateTime: updateTime is String ? updateTime : '',
      coverUrl: coverUrl,
      videoUrl: videoUrl,
      source: source is String ? source : null,
      type: type is String && type.isNotEmpty ? type : 'phvideo',
      commentsUrl: commentsUrl is String && commentsUrl.isNotEmpty
          ? commentsUrl
          : null,
      commentsCount: commentsCount is String && commentsCount.isNotEmpty
          ? commentsCount
          : '0',
      watchedAtMillis: watchedAtMillis,
    );
  }
}

class ShortVideoWatchHistoryPersistence {
  ShortVideoWatchHistoryPersistence._();

  static const String _key = 'short_video_watch_history_v1';
  static const int _maxItems = 500;

  static Future<List<ShortVideoWatchHistoryEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const <ShortVideoWatchHistoryEntry>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <ShortVideoWatchHistoryEntry>[];
      }

      final entries = decoded
          .map(ShortVideoWatchHistoryEntry.fromJson)
          .whereType<ShortVideoWatchHistoryEntry>()
          .toList(growable: false);
      entries.sort((a, b) => b.watchedAtMillis.compareTo(a.watchedAtMillis));
      return entries;
    } catch (_) {
      return const <ShortVideoWatchHistoryEntry>[];
    }
  }

  static Future<void> record(ShortVideoWatchHistoryEntry entry) async {
    final existing = await loadAll();
    final merged = <ShortVideoWatchHistoryEntry>[entry];
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

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> remove(String videoId) async {
    final existing = await loadAll();
    final next = existing
        .where((entry) => entry.videoId != videoId)
        .toList(growable: false);
    await _saveAll(next);
  }

  static Future<void> _saveAll(List<ShortVideoWatchHistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(_key, raw);
  }
}

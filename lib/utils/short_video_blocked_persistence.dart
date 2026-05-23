import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShortVideoBlockedSnapshot {
  const ShortVideoBlockedSnapshot({
    required this.videoIds,
    required this.sources,
    required this.titleKeywords,
  });

  final Set<String> videoIds;
  final Set<String> sources;
  final Set<String> titleKeywords;

  bool get isEmpty =>
      videoIds.isEmpty && sources.isEmpty && titleKeywords.isEmpty;

  bool isBlocked({
    required String videoId,
    required String title,
    String? source,
  }) {
    if (videoIds.contains(videoId)) {
      return true;
    }

    final normalizedSource = _normalize(source);
    if (normalizedSource != null && sources.contains(normalizedSource)) {
      return true;
    }

    final normalizedTitle = _normalize(title);
    if (normalizedTitle == null) {
      return false;
    }

    for (final keyword in titleKeywords) {
      if (normalizedTitle.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'videoIds': videoIds.toList(growable: false),
      'sources': sources.toList(growable: false),
      'titleKeywords': titleKeywords.toList(growable: false),
    };
  }

  static ShortVideoBlockedSnapshot fromJson(Object? json) {
    if (json is List) {
      return ShortVideoBlockedSnapshot(
        videoIds: json.whereType<String>().toSet(),
        sources: <String>{},
        titleKeywords: <String>{},
      );
    }

    if (json is! Map<String, dynamic>) {
      return const ShortVideoBlockedSnapshot(
        videoIds: <String>{},
        sources: <String>{},
        titleKeywords: <String>{},
      );
    }

    return ShortVideoBlockedSnapshot(
      videoIds: _stringSetOf(json['videoIds']),
      sources: _stringSetOf(json['sources']),
      titleKeywords: _stringSetOf(json['titleKeywords']),
    );
  }

  static Set<String> _stringSetOf(Object? value) {
    if (value is! List) {
      return <String>{};
    }
    return value
        .whereType<String>()
        .map(_normalize)
        .whereType<String>()
        .toSet();
  }
}

class ShortVideoBlockedPersistence {
  ShortVideoBlockedPersistence._();

  static const String _key = 'short_video_blocked_ids_v1';
  static const int _maxItems = 2000;

  static Future<Set<String>> loadAll() async {
    final snapshot = await loadSnapshot();
    return snapshot.videoIds;
  }

  static Future<ShortVideoBlockedSnapshot> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const ShortVideoBlockedSnapshot(
        videoIds: <String>{},
        sources: <String>{},
        titleKeywords: <String>{},
      );
    }

    try {
      return ShortVideoBlockedSnapshot.fromJson(jsonDecode(raw));
    } catch (_) {
      return const ShortVideoBlockedSnapshot(
        videoIds: <String>{},
        sources: <String>{},
        titleKeywords: <String>{},
      );
    }
  }

  static Future<void> add(String videoId) {
    return addVideo(videoId);
  }

  static Future<void> addVideo(String videoId) async {
    final normalized = _normalize(videoId);
    if (normalized == null) {
      return;
    }
    final snapshot = await loadSnapshot();
    await _save(
      ShortVideoBlockedSnapshot(
        videoIds: _trimmed(<String>{...snapshot.videoIds, normalized}),
        sources: snapshot.sources,
        titleKeywords: snapshot.titleKeywords,
      ),
    );
  }

  static Future<void> addSource(String? source) async {
    final normalized = _normalize(source);
    if (normalized == null) {
      return;
    }
    final snapshot = await loadSnapshot();
    await _save(
      ShortVideoBlockedSnapshot(
        videoIds: snapshot.videoIds,
        sources: _trimmed(<String>{...snapshot.sources, normalized}),
        titleKeywords: snapshot.titleKeywords,
      ),
    );
  }

  static Future<void> addTitleKeyword(String keyword) async {
    final normalized = _normalize(keyword);
    if (normalized == null) {
      return;
    }
    final snapshot = await loadSnapshot();
    await _save(
      ShortVideoBlockedSnapshot(
        videoIds: snapshot.videoIds,
        sources: snapshot.sources,
        titleKeywords: _trimmed(<String>{
          ...snapshot.titleKeywords,
          normalized,
        }),
      ),
    );
  }

  static Future<void> remove(String videoId) {
    return removeVideo(videoId);
  }

  static Future<void> removeVideo(String videoId) async {
    final normalized = _normalize(videoId);
    if (normalized == null) {
      return;
    }
    final snapshot = await loadSnapshot();
    await _save(
      ShortVideoBlockedSnapshot(
        videoIds: <String>{...snapshot.videoIds}..remove(normalized),
        sources: snapshot.sources,
        titleKeywords: snapshot.titleKeywords,
      ),
    );
  }

  static Future<void> removeSource(String source) async {
    final normalized = _normalize(source);
    if (normalized == null) {
      return;
    }
    final snapshot = await loadSnapshot();
    await _save(
      ShortVideoBlockedSnapshot(
        videoIds: snapshot.videoIds,
        sources: <String>{...snapshot.sources}..remove(normalized),
        titleKeywords: snapshot.titleKeywords,
      ),
    );
  }

  static Future<void> removeTitleKeyword(String keyword) async {
    final normalized = _normalize(keyword);
    if (normalized == null) {
      return;
    }
    final snapshot = await loadSnapshot();
    await _save(
      ShortVideoBlockedSnapshot(
        videoIds: snapshot.videoIds,
        sources: snapshot.sources,
        titleKeywords: <String>{...snapshot.titleKeywords}..remove(normalized),
      ),
    );
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Set<String> _trimmed(Set<String> values) {
    if (values.length <= _maxItems) {
      return values;
    }
    return values.take(_maxItems).toSet();
  }

  static Future<void> _save(ShortVideoBlockedSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(snapshot.toJson()));
  }
}

String? _normalize(String? value) {
  final trimmed = value?.trim().toLowerCase();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

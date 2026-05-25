import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShortVideoArticleHistoryEntry {
  const ShortVideoArticleHistoryEntry({
    required this.docId,
    required this.title,
    required this.source,
    required this.updateTime,
    required this.coverUrl,
    required this.detailUrl,
    required this.viewedAtMillis,
  });

  final String docId;
  final String title;
  final String source;
  final String updateTime;
  final String coverUrl;
  final String detailUrl;
  final int viewedAtMillis;

  DateTime get viewedAt => DateTime.fromMillisecondsSinceEpoch(viewedAtMillis);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'docId': docId,
      'title': title,
      'source': source,
      'updateTime': updateTime,
      'coverUrl': coverUrl,
      'detailUrl': detailUrl,
      'viewedAtMillis': viewedAtMillis,
    };
  }

  static ShortVideoArticleHistoryEntry? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return null;
    }

    final docId = json['docId'];
    final title = json['title'];
    final source = json['source'];
    final updateTime = json['updateTime'];
    final coverUrl = json['coverUrl'];
    final detailUrl = json['detailUrl'];
    final viewedAtMillis = json['viewedAtMillis'];

    if (docId is! String ||
        title is! String ||
        source is! String ||
        updateTime is! String ||
        coverUrl is! String ||
        detailUrl is! String ||
        viewedAtMillis is! int) {
      return null;
    }

    return ShortVideoArticleHistoryEntry(
      docId: docId,
      title: title,
      source: source,
      updateTime: updateTime,
      coverUrl: coverUrl,
      detailUrl: detailUrl,
      viewedAtMillis: viewedAtMillis,
    );
  }
}

class ShortVideoArticleHistoryPersistence {
  ShortVideoArticleHistoryPersistence._();

  static const String _key = 'short_video_article_history_v1';
  static const int _maxItems = 500;

  static Future<List<ShortVideoArticleHistoryEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const <ShortVideoArticleHistoryEntry>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const <ShortVideoArticleHistoryEntry>[];
      }
      final entries = decoded
          .map(ShortVideoArticleHistoryEntry.fromJson)
          .whereType<ShortVideoArticleHistoryEntry>()
          .toList(growable: false);
      entries.sort((a, b) => b.viewedAtMillis.compareTo(a.viewedAtMillis));
      return entries;
    } catch (_) {
      return const <ShortVideoArticleHistoryEntry>[];
    }
  }

  static Future<void> record(ShortVideoArticleHistoryEntry entry) async {
    final existing = await loadAll();
    final merged = <ShortVideoArticleHistoryEntry>[entry];
    for (final item in existing) {
      if (item.docId == entry.docId) {
        continue;
      }
      merged.add(item);
      if (merged.length >= _maxItems) {
        break;
      }
    }
    await _saveAll(merged);
  }

  static Future<void> remove(String docId) async {
    final existing = await loadAll();
    final next = existing
        .where((entry) => entry.docId != docId)
        .toList(growable: false);
    await _saveAll(next);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _saveAll(
    List<ShortVideoArticleHistoryEntry> entries,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(
      entries.map((entry) => entry.toJson()).toList(growable: false),
    );
    await prefs.setString(_key, raw);
  }
}

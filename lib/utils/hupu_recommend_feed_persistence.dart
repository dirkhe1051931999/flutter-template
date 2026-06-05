import 'dart:convert';

import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HupuRecommendFeedCacheSnapshot {
  const HupuRecommendFeedCacheSnapshot({
    required this.cachedAtMillis,
    required this.response,
  });

  final int cachedAtMillis;
  final HupuHotListResponse response;

  bool isFresh(Duration maxAge) {
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);
    return DateTime.now().difference(cachedAt) <= maxAge;
  }

  factory HupuRecommendFeedCacheSnapshot.fromJson(Map<String, dynamic> json) {
    return HupuRecommendFeedCacheSnapshot(
      cachedAtMillis: _asInt(json['cachedAtMillis']),
      response: HupuHotListResponse.fromJson(
        Map<String, dynamic>.from(
          json['response'] as Map<dynamic, dynamic>? ?? <String, dynamic>{},
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'cachedAtMillis': cachedAtMillis,
      'response': response.toJson(),
    };
  }
}

class HupuRecommendFeedPersistence {
  HupuRecommendFeedPersistence._();

  static const String _cacheKey = 'hupu_recommend_feed_cache_v1';

  static Future<HupuRecommendFeedCacheSnapshot?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return HupuRecommendFeedCacheSnapshot.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(HupuRecommendFeedCacheSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(snapshot.toJson()));
  }
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

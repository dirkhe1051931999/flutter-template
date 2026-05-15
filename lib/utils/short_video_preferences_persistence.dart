import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShortVideoPreferencesSnapshot {
  const ShortVideoPreferencesSnapshot({
    required this.recordWatchHistory,
    required this.autoPlayNextVideo,
    required this.playbackRate,
    required this.preloadPagesCount,
    required this.keepWindow,
    required this.videoFitMode,
  });

  final bool recordWatchHistory;
  final bool autoPlayNextVideo;
  final double playbackRate;
  final int preloadPagesCount;
  final int keepWindow;
  final String videoFitMode;
}

class ShortVideoPreferencesPersistence {
  ShortVideoPreferencesPersistence._();

  static const _key = 'short_video_preferences_v1';

  static Future<void> save({
    required bool recordWatchHistory,
    required bool autoPlayNextVideo,
    required double playbackRate,
    required int preloadPagesCount,
    required int keepWindow,
    required String videoFitMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{
      'recordWatchHistory': recordWatchHistory,
      'autoPlayNextVideo': autoPlayNextVideo,
      'playbackRate': playbackRate,
      'preloadPagesCount': preloadPagesCount,
      'keepWindow': keepWindow,
      'videoFitMode': videoFitMode,
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
      final playbackRateRaw = decoded['playbackRate'];
      final preloadPagesCountRaw = decoded['preloadPagesCount'];
      final keepWindowRaw = decoded['keepWindow'];
      final videoFitModeRaw = decoded['videoFitMode'];
      return ShortVideoPreferencesSnapshot(
        recordWatchHistory: recordRaw is bool ? recordRaw : true,
        autoPlayNextVideo: autoPlayRaw is bool ? autoPlayRaw : true,
        playbackRate: playbackRateRaw is num ? playbackRateRaw.toDouble() : 1.0,
        preloadPagesCount: preloadPagesCountRaw is int ? preloadPagesCountRaw : 2,
        keepWindow: keepWindowRaw is int ? keepWindowRaw : 1,
        videoFitMode: videoFitModeRaw is String ? videoFitModeRaw : 'cover',
      );
    } catch (_) {
      return null;
    }
  }
}

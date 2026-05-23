import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShortVideoPreferencesSnapshot {
  const ShortVideoPreferencesSnapshot({
    required this.recordWatchHistory,
    required this.autoPlayOnEnter,
    required this.rememberPlaybackProgress,
    required this.autoPlayNextVideo,
    required this.playbackRate,
    required this.preloadPagesCount,
    required this.keepWindow,
    required this.videoFitMode,
    required this.danmakuEnabled,
    required this.danmakuOpacity,
    required this.danmakuFontScale,
    required this.danmakuFontWeight,
    required this.danmakuSpeed,
    required this.danmakuArea,
  });

  final bool recordWatchHistory;
  final bool autoPlayOnEnter;
  final bool rememberPlaybackProgress;
  final bool autoPlayNextVideo;
  final double playbackRate;
  final int preloadPagesCount;
  final int keepWindow;
  final String videoFitMode;
  final bool danmakuEnabled;
  final double danmakuOpacity;
  final double danmakuFontScale;
  final int danmakuFontWeight;
  final double danmakuSpeed;
  final double danmakuArea;
}

class ShortVideoPreferencesPersistence {
  ShortVideoPreferencesPersistence._();

  static const _key = 'short_video_preferences_v1';

  static Future<void> save({
    required bool recordWatchHistory,
    required bool autoPlayOnEnter,
    required bool rememberPlaybackProgress,
    required bool autoPlayNextVideo,
    required double playbackRate,
    required int preloadPagesCount,
    required int keepWindow,
    required String videoFitMode,
    required bool danmakuEnabled,
    required double danmakuOpacity,
    required double danmakuFontScale,
    required int danmakuFontWeight,
    required double danmakuSpeed,
    required double danmakuArea,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{
      'recordWatchHistory': recordWatchHistory,
      'autoPlayOnEnter': autoPlayOnEnter,
      'rememberPlaybackProgress': rememberPlaybackProgress,
      'autoPlayNextVideo': autoPlayNextVideo,
      'playbackRate': playbackRate,
      'preloadPagesCount': preloadPagesCount,
      'keepWindow': keepWindow,
      'videoFitMode': videoFitMode,
      'danmakuEnabled': danmakuEnabled,
      'danmakuOpacity': danmakuOpacity,
      'danmakuFontScale': danmakuFontScale,
      'danmakuFontWeight': danmakuFontWeight,
      'danmakuSpeed': danmakuSpeed,
      'danmakuArea': danmakuArea,
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
      final autoPlayOnEnterRaw = decoded['autoPlayOnEnter'];
      final rememberProgressRaw = decoded['rememberPlaybackProgress'];
      final autoPlayRaw = decoded['autoPlayNextVideo'];
      final playbackRateRaw = decoded['playbackRate'];
      final preloadPagesCountRaw = decoded['preloadPagesCount'];
      final keepWindowRaw = decoded['keepWindow'];
      final videoFitModeRaw = decoded['videoFitMode'];
      final danmakuEnabledRaw = decoded['danmakuEnabled'];
      final danmakuOpacityRaw = decoded['danmakuOpacity'];
      final danmakuFontScaleRaw = decoded['danmakuFontScale'];
      final danmakuFontWeightRaw = decoded['danmakuFontWeight'];
      final danmakuSpeedRaw = decoded['danmakuSpeed'];
      final danmakuAreaRaw = decoded['danmakuArea'];
      return ShortVideoPreferencesSnapshot(
        recordWatchHistory: recordRaw is bool ? recordRaw : true,
        autoPlayOnEnter:
            autoPlayOnEnterRaw is bool ? autoPlayOnEnterRaw : true,
        rememberPlaybackProgress:
            rememberProgressRaw is bool ? rememberProgressRaw : true,
        autoPlayNextVideo: autoPlayRaw is bool ? autoPlayRaw : true,
        playbackRate: playbackRateRaw is num ? playbackRateRaw.toDouble() : 1.0,
        preloadPagesCount:
            preloadPagesCountRaw is int ? preloadPagesCountRaw : 2,
        keepWindow: keepWindowRaw is int ? keepWindowRaw : 1,
        videoFitMode: videoFitModeRaw is String ? videoFitModeRaw : 'cover',
        danmakuEnabled: danmakuEnabledRaw is bool ? danmakuEnabledRaw : true,
        danmakuOpacity:
            danmakuOpacityRaw is num ? danmakuOpacityRaw.toDouble() : 0.82,
        danmakuFontScale:
            danmakuFontScaleRaw is num ? danmakuFontScaleRaw.toDouble() : 1.0,
        danmakuFontWeight:
            danmakuFontWeightRaw is int ? danmakuFontWeightRaw : 600,
        danmakuSpeed: danmakuSpeedRaw is num ? danmakuSpeedRaw.toDouble() : 1.0,
        danmakuArea: danmakuAreaRaw is num ? danmakuAreaRaw.toDouble() : 0.7,
      );
    } catch (_) {
      return null;
    }
  }
}

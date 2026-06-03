import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:oolaf_flutted/store/oolaf_music/state.dart';

class OolafPlaybackSnapshot {
  const OolafPlaybackSnapshot({
    required this.queue,
    required this.queueIndex,
    required this.queueGroupKey,
    required this.loopMode,
    required this.nowPlaying,
    required this.positionMillis,
    required this.wasPlaying,
  });

  final List<OolafTrack> queue;
  final int queueIndex;
  final String queueGroupKey;
  final OolafLoopMode loopMode;
  final OolafNowPlaying? nowPlaying;
  final int positionMillis;
  final bool wasPlaying;
}

class OolafPlaybackPersistence {
  OolafPlaybackPersistence._();

  static const _key = 'oolaf_playback_snapshot_v1';

  static Future<void> save({
    required List<OolafTrack> queue,
    required int queueIndex,
    required String queueGroupKey,
    required OolafLoopMode loopMode,
    required OolafNowPlaying? nowPlaying,
    required int positionMillis,
    required bool wasPlaying,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{
      'queue': queue
          .map((t) => <String, dynamic>{
                'title': t.title,
                'cdnUrl': t.cdnUrl,
              })
          .toList(),
      'queueIndex': queueIndex,
      'queueGroupKey': queueGroupKey,
      'loopMode': loopMode.name,
      'positionMillis': positionMillis,
      'wasPlaying': wasPlaying,
      'nowPlaying': nowPlaying == null
          ? null
          : <String, dynamic>{
              'title': nowPlaying.title,
              'cdnUrl': nowPlaying.cdnUrl,
            },
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  static Future<OolafPlaybackSnapshot?> load() async {
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

      final queueRaw = decoded['queue'];
      final queue = <OolafTrack>[];
      if (queueRaw is List) {
        for (final item in queueRaw) {
          if (item is Map<String, dynamic>) {
            final title = item['title'];
            final cdnUrl = item['cdnUrl'];
            if (title is String && cdnUrl is String) {
              queue.add(OolafTrack(title: title, cdnUrl: cdnUrl));
            }
          }
        }
      }

      final loopModeRaw = decoded['loopMode'];
      final loopMode = OolafLoopMode.values.firstWhere(
        (m) => m.name == loopModeRaw,
        orElse: () => OolafLoopMode.all,
      );

      OolafNowPlaying? nowPlaying;
      final npRaw = decoded['nowPlaying'];
      if (npRaw is Map<String, dynamic>) {
        final title = npRaw['title'];
        final cdnUrl = npRaw['cdnUrl'];
        if (title is String && cdnUrl is String) {
          nowPlaying = OolafNowPlaying(title: title, cdnUrl: cdnUrl);
        }
      }

      final queueIndexRaw = decoded['queueIndex'];
      final queueIndex = queueIndexRaw is num ? queueIndexRaw.toInt() : -1;
      final groupKeyRaw = decoded['queueGroupKey'];
      final queueGroupKey = groupKeyRaw is String ? groupKeyRaw : '';
      final positionMillisRaw = decoded['positionMillis'];
      final positionMillis =
          positionMillisRaw is num ? positionMillisRaw.toInt() : 0;
      final wasPlayingRaw = decoded['wasPlaying'];
      final wasPlaying = wasPlayingRaw is bool ? wasPlayingRaw : false;

      return OolafPlaybackSnapshot(
        queue: queue,
        queueIndex: queueIndex,
        queueGroupKey: queueGroupKey,
        loopMode: loopMode,
        nowPlaying: nowPlaying,
        positionMillis: positionMillis < 0 ? 0 : positionMillis,
        wasPlaying: wasPlaying,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

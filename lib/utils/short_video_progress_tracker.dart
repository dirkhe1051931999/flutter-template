import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';
import 'package:oolaf_flutted/utils/short_video_playback_progress_persistence.dart';

class ShortVideoProgressTracker {
  ShortVideoProgressTracker({
    this.saveInterval = const Duration(seconds: 2),
    this.minRestorePosition = const Duration(seconds: 3),
    this.restartThreshold = const Duration(seconds: 3),
  });

  final Duration saveInterval;
  final Duration minRestorePosition;
  final Duration restartThreshold;

  int _lastSaveAtMillis = 0;

  Future<void> restore({
    required bool enabled,
    required String videoId,
    required OolafVideoController controller,
  }) async {
    if (!enabled) {
      return;
    }

    final saved = await ShortVideoPlaybackProgressPersistence.load(videoId);
    if (saved == null) {
      return;
    }
    if (saved.positionMillis < minRestorePosition.inMilliseconds ||
        saved.durationMillis <= 0) {
      return;
    }

    final remain = saved.durationMillis - saved.positionMillis;
    if (remain <= restartThreshold.inMilliseconds) {
      return;
    }

    await controller.seekTo(Duration(milliseconds: saved.positionMillis));
  }

  Future<void> save({
    required bool enabled,
    required String videoId,
    required OolafVideoController controller,
    bool force = false,
  }) async {
    if (!enabled) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (!force && now - _lastSaveAtMillis < saveInterval.inMilliseconds) {
      return;
    }

    final duration = controller.duration.value;
    final position = controller.position.value;
    if (duration <= Duration.zero || position <= Duration.zero) {
      return;
    }

    _lastSaveAtMillis = now;
    await ShortVideoPlaybackProgressPersistence.save(
      ShortVideoPlaybackProgressEntry(
        videoId: videoId,
        positionMillis: position.inMilliseconds,
        durationMillis: duration.inMilliseconds,
        updatedAtMillis: now,
      ),
    );
  }
}

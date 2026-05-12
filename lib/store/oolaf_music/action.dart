import 'package:oolaf_flutted/model/oolaf_music/index.dart';
import 'package:oolaf_flutted/store/action.dart';
import 'package:oolaf_flutted/store/oolaf_music/state.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';

class OolafSetLoadingAction extends AppAction {
  const OolafSetLoadingAction(this.isLoading);

  final bool isLoading;
}

class OolafSetMusicIndexAction extends AppAction {
  const OolafSetMusicIndexAction(this.index);

  final OolafMusicIndex? index;
}

class OolafResetPlaybackAction extends AppAction {
  const OolafResetPlaybackAction();
}

class OolafToggleFolderExpandedAction extends AppAction {
  const OolafToggleFolderExpandedAction(this.key);

  final String key;
}

class OolafSetExpandedKeysAction extends AppAction {
  const OolafSetExpandedKeysAction(this.keys);

  final Set<String> keys;
}

class OolafPlayTrackAction extends AppAction {
  const OolafPlayTrackAction({
    required this.title,
    required this.cdnUrl,
    required this.queue,
    required this.queueIndex,
    required this.queueGroupKey,
  });

  final String title;
  final String cdnUrl;
  final List<OolafTrack> queue;
  final int queueIndex;
  final String queueGroupKey;
}

class OolafSetNowPlayingAction extends AppAction {
  const OolafSetNowPlayingAction({
    required this.title,
    required this.cdnUrl,
    required this.queue,
    required this.queueIndex,
    required this.queueGroupKey,
  });

  final String title;
  final String cdnUrl;
  final List<OolafTrack> queue;
  final int queueIndex;
  final String queueGroupKey;
}

class OolafSetTrackLoadingAction extends AppAction {
  const OolafSetTrackLoadingAction({
    required this.cdnUrl,
    required this.isLoading,
  });

  final String cdnUrl;
  final bool isLoading;
}

class OolafClearTrackLoadingAction extends AppAction {
  const OolafClearTrackLoadingAction();
}

class OolafSetQueueAction extends AppAction {
  const OolafSetQueueAction({
    required this.queue,
    required this.queueIndex,
    required this.queueGroupKey,
  });

  final List<OolafTrack> queue;
  final int queueIndex;
  final String queueGroupKey;
}

class OolafPlayByQueueIndexAction extends AppAction {
  const OolafPlayByQueueIndexAction(this.queueIndex);

  final int queueIndex;
}

class OolafSetPlayingAction extends AppAction {
  const OolafSetPlayingAction(this.isPlaying);

  final bool isPlaying;
}

class OolafSetPlaybackStateAction extends AppAction {
  const OolafSetPlaybackStateAction(this.playbackState);

  final OolafPlaybackState playbackState;
}

class OolafSetLoopModeAction extends AppAction {
  const OolafSetLoopModeAction(this.loopMode);

  final OolafLoopMode loopMode;
}

class OolafRestorePlaybackAction extends AppAction {
  const OolafRestorePlaybackAction({
    required this.queue,
    required this.queueIndex,
    required this.queueGroupKey,
    required this.loopMode,
    required this.nowPlaying,
  });

  final List<OolafTrack> queue;
  final int queueIndex;
  final String queueGroupKey;
  final OolafLoopMode loopMode;
  final OolafNowPlaying? nowPlaying;
}

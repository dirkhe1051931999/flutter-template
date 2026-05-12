import 'package:oolaf_flutted/store/action.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/oolaf_music/action.dart';
import 'package:oolaf_flutted/store/oolaf_music/state.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';

AppState oolafMusicReducer(AppState state, AppAction action) {
  final current = state.oolafMusic;

  if (action is OolafSetLoadingAction) {
    return state.copyWith(
      oolafMusic: current.copyWith(isLoading: action.isLoading),
    );
  }

  if (action is OolafSetMusicIndexAction) {
    return state.copyWith(
      oolafMusic: current.copyWith(index: action.index),
    );
  }

  if (action is OolafResetPlaybackAction) {
    return state.copyWith(
      oolafMusic: OolafMusicState(
        isLoading: current.isLoading,
        index: current.index,
        expandedKeys: current.expandedKeys,
        nowPlaying: null,
        isPlaying: false,
        playbackState: OolafPlaybackState.idle,
        loopMode: current.loopMode,
        queue: const <OolafTrack>[],
        queueIndex: -1,
        queueGroupKey: '',
        loadingUrls: const <String>{},
      ),
    );
  }

  if (action is OolafToggleFolderExpandedAction) {
    final next = Set<String>.from(current.expandedKeys);
    if (next.contains(action.key)) {
      next.remove(action.key);
    } else {
      next.add(action.key);
    }
    return state.copyWith(
      oolafMusic: current.copyWith(expandedKeys: next),
    );
  }

  if (action is OolafSetExpandedKeysAction) {
    return state.copyWith(
      oolafMusic: current.copyWith(expandedKeys: Set<String>.from(action.keys)),
    );
  }

  if (action is OolafPlayTrackAction) {
    return state.copyWith(
      oolafMusic: current.copyWith(
        nowPlaying: OolafNowPlaying(title: action.title, cdnUrl: action.cdnUrl),
        isPlaying: true,
        queue: action.queue,
        queueIndex: action.queueIndex,
        queueGroupKey: action.queueGroupKey,
      ),
    );
  }

  if (action is OolafSetNowPlayingAction) {
    return state.copyWith(
      oolafMusic: current.copyWith(
        nowPlaying: OolafNowPlaying(title: action.title, cdnUrl: action.cdnUrl),
        isPlaying: false,
        queue: action.queue,
        queueIndex: action.queueIndex,
        queueGroupKey: action.queueGroupKey,
      ),
    );
  }

  if (action is OolafSetTrackLoadingAction) {
    final next = Set<String>.from(current.loadingUrls);
    if (action.isLoading) {
      next.add(action.cdnUrl);
    } else {
      next.remove(action.cdnUrl);
    }
    return state.copyWith(
      oolafMusic: current.copyWith(loadingUrls: next),
    );
  }

  if (action is OolafClearTrackLoadingAction) {
    return state.copyWith(
      oolafMusic: current.copyWith(loadingUrls: const <String>{}),
    );
  }

  if (action is OolafSetQueueAction) {
    return state.copyWith(
      oolafMusic: current.copyWith(
        queue: action.queue,
        queueIndex: action.queueIndex,
        queueGroupKey: action.queueGroupKey,
      ),
    );
  }

  if (action is OolafPlayByQueueIndexAction) {
    final index = action.queueIndex;
    if (index < 0 || index >= current.queue.length) {
      return state;
    }

    final track = current.queue[index];
    return state.copyWith(
      oolafMusic: current.copyWith(
        nowPlaying: OolafNowPlaying(title: track.title, cdnUrl: track.cdnUrl),
        queueIndex: index,
        isPlaying: true,
      ),
    );
  }

  if (action is OolafSetPlayingAction) {
    return state.copyWith(
      oolafMusic: current.copyWith(isPlaying: action.isPlaying),
    );
  }

  if (action is OolafSetPlaybackStateAction) {
    return state.copyWith(
      oolafMusic: current.copyWith(playbackState: action.playbackState),
    );
  }

  if (action is OolafSetLoopModeAction) {
    return state.copyWith(
      oolafMusic: current.copyWith(loopMode: action.loopMode),
    );
  }

  if (action is OolafRestorePlaybackAction) {
    return state.copyWith(
      oolafMusic: OolafMusicState(
        isLoading: current.isLoading,
        index: current.index,
        expandedKeys: current.expandedKeys,
        nowPlaying: action.nowPlaying,
        isPlaying: false,
        playbackState: OolafPlaybackState.idle,
        loopMode: action.loopMode,
        queue: action.queue,
        queueIndex: action.queueIndex,
        queueGroupKey: action.queueGroupKey,
        loadingUrls: const <String>{},
      ),
    );
  }

  return state;
}

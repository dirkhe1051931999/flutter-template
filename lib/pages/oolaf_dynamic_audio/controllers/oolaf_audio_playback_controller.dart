import 'dart:async';

import 'package:redux/redux.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/oolaf_music/action.dart';
import 'package:oolaf_flutted/store/oolaf_music/state.dart';
import 'package:oolaf_flutted/utils/helper.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';
import 'package:oolaf_flutted/utils/oolaf_playback_persistence.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class OolafAudioPlaybackController {
  int _playByStateToken = 0;
  Timer? _persistDebounce;
  String? _lastPersistKey;
  Store<AppState>? _boundStore;
  StreamSubscription<void>? _completedSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<OolafPlaybackState>? _playbackSub;
  StreamSubscription<AppState>? _storeSub;
  static const Duration _minRestorePosition = Duration(milliseconds: 500);

  void bindStore(Store<AppState> store) {
    if (identical(_boundStore, store)) {
      return;
    }
    _unbindStore();
    _boundStore = store;
    _completedSub = oolafAudioPlayer.completedStream.listen((_) {
      playNextByState(store);
    });
    _playingSub = oolafAudioPlayer.playingStream.listen((isPlaying) {
      store.dispatch(OolafSetPlayingAction(isPlaying));
    });
    _playbackSub = oolafAudioPlayer.playbackStateStream.listen((state) {
      store.dispatch(OolafSetPlaybackStateAction(state));
    });
    _storeSub = store.onChange.listen(handlePlaybackPersistence);
    handlePlaybackPersistence(store.state);
  }

  Future<void> restorePlayback(Store<AppState> store) async {
    final restoreIntentVersion = oolafAudioPlayer.playbackIntentVersion;
    final snapshot = await OolafPlaybackPersistence.load();
    if (restoreIntentVersion != oolafAudioPlayer.playbackIntentVersion) {
      return;
    }
    if (snapshot == null || snapshot.nowPlaying == null) {
      return;
    }
    store.dispatch(
      OolafRestorePlaybackAction(
        queue: snapshot.queue,
        queueIndex: snapshot.queueIndex,
        queueGroupKey: snapshot.queueGroupKey,
        loopMode: snapshot.loopMode,
        nowPlaying: snapshot.nowPlaying,
      ),
    );
    try {
      if (restoreIntentVersion != oolafAudioPlayer.playbackIntentVersion) {
        return;
      }
      final targetUrl = snapshot.nowPlaying!.cdnUrl;
      final isSameTrackAlive =
          oolafAudioPlayer.currentUrl == targetUrl &&
          oolafAudioPlayer.playbackState != OolafPlaybackState.disposed &&
          oolafAudioPlayer.playbackState != OolafPlaybackState.idle;

      if (!isSameTrackAlive) {
        await oolafAudioPlayer.setUrl(targetUrl);
        if (restoreIntentVersion != oolafAudioPlayer.playbackIntentVersion) {
          return;
        }
        final restorePosition = Duration(
          milliseconds: snapshot.positionMillis,
        );
        if (restorePosition >= _minRestorePosition) {
          await oolafAudioPlayer.seek(restorePosition);
          if (restoreIntentVersion != oolafAudioPlayer.playbackIntentVersion) {
            return;
          }
        }
        if (snapshot.wasPlaying) {
          await oolafAudioPlayer.play();
          if (restoreIntentVersion != oolafAudioPlayer.playbackIntentVersion) {
            return;
          }
        }
      }

      store.dispatch(OolafSetPlayingAction(oolafAudioPlayer.isPlaying));
      store.dispatch(
        OolafSetPlaybackStateAction(oolafAudioPlayer.playbackState),
      );
    } catch (error, stackTrace) {
      customLogger.log('restore playback setUrl failed: $error');
      customLogger.log(stackTrace);
    }
  }

  void handlePlaybackPersistence(AppState appState) {
    final music = appState.oolafMusic;
    final key =
        '${music.queueGroupKey}|${music.queueIndex}|${music.loopMode.name}|${music.nowPlaying?.cdnUrl ?? ''}|${music.queue.length}|${music.isPlaying}|${oolafAudioPlayer.position.inMilliseconds ~/ 500}';
    if (key == _lastPersistKey) {
      return;
    }
    _lastPersistKey = key;
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 250), () {
      if (music.nowPlaying == null && music.queue.isEmpty) {
        OolafPlaybackPersistence.clear();
        return;
      }
      OolafPlaybackPersistence.save(
        queue: music.queue,
        queueIndex: music.queueIndex,
        queueGroupKey: music.queueGroupKey,
        loopMode: music.loopMode,
        nowPlaying: music.nowPlaying,
        positionMillis: oolafAudioPlayer.position.inMilliseconds,
        wasPlaying: music.isPlaying,
      );
    });
  }

  Future<void> playPrevByState(Store<AppState> store) async {
    final token = ++_playByStateToken;
    try {
      oolafAudioPlayer.markPlaybackIntent();
      final music = store.state.oolafMusic;
      final queue = music.queue;
      final currentIndex = music.queueIndex;

      if (queue.isEmpty || currentIndex < 0 || currentIndex >= queue.length) {
        store.dispatch(const OolafSetPlayingAction(false));
        return;
      }

      if (music.loopMode == OolafLoopMode.one) {
        final track = queue[currentIndex];
        await oolafAudioPlayer.playUrl(track.cdnUrl);
        if (token != _playByStateToken) {
          return;
        }
        store.dispatch(OolafPlayByQueueIndexAction(currentIndex));
        store.dispatch(const OolafSetPlayingAction(true));
        store.dispatch(
          const OolafSetPlaybackStateAction(OolafPlaybackState.playing),
        );
        return;
      }

      final prevIndex = currentIndex - 1;
      if (prevIndex < 0) {
        if (music.loopMode == OolafLoopMode.all) {
          final lastIndex = queue.length - 1;
          final track = queue[lastIndex];
          await oolafAudioPlayer.playUrl(track.cdnUrl);
          if (token != _playByStateToken) {
            return;
          }
          store.dispatch(OolafPlayByQueueIndexAction(lastIndex));
          store.dispatch(const OolafSetPlayingAction(true));
          store.dispatch(
            const OolafSetPlaybackStateAction(OolafPlaybackState.playing),
          );
          return;
        }

        store.dispatch(const OolafSetPlayingAction(false));
        return;
      }

      final track = queue[prevIndex];
      await oolafAudioPlayer.playUrl(track.cdnUrl);
      if (token != _playByStateToken) {
        return;
      }
      store.dispatch(OolafPlayByQueueIndexAction(prevIndex));
      store.dispatch(const OolafSetPlayingAction(true));
      store.dispatch(
        const OolafSetPlaybackStateAction(OolafPlaybackState.playing),
      );
    } catch (error, stackTrace) {
      if (token != _playByStateToken) {
        return;
      }
      customLogger.log('play prev oolaf music failed: $error');
      customLogger.log(stackTrace);
      store.dispatch(const OolafSetPlayingAction(false));
      AppToast.showText('播放上一首失败');
    }
  }

  Future<void> playNextByState(Store<AppState> store) async {
    final token = ++_playByStateToken;
    try {
      oolafAudioPlayer.markPlaybackIntent();
      final music = store.state.oolafMusic;
      final queue = music.queue;
      final currentIndex = music.queueIndex;

      if (queue.isEmpty || currentIndex < 0 || currentIndex >= queue.length) {
        store.dispatch(const OolafSetPlayingAction(false));
        return;
      }

      if (music.loopMode == OolafLoopMode.one) {
        final track = queue[currentIndex];
        await oolafAudioPlayer.playUrl(track.cdnUrl);
        if (token != _playByStateToken) {
          return;
        }
        store.dispatch(OolafPlayByQueueIndexAction(currentIndex));
        store.dispatch(const OolafSetPlayingAction(true));
        store.dispatch(
          const OolafSetPlaybackStateAction(OolafPlaybackState.playing),
        );
        return;
      }

      final nextIndex = currentIndex + 1;
      if (nextIndex >= queue.length) {
        if (music.loopMode == OolafLoopMode.all) {
          final track = queue[0];
          await oolafAudioPlayer.playUrl(track.cdnUrl);
          if (token != _playByStateToken) {
            return;
          }
          store.dispatch(const OolafPlayByQueueIndexAction(0));
          store.dispatch(const OolafSetPlayingAction(true));
          store.dispatch(
            const OolafSetPlaybackStateAction(OolafPlaybackState.playing),
          );
          return;
        }

        await oolafAudioPlayer.stop();
        if (token != _playByStateToken) {
          return;
        }
        store.dispatch(const OolafResetPlaybackAction());
        store.dispatch(
          const OolafSetPlaybackStateAction(OolafPlaybackState.idle),
        );
        return;
      }

      final track = queue[nextIndex];
      await oolafAudioPlayer.playUrl(track.cdnUrl);
      if (token != _playByStateToken) {
        return;
      }
      store.dispatch(OolafPlayByQueueIndexAction(nextIndex));
      store.dispatch(const OolafSetPlayingAction(true));
      store.dispatch(
        const OolafSetPlaybackStateAction(OolafPlaybackState.playing),
      );
    } catch (error, stackTrace) {
      if (token != _playByStateToken) {
        return;
      }
      customLogger.log('auto play next oolaf music failed: $error');
      customLogger.log(stackTrace);
      store.dispatch(const OolafSetPlayingAction(false));
      AppToast.showText('播放下一首失败');
    }
  }

  void dispose() {
    _persistDebounce?.cancel();
    _unbindStore();
  }

  void _unbindStore() {
    _completedSub?.cancel();
    _playingSub?.cancel();
    _playbackSub?.cancel();
    _storeSub?.cancel();
    _completedSub = null;
    _playingSub = null;
    _playbackSub = null;
    _storeSub = null;
    _boundStore = null;
  }
}

final oolafAudioPlaybackController = OolafAudioPlaybackController();

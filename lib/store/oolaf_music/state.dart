import 'package:oolaf_flutted/model/oolaf_music/index.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';

enum OolafLoopMode {
  off,
  one,
  all,
}

class OolafNowPlaying {
  const OolafNowPlaying({
    required this.title,
    required this.cdnUrl,
  });

  final String title;
  final String cdnUrl;
}

class OolafTrack {
  const OolafTrack({
    required this.title,
    required this.cdnUrl,
  });

  final String title;
  final String cdnUrl;
}

class OolafMusicState {
  const OolafMusicState({
    required this.isLoading,
    required this.index,
    required this.expandedKeys,
    required this.nowPlaying,
    required this.isPlaying,
    required this.playbackState,
    required this.loopMode,
    required this.queue,
    required this.queueIndex,
    required this.queueGroupKey,
    required this.loadingUrls,
  });

  final bool isLoading;
  final OolafMusicIndex? index;
  final Set<String> expandedKeys;
  final OolafNowPlaying? nowPlaying;
  final bool isPlaying;
  final OolafPlaybackState playbackState;
  final OolafLoopMode loopMode;
  final List<OolafTrack> queue;
  final int queueIndex;
  final String queueGroupKey;
  final Set<String> loadingUrls;

  factory OolafMusicState.initial() {
    return const OolafMusicState(
      isLoading: false,
      index: null,
      expandedKeys: <String>{},
      nowPlaying: null,
      isPlaying: false,
      playbackState: OolafPlaybackState.idle,
      loopMode: OolafLoopMode.all,
      queue: <OolafTrack>[],
      queueIndex: -1,
      queueGroupKey: '',
      loadingUrls: <String>{},
    );
  }

  OolafMusicState copyWith({
    bool? isLoading,
    OolafMusicIndex? index,
    Set<String>? expandedKeys,
    OolafNowPlaying? nowPlaying,
    bool? isPlaying,
    OolafPlaybackState? playbackState,
    OolafLoopMode? loopMode,
    List<OolafTrack>? queue,
    int? queueIndex,
    String? queueGroupKey,
    Set<String>? loadingUrls,
  }) {
    return OolafMusicState(
      isLoading: isLoading ?? this.isLoading,
      index: index ?? this.index,
      expandedKeys: expandedKeys ?? this.expandedKeys,
      nowPlaying: nowPlaying ?? this.nowPlaying,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackState: playbackState ?? this.playbackState,
      loopMode: loopMode ?? this.loopMode,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
      queueGroupKey: queueGroupKey ?? this.queueGroupKey,
      loadingUrls: loadingUrls ?? this.loadingUrls,
    );
  }
}

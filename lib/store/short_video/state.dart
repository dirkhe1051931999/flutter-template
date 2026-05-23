class ShortVideoItem {
  const ShortVideoItem({
    required this.id,
    this.source,
    this.avatarUrl,
    required this.title,
    this.updateTime,
    required this.videoUrl,
    required this.coverUrl,
  });

  final String id;
  final String? source;
  final String? avatarUrl;
  final String title;
  final String? updateTime;
  final String videoUrl;
  final String coverUrl;
}

class ShortVideoState {
  const ShortVideoState({
    required this.isLoading,
    required this.items,
    required this.activeIndex,
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

  final bool isLoading;
  final List<ShortVideoItem> items;
  final int activeIndex;
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

  factory ShortVideoState.initial() {
    return const ShortVideoState(
      isLoading: false,
      items: <ShortVideoItem>[],
      activeIndex: 0,
      recordWatchHistory: true,
      autoPlayOnEnter: true,
      rememberPlaybackProgress: true,
      autoPlayNextVideo: true,
      playbackRate: 1.0,
      preloadPagesCount: 2,
      keepWindow: 1,
      videoFitMode: 'cover',
      danmakuEnabled: true,
      danmakuOpacity: 0.82,
      danmakuFontScale: 1.0,
      danmakuFontWeight: 600,
      danmakuSpeed: 1.0,
      danmakuArea: 0.7,
    );
  }

  ShortVideoState copyWith({
    bool? isLoading,
    List<ShortVideoItem>? items,
    int? activeIndex,
    bool? recordWatchHistory,
    bool? autoPlayOnEnter,
    bool? rememberPlaybackProgress,
    bool? autoPlayNextVideo,
    double? playbackRate,
    int? preloadPagesCount,
    int? keepWindow,
    String? videoFitMode,
    bool? danmakuEnabled,
    double? danmakuOpacity,
    double? danmakuFontScale,
    int? danmakuFontWeight,
    double? danmakuSpeed,
    double? danmakuArea,
  }) {
    return ShortVideoState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      activeIndex: activeIndex ?? this.activeIndex,
      recordWatchHistory: recordWatchHistory ?? this.recordWatchHistory,
      autoPlayOnEnter: autoPlayOnEnter ?? this.autoPlayOnEnter,
      rememberPlaybackProgress:
          rememberPlaybackProgress ?? this.rememberPlaybackProgress,
      autoPlayNextVideo: autoPlayNextVideo ?? this.autoPlayNextVideo,
      playbackRate: playbackRate ?? this.playbackRate,
      preloadPagesCount: preloadPagesCount ?? this.preloadPagesCount,
      keepWindow: keepWindow ?? this.keepWindow,
      videoFitMode: videoFitMode ?? this.videoFitMode,
      danmakuEnabled: danmakuEnabled ?? this.danmakuEnabled,
      danmakuOpacity: danmakuOpacity ?? this.danmakuOpacity,
      danmakuFontScale: danmakuFontScale ?? this.danmakuFontScale,
      danmakuFontWeight: danmakuFontWeight ?? this.danmakuFontWeight,
      danmakuSpeed: danmakuSpeed ?? this.danmakuSpeed,
      danmakuArea: danmakuArea ?? this.danmakuArea,
    );
  }
}

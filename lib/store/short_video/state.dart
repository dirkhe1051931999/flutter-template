class ShortVideoItem {
  const ShortVideoItem({
    required this.id,
    this.source,
    required this.title,
    this.updateTime,
    required this.videoUrl,
    required this.coverUrl,
  });

  final String id;
  final String? source;
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
    required this.autoPlayNextVideo,
    required this.playbackRate,
    required this.preloadPagesCount,
    required this.keepWindow,
    required this.videoFitMode,
  });

  final bool isLoading;
  final List<ShortVideoItem> items;
  final int activeIndex;
  final bool recordWatchHistory;
  final bool autoPlayNextVideo;
  final double playbackRate;
  final int preloadPagesCount;
  final int keepWindow;
  final String videoFitMode;

  factory ShortVideoState.initial() {
    return const ShortVideoState(
      isLoading: false,
      items: <ShortVideoItem>[],
      activeIndex: 0,
      recordWatchHistory: true,
      autoPlayNextVideo: true,
      playbackRate: 1.0,
      preloadPagesCount: 2,
      keepWindow: 1,
      videoFitMode: 'cover',
    );
  }

  ShortVideoState copyWith({
    bool? isLoading,
    List<ShortVideoItem>? items,
    int? activeIndex,
    bool? recordWatchHistory,
    bool? autoPlayNextVideo,
    double? playbackRate,
    int? preloadPagesCount,
    int? keepWindow,
    String? videoFitMode,
  }) {
    return ShortVideoState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      activeIndex: activeIndex ?? this.activeIndex,
      recordWatchHistory: recordWatchHistory ?? this.recordWatchHistory,
      autoPlayNextVideo: autoPlayNextVideo ?? this.autoPlayNextVideo,
      playbackRate: playbackRate ?? this.playbackRate,
      preloadPagesCount: preloadPagesCount ?? this.preloadPagesCount,
      keepWindow: keepWindow ?? this.keepWindow,
      videoFitMode: videoFitMode ?? this.videoFitMode,
    );
  }
}

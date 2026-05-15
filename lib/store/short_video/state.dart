class ShortVideoItem {
  const ShortVideoItem({
    required this.id,
    this.source,
    required this.title,
    required this.videoUrl,
    required this.coverUrl,
  });

  final String id;
  final String? source;
  final String title;
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
  });

  final bool isLoading;
  final List<ShortVideoItem> items;
  final int activeIndex;
  final bool recordWatchHistory;
  final bool autoPlayNextVideo;

  factory ShortVideoState.initial() {
    return const ShortVideoState(
      isLoading: false,
      items: <ShortVideoItem>[],
      activeIndex: 0,
      recordWatchHistory: true,
      autoPlayNextVideo: true,
    );
  }

  ShortVideoState copyWith({
    bool? isLoading,
    List<ShortVideoItem>? items,
    int? activeIndex,
    bool? recordWatchHistory,
    bool? autoPlayNextVideo,
  }) {
    return ShortVideoState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      activeIndex: activeIndex ?? this.activeIndex,
      recordWatchHistory: recordWatchHistory ?? this.recordWatchHistory,
      autoPlayNextVideo: autoPlayNextVideo ?? this.autoPlayNextVideo,
    );
  }
}

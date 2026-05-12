class ShortVideoItem {
  const ShortVideoItem({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.coverUrl,
  });

  final String id;
  final String title;
  final String videoUrl;
  final String coverUrl;
}

class ShortVideoState {
  const ShortVideoState({
    required this.isLoading,
    required this.items,
    required this.activeIndex,
  });

  final bool isLoading;
  final List<ShortVideoItem> items;
  final int activeIndex;

  factory ShortVideoState.initial() {
    return const ShortVideoState(
      isLoading: false,
      items: <ShortVideoItem>[],
      activeIndex: 0,
    );
  }

  ShortVideoState copyWith({
    bool? isLoading,
    List<ShortVideoItem>? items,
    int? activeIndex,
  }) {
    return ShortVideoState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}

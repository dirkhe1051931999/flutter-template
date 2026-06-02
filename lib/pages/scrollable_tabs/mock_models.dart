class ScrollableTabsMockData {
  const ScrollableTabsMockData({
    required this.tabs,
  });

  final List<ScrollableTabsMockTab> tabs;

  factory ScrollableTabsMockData.fromJson(Map<String, dynamic> json) {
    final tabsJson = json['tabs'];
    return ScrollableTabsMockData(
      tabs: tabsJson is List
          ? tabsJson
              .whereType<Map<String, dynamic>>()
              .map(ScrollableTabsMockTab.fromJson)
              .toList(growable: false)
          : const <ScrollableTabsMockTab>[],
    );
  }
}

class ScrollableTabsMockTab {
  const ScrollableTabsMockTab({
    required this.id,
    required this.label,
    required this.description,
    required this.accentColor,
    required this.keepAlive,
    required this.swipeEnabled,
    required this.cards,
  });

  final String id;
  final String label;
  final String description;
  final String accentColor;
  final bool keepAlive;
  final bool swipeEnabled;
  final List<ScrollableTabsMockCard> cards;

  factory ScrollableTabsMockTab.fromJson(Map<String, dynamic> json) {
    final cardsJson = json['cards'];
    return ScrollableTabsMockTab(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      accentColor: json['accentColor']?.toString() ?? '#E5484D',
      keepAlive: json['keepAlive'] == true,
      swipeEnabled: json['swipeEnabled'] != false,
      cards: cardsJson is List
          ? cardsJson
              .whereType<Map<String, dynamic>>()
              .map(ScrollableTabsMockCard.fromJson)
              .toList(growable: false)
          : const <ScrollableTabsMockCard>[],
    );
  }

  ScrollableTabsMockTab copyWith({
    List<ScrollableTabsMockCard>? cards,
  }) {
    return ScrollableTabsMockTab(
      id: id,
      label: label,
      description: description,
      accentColor: accentColor,
      keepAlive: keepAlive,
      swipeEnabled: swipeEnabled,
      cards: cards ?? this.cards,
    );
  }
}

class ScrollableTabsMockCard {
  const ScrollableTabsMockCard({
    required this.id,
    required this.title,
    required this.summary,
    required this.tag,
    required this.meta,
    required this.icon,
  });

  final String id;
  final String title;
  final String summary;
  final String tag;
  final String meta;
  final String icon;

  factory ScrollableTabsMockCard.fromJson(Map<String, dynamic> json) {
    return ScrollableTabsMockCard(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      tag: json['tag']?.toString() ?? '',
      meta: json['meta']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'square.grid.2x2',
    );
  }
}

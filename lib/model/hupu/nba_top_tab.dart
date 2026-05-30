class HupuNbaTopTabData {
  const HupuNbaTopTabData({
    required this.shortcuts,
    required this.recommendedMatch,
    required this.hotNews,
    required this.news,
    required this.topNewsCount,
  });

  final List<HupuNbaShortcut> shortcuts;
  final HupuNbaRecommendedMatch? recommendedMatch;
  final List<HupuNbaNewsItem> hotNews;
  final List<HupuNbaNewsItem> news;
  final int topNewsCount;

  String get nextNewsId {
    if (news.isEmpty) {
      return '';
    }
    return news.last.nid;
  }
}

class HupuNbaNewsPage {
  const HupuNbaNewsPage({
    required this.items,
    required this.topNewsCount,
  });

  final List<HupuNbaNewsItem> items;
  final int topNewsCount;

  String get nextNewsId {
    if (items.isEmpty) {
      return '';
    }
    return items.last.nid;
  }

  factory HupuNbaNewsPage.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    return HupuNbaNewsPage(
      items: _parseNewsItems(result['data']),
      topNewsCount: _intValue(result['topNewsCount']),
    );
  }
}

class HupuNbaHotNewsData {
  const HupuNbaHotNewsData({required this.items});

  final List<HupuNbaNewsItem> items;

  factory HupuNbaHotNewsData.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    return HupuNbaHotNewsData(items: _parseNewsItems(result['data']));
  }
}

class HupuNbaShortcut {
  const HupuNbaShortcut({
    required this.schema,
    required this.icon,
    required this.name,
    required this.dayColor,
    required this.nightColor,
  });

  final String schema;
  final String icon;
  final String name;
  final String dayColor;
  final String nightColor;

  factory HupuNbaShortcut.fromJson(Map<String, dynamic> json) {
    final color = _asMap(json['color']);
    return HupuNbaShortcut(
      schema: _stringValue(json['schema']),
      icon: _stringValue(json['icon']),
      name: _stringValue(json['name']),
      dayColor: _stringValue(color['day']),
      nightColor: _stringValue(color['night']),
    );
  }
}

class HupuNbaRecommendedMatch {
  const HupuNbaRecommendedMatch({
    required this.matchId,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.homeBigScore,
    required this.awayBigScore,
    required this.statusText,
    required this.iconText,
    required this.dateText,
    required this.matchTitle,
    required this.matchCountText,
    required this.matchListLink,
  });

  final String matchId;
  final String homeTeamName;
  final String awayTeamName;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final int homeBigScore;
  final int awayBigScore;
  final String statusText;
  final String iconText;
  final String dateText;
  final String matchTitle;
  final String matchCountText;
  final String matchListLink;

  factory HupuNbaRecommendedMatch.fromJson(Map<String, dynamic> json) {
    final matchList = json['matchList'];
    final firstMatch = matchList is List && matchList.isNotEmpty
        ? _asMap(matchList.first)
        : const <String, dynamic>{};
    final toast = _asMap(json['toast']);
    final status = _asMap(firstMatch['frontEndMatchStatus']);

    return HupuNbaRecommendedMatch(
      matchId: _stringValue(firstMatch['matchId']),
      homeTeamName: _stringValue(firstMatch['homeTeamName']),
      awayTeamName: _stringValue(firstMatch['awayTeamName']),
      homeTeamLogo: _stringValue(firstMatch['homeTeamLogo']),
      awayTeamLogo: _stringValue(firstMatch['awayTeamLogo']),
      homeBigScore: _intValue(firstMatch['homeBigScore']),
      awayBigScore: _intValue(firstMatch['awayBigScore']),
      statusText: _stringValue(status['desc']),
      iconText: _stringValue(firstMatch['iconText']),
      dateText: _stringValue(toast['date']),
      matchTitle: _stringValue(toast['title']),
      matchCountText: _stringValue(toast['matchCountText']),
      matchListLink: _stringValue(toast['matchListLink']),
    );
  }
}

class HupuNbaNewsItem {
  const HupuNbaNewsItem({
    required this.nid,
    required this.tid,
    required this.title,
    required this.imageUrl,
    required this.replies,
    required this.lights,
    required this.link,
    required this.top,
    required this.badges,
  });

  final String nid;
  final String tid;
  final String title;
  final String imageUrl;
  final int replies;
  final int lights;
  final String link;
  final bool top;
  final List<HupuNbaNewsBadge> badges;

  String get replySummary => '$replies回复 / $lights亮回复';

  bool get isPinned {
    return top || badges.any((badge) => badge.name == '置顶');
  }

  factory HupuNbaNewsItem.fromJson(Map<String, dynamic> json) {
    return HupuNbaNewsItem(
      nid: _stringValue(json['nid']),
      tid: _stringValue(json['tid']),
      title: _stringValue(json['title']),
      imageUrl: _stringValue(json['img']),
      replies: _intValue(json['replies']),
      lights: _intValue(json['lights']),
      link: _stringValue(json['link']),
      top: json['top'] == true,
      badges: _parseBadges(json['badge']),
    );
  }
}

class HupuNbaNewsBadge {
  const HupuNbaNewsBadge({
    required this.name,
    required this.color,
    required this.colorBg,
  });

  final String name;
  final String color;
  final String colorBg;

  factory HupuNbaNewsBadge.fromJson(Map<String, dynamic> json) {
    return HupuNbaNewsBadge(
      name: _stringValue(json['name']),
      color: _stringValue(json['v2DayColor'] ?? json['color']),
      colorBg: _stringValue(json['v2DayColorBg'] ?? json['colorBg']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

String _stringValue(dynamic value) => value?.toString() ?? '';

int _intValue(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

List<HupuNbaNewsItem> _parseNewsItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuNbaNewsItem>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => HupuNbaNewsItem.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.nid.isNotEmpty)
      .toList(growable: false);
}

List<HupuNbaNewsBadge> _parseBadges(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuNbaNewsBadge>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => HupuNbaNewsBadge.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

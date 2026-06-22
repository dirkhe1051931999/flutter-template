class HupuSportsNewsPage {
  const HupuSportsNewsPage({
    required this.items,
    required this.topNewsCount,
  });

  final List<HupuSportsNewsItem> items;
  final int topNewsCount;

  factory HupuSportsNewsPage.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    return HupuSportsNewsPage(
      items: _parseNewsItems(result['data']),
      topNewsCount: _intValue(result['topNewsCount']),
    );
  }
}

class HupuSportsHotNewsData {
  const HupuSportsHotNewsData({required this.items});

  final List<HupuSportsNewsItem> items;

  factory HupuSportsHotNewsData.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    return HupuSportsHotNewsData(items: _parseNewsItems(result['data']));
  }
}

class HupuCompetitionTopic {
  const HupuCompetitionTopic({
    required this.id,
    required this.topicId,
    required this.name,
    required this.code,
  });

  final int id;
  final int topicId;
  final String name;
  final String code;

  factory HupuCompetitionTopic.fromJson(Map<String, dynamic> json) {
    return HupuCompetitionTopic(
      id: _intValue(json['id']),
      topicId: _intValue(json['topicId']),
      name: _stringValue(json['name']),
      code: _stringValue(json['code']),
    );
  }
}

class HupuSportsNewsItem {
  const HupuSportsNewsItem({
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
  final List<HupuSportsNewsBadge> badges;

  String get replySummary => '$replies回复 / $lights亮回复';

  bool get isPinned {
    return top || badges.any((badge) => badge.name == '置顶');
  }

  factory HupuSportsNewsItem.fromJson(Map<String, dynamic> json) {
    return HupuSportsNewsItem(
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

class HupuSportsNewsBadge {
  const HupuSportsNewsBadge({
    required this.name,
    required this.color,
    required this.colorBg,
  });

  final String name;
  final String color;
  final String colorBg;

  factory HupuSportsNewsBadge.fromJson(Map<String, dynamic> json) {
    return HupuSportsNewsBadge(
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

List<HupuSportsNewsItem> _parseNewsItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuSportsNewsItem>[];
  }
  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuSportsNewsItem.fromJson(Map<String, dynamic>.from(item)),
      )
      .where((item) => item.nid.isNotEmpty)
      .toList(growable: false);
}

List<HupuSportsNewsBadge> _parseBadges(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuSportsNewsBadge>[];
  }
  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuSportsNewsBadge.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuCompetitionTopic> parseHupuCompetitionTopics(
  Map<String, dynamic> json,
) {
  final data = json['data'];
  if (data is! List) {
    return const <HupuCompetitionTopic>[];
  }
  return data
      .whereType<Map>()
      .map(
        (item) => HupuCompetitionTopic.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .where((item) => item.topicId > 0 && item.name.isNotEmpty)
      .toList(growable: false);
}

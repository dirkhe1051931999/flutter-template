class HupuCbaNewsPage {
  const HupuCbaNewsPage({
    required this.items,
    required this.topNewsCount,
  });

  final List<HupuCbaNewsItem> items;
  final int topNewsCount;

  factory HupuCbaNewsPage.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    return HupuCbaNewsPage(
      items: _parseNewsItems(result['data']),
      topNewsCount: _intValue(result['topNewsCount']),
    );
  }
}

class HupuCbaHotNewsData {
  const HupuCbaHotNewsData({required this.items});

  final List<HupuCbaNewsItem> items;

  factory HupuCbaHotNewsData.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    return HupuCbaHotNewsData(items: _parseNewsItems(result['data']));
  }
}

class HupuCbaNewsItem {
  const HupuCbaNewsItem({
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
  final List<HupuCbaNewsBadge> badges;

  String get replySummary => '$replies回复 / $lights亮回复';

  bool get isPinned {
    return top || badges.any((badge) => badge.name == '置顶');
  }

  factory HupuCbaNewsItem.fromJson(Map<String, dynamic> json) {
    return HupuCbaNewsItem(
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

class HupuCbaNewsBadge {
  const HupuCbaNewsBadge({
    required this.name,
    required this.color,
    required this.colorBg,
  });

  final String name;
  final String color;
  final String colorBg;

  factory HupuCbaNewsBadge.fromJson(Map<String, dynamic> json) {
    return HupuCbaNewsBadge(
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

List<HupuCbaNewsItem> _parseNewsItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuCbaNewsItem>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => HupuCbaNewsItem.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.nid.isNotEmpty)
      .toList(growable: false);
}

List<HupuCbaNewsBadge> _parseBadges(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuCbaNewsBadge>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => HupuCbaNewsBadge.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

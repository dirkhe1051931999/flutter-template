import 'user_identity.dart';

class HupuTopicAdminResponse {
  const HupuTopicAdminResponse({
    required this.title,
    required this.adminApplicable,
    required this.admins,
  });

  final String title;
  final bool adminApplicable;
  final List<HupuTopicAdmin> admins;

  factory HupuTopicAdminResponse.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    return HupuTopicAdminResponse(
      title: _stringValue(data['title']),
      adminApplicable: _intValue(data['adminApplicable']) == 1,
      admins: _parseTopicAdmins(data['adminList']),
    );
  }
}

class HupuTopicAdmin {
  const HupuTopicAdmin({
    required this.puid,
    required this.userName,
    required this.roleName,
    required this.avatar,
  });

  final String puid;
  final String userName;
  final String roleName;
  final String avatar;

  factory HupuTopicAdmin.fromJson(Map<String, dynamic> json) {
    return HupuTopicAdmin(
      puid: resolveHupuPuid(
        directValues: <dynamic>[json['puid']],
        schemaCandidates: const <String>[],
      ),
      userName: _stringValue(json['userName']),
      roleName: _stringValue(json['roleName']),
      avatar: _normalizeUrl(
        _stringValue(json['headerBig']).isNotEmpty
            ? _stringValue(json['headerBig'])
            : _stringValue(json['header']),
      ),
    );
  }
}

class HupuTopicDetailResponse {
  const HupuTopicDetailResponse({
    required this.topic,
    required this.tabs,
    required this.topThreads,
    required this.zones,
    required this.resources,
    required this.adPageId,
  });

  final HupuTopicDetail topic;
  final List<HupuTopicTab> tabs;
  final List<HupuTopicThreadItem> topThreads;
  final List<HupuTopicZone> zones;
  final List<HupuTopicResource> resources;
  final String adPageId;

  factory HupuTopicDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    return HupuTopicDetailResponse(
      topic: HupuTopicDetail.fromJson(_asMap(data['topic'])),
      tabs: _parseTopicTabs(data['tab']),
      topThreads: _parseTopicThreads(data['topicTopList']),
      zones: _parseTopicZones(data['topicZones']),
      resources: _parseTopicResources(data['topicResources']),
      adPageId: _stringValue(data['ad_page_id']),
    );
  }
}

class HupuTopicDetail {
  const HupuTopicDetail({
    required this.topicId,
    required this.name,
    required this.logo,
    required this.realLogo,
    required this.description,
    required this.fid,
    required this.followedUserCount,
    required this.threadCount,
    required this.backgroundColor,
    required this.nightBackgroundColor,
  });

  final int topicId;
  final String name;
  final String logo;
  final String realLogo;
  final String description;
  final int fid;
  final int followedUserCount;
  final int threadCount;
  final String backgroundColor;
  final String nightBackgroundColor;

  String get displayLogo => realLogo.isNotEmpty ? realLogo : logo;

  factory HupuTopicDetail.fromJson(Map<String, dynamic> json) {
    return HupuTopicDetail(
      topicId: _intValue(json['topic_id']),
      name: _stringValue(json['name']),
      logo: _normalizeUrl(_stringValue(json['logo'])),
      realLogo: _normalizeUrl(_stringValue(json['realLogo'])),
      description: _stringValue(json['desc']),
      fid: _intValue(json['fid']),
      followedUserCount: _intValue(json['followedUserNum']),
      threadCount: _intValue(json['allThreadNum']),
      backgroundColor: _stringValue(json['bgColor']),
      nightBackgroundColor: _stringValue(json['nightBgColor']),
    );
  }
}

class HupuTopicTab {
  const HupuTopicTab({
    required this.name,
    required this.tabType,
    required this.ename,
  });

  final String name;
  final int tabType;
  final String ename;

  factory HupuTopicTab.fromJson(Map<String, dynamic> json) {
    return HupuTopicTab(
      name: _stringValue(json['name']),
      tabType: _intValue(json['tab_type']),
      ename: _stringValue(json['ename']),
    );
  }
}

class HupuTopicZone {
  const HupuTopicZone({
    required this.id,
    required this.topicId,
    required this.zoneName,
    required this.sortOrder,
  });

  final int id;
  final int topicId;
  final String zoneName;
  final int sortOrder;

  factory HupuTopicZone.fromJson(Map<String, dynamic> json) {
    return HupuTopicZone(
      id: _intValue(json['id']),
      topicId: _intValue(json['topicId']),
      zoneName: _stringValue(json['zoneName']),
      sortOrder: _intValue(json['sortOrder']),
    );
  }
}

class HupuTopicResource {
  const HupuTopicResource({
    required this.id,
    required this.backImageUrl,
    required this.jumpUrl,
  });

  final int id;
  final String backImageUrl;
  final String jumpUrl;

  factory HupuTopicResource.fromJson(Map<String, dynamic> json) {
    return HupuTopicResource(
      id: _intValue(json['id']),
      backImageUrl: _normalizeUrl(_stringValue(json['backImgUrl'])),
      jumpUrl: _stringValue(json['jumpUrl']),
    );
  }
}

class HupuTopicThreadPage {
  const HupuTopicThreadPage({
    required this.items,
    required this.hasNextPage,
    required this.cursor,
    required this.stamp,
  });

  final List<HupuTopicThreadItem> items;
  final bool hasNextPage;
  final String cursor;
  final int stamp;

  factory HupuTopicThreadPage.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    return HupuTopicThreadPage(
      items: _parseTopicThreads(data['list']),
      hasNextPage: data['next_page'] == true || data['nextPage'] == true,
      cursor: _stringValue(data['cursor']),
      stamp: _intValue(data['stamp']),
    );
  }
}

class HupuTopicThreadItem {
  const HupuTopicThreadItem({
    required this.tid,
    required this.puid,
    required this.title,
    required this.userName,
    required this.timeText,
    required this.replyCount,
    required this.lightReplyCount,
    required this.recommendCount,
    required this.imageUrl,
    required this.zoneId,
    required this.zoneName,
    required this.threadType,
    required this.badges,
    required this.certTitle,
    required this.certIconUrl,
    required this.isTop,
  });

  final String tid;
  final String puid;
  final String title;
  final String userName;
  final String timeText;
  final int replyCount;
  final int lightReplyCount;
  final int recommendCount;
  final String imageUrl;
  final int zoneId;
  final String zoneName;
  final String threadType;
  final List<HupuTopicThreadBadge> badges;
  final String certTitle;
  final String certIconUrl;
  final bool isTop;

  String get statsText => '$replyCount回复 / $recommendCount推荐';

  HupuTopicThreadBadge? get primaryBadge {
    if (badges.isEmpty) {
      return null;
    }
    return badges.first;
  }

  factory HupuTopicThreadItem.fromJson(Map<String, dynamic> json) {
    return HupuTopicThreadItem(
      tid: _stringValue(json['tid']),
      puid: resolveHupuPuid(
        directValues: <dynamic>[json['puid'], json['uid'], json['user_id']],
        schemaCandidates: <String>[_stringValue(json['schema'])],
      ),
      title: _stringValue(json['title']),
      userName: _stringValue(json['user_name']),
      timeText: _stringValue(json['time']),
      replyCount: _intValue(json['replys']),
      lightReplyCount: _intValue(json['light_replys']),
      recommendCount: _intValue(json['recommends']),
      imageUrl: _resolveThreadImage(json),
      zoneId: _intValue(json['zoneId'] ?? json['zone_id']),
      zoneName: _stringValue(json['zoneName'] ?? json['zone_name']),
      threadType: _stringValue(json['threadType'] ?? json['thread_type']),
      badges: _parseTopicThreadBadges(json['badge']),
      certTitle: _stringValue(json['certTitle'] ?? json['cert_title']),
      certIconUrl: _normalizeUrl(
        _stringValue(json['certIconUrl'] ?? json['cert_icon_url']),
      ),
      isTop: _intValue(json['top']) == 1,
    );
  }
}

class HupuTopicThreadBadge {
  const HupuTopicThreadBadge({
    required this.name,
    required this.colorHex,
  });

  final String name;
  final String colorHex;

  factory HupuTopicThreadBadge.fromJson(Map<String, dynamic> json) {
    return HupuTopicThreadBadge(
      name: _stringValue(json['name']),
      colorHex: _stringValue(json['color']),
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

String _normalizeUrl(String value) {
  final normalized = value.trim();
  if (normalized.startsWith('http://')) {
    return 'https://${normalized.substring(7)}';
  }
  return normalized;
}

String _resolveThreadImage(Map<String, dynamic> json) {
  final cover = _normalizeUrl(_stringValue(json['cover']));
  if (cover.isNotEmpty) {
    return cover;
  }
  final imgs = json['imgs'];
  if (imgs is List && imgs.isNotEmpty) {
    final first = imgs.first;
    if (first is Map) {
      return _normalizeUrl(_stringValue(first['url'] ?? first['img']));
    }
    return _normalizeUrl(_stringValue(first));
  }
  return '';
}

List<HupuTopicAdmin> _parseTopicAdmins(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuTopicAdmin>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => HupuTopicAdmin.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.userName.isNotEmpty)
      .toList(growable: false);
}

List<HupuTopicTab> _parseTopicTabs(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuTopicTab>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => HupuTopicTab.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.name.isNotEmpty)
      .toList(growable: false);
}

List<HupuTopicZone> _parseTopicZones(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuTopicZone>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => HupuTopicZone.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.id > 0 && item.zoneName.isNotEmpty)
      .toList(growable: false);
}

List<HupuTopicResource> _parseTopicResources(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuTopicResource>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => HupuTopicResource.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.backImageUrl.isNotEmpty)
      .toList(growable: false);
}

List<HupuTopicThreadItem> _parseTopicThreads(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuTopicThreadItem>[];
  }
  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuTopicThreadItem.fromJson(Map<String, dynamic>.from(item)),
      )
      .where((item) => item.tid.isNotEmpty)
      .toList(growable: false);
}

List<HupuTopicThreadBadge> _parseTopicThreadBadges(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuTopicThreadBadge>[];
  }
  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuTopicThreadBadge.fromJson(Map<String, dynamic>.from(item)),
      )
      .where((item) => item.name.isNotEmpty)
      .toList(growable: false);
}

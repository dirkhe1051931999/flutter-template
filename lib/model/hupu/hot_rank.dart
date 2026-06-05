import 'user_identity.dart';

class HupuHotTagPage {
  const HupuHotTagPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalPage,
    required this.headTitleImage,
    required this.headTitleImageNight,
  });

  final List<HupuHotTagItem> items;
  final int page;
  final int pageSize;
  final int totalPage;
  final String headTitleImage;
  final String headTitleImageNight;

  factory HupuHotTagPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected Hupu hot tag payload');
    }

    final resource = data['heatTagResource'];
    final resourceMap =
        resource is Map<String, dynamic> ? resource : const <String, dynamic>{};

    return HupuHotTagPage(
      items: _parseHotTagItems(data['content']),
      page: _parseInt(data['page']),
      pageSize: _parseInt(data['pageSize']),
      totalPage: _parseInt(data['totalPage']),
      headTitleImage: resourceMap['headTitleImg']?.toString() ?? '',
      headTitleImageNight: resourceMap['headTitleImgNight']?.toString() ?? '',
    );
  }

}

class HupuHotTagItem {
  const HupuHotTagItem({
    required this.tagId,
    required this.tagName,
    required this.heat,
    required this.rank,
    required this.competitionType,
    required this.useBusiness,
  });

  final int tagId;
  final String tagName;
  final int heat;
  final int rank;
  final String competitionType;
  final int useBusiness;

  factory HupuHotTagItem.fromJson(Map<String, dynamic> json) {
    return HupuHotTagItem(
      tagId: _parseInt(json['tagId']),
      tagName: json['tagName']?.toString() ?? '',
      heat: _parseInt(json['heat']),
      rank: _parseInt(json['rank']),
      competitionType: json['competitionType']?.toString() ?? '',
      useBusiness: _parseInt(json['useBusiness']),
    );
  }

}

class HupuHotRankCategory {
  const HupuHotRankCategory({
    required this.id,
    required this.name,
    required this.sort,
    required this.count,
    required this.intervalTimeSecond,
    required this.adPageId,
  });

  final int id;
  final String name;
  final int sort;
  final int count;
  final int intervalTimeSecond;
  final String adPageId;

  factory HupuHotRankCategory.fromJson(Map<String, dynamic> json) {
    return HupuHotRankCategory(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      sort: _parseInt(json['sort']),
      count: _parseInt(json['count']),
      intervalTimeSecond: _parseInt(json['intervalTimeSecond']),
      adPageId: json['ad_page_id']?.toString() ?? '',
    );
  }

}

class HupuHotRankResponse {
  const HupuHotRankResponse({
    required this.items,
    required this.totalCount,
    required this.adPageId,
  });

  final List<HupuHotRankItem> items;
  final int totalCount;
  final String adPageId;

  factory HupuHotRankResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    if (result is! Map<String, dynamic>) {
      throw StateError('Unexpected Hupu hot rank payload');
    }

    return HupuHotRankResponse(
      items: _parseHotRankItems(result['listV2']),
      totalCount: _parseInt(result['count']),
      adPageId: result['ad_page_id']?.toString() ?? '',
    );
  }

}

class HupuHotRankItem {
  const HupuHotRankItem({
    required this.order,
    required this.createTimeText,
    required this.schemaUrl,
    required this.thread,
  });

  final int order;
  final String createTimeText;
  final String schemaUrl;
  final HupuHotRankThread thread;

  factory HupuHotRankItem.fromJson(Map<String, dynamic> json) {
    final thread = json['thread'];
    if (thread is! Map<String, dynamic>) {
      throw StateError('Unexpected Hupu hot rank thread payload');
    }

    return HupuHotRankItem(
      order: _parseInt(json['order']),
      createTimeText: json['createTime']?.toString() ?? '',
      schemaUrl: json['schemaUrl']?.toString() ?? '',
      thread: HupuHotRankThread.fromJson(thread),
    );
  }

}

class HupuHotRankThread {
  const HupuHotRankThread({
    required this.tid,
    required this.fid,
    required this.topicId,
    required this.puid,
    required this.title,
    required this.summary,
    required this.content,
    required this.nickname,
    required this.header,
    required this.forumName,
    required this.topicName,
    required this.topicLogo,
    required this.createTime,
    required this.replies,
    required this.recommendNum,
    required this.shareNum,
    required this.lights,
    required this.pics,
    required this.lightReplies,
  });

  final String tid;
  final String fid;
  final int topicId;
  final String puid;
  final String title;
  final String summary;
  final String content;
  final String nickname;
  final String header;
  final String forumName;
  final String topicName;
  final String topicLogo;
  final int createTime;
  final int replies;
  final int recommendNum;
  final int shareNum;
  final int lights;
  final List<HupuHotRankImage> pics;
  final List<HupuHotRankLightReply> lightReplies;

  String get primarySectionName {
    if (forumName.trim().isNotEmpty) {
      return forumName.trim();
    }
    return topicName.trim();
  }

  factory HupuHotRankThread.fromJson(Map<String, dynamic> json) {
    return HupuHotRankThread(
      tid: json['tid']?.toString() ?? '',
      fid: json['fid']?.toString() ?? '',
      topicId: _parseInt(json['topic_id']),
      puid: resolveHupuPuid(
        directValues: <dynamic>[
          json['puid'],
          json['user_id'],
          json['uid'],
          json['author_puid'],
        ],
        schemaCandidates: <String>[
          json['schemaUrl']?.toString() ?? '',
          json['schema_url']?.toString() ?? '',
          json['url']?.toString() ?? '',
        ],
      ),
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      header: json['header']?.toString() ?? '',
      forumName: json['forum_name']?.toString() ?? '',
      topicName: json['topic_name']?.toString() ?? '',
      topicLogo: json['topic_logo']?.toString() ?? '',
      createTime: _parseInt(json['create_time']),
      replies: _parseInt(json['replies']),
      recommendNum: _parseInt(json['recommend_num']),
      shareNum: _parseInt(json['share_num']),
      lights: _parseInt(json['lights']),
      pics: _parseHotRankImages(json['pics']),
      lightReplies: _parseHotRankLightReplies(json['light_replies']),
    );
  }

}

class HupuHotRankImage {
  const HupuHotRankImage({
    required this.url,
    required this.width,
    required this.height,
    required this.isGif,
    required this.type,
  });

  final String url;
  final double width;
  final double height;
  final bool isGif;
  final String type;

  factory HupuHotRankImage.fromJson(Map<String, dynamic> json) {
    return HupuHotRankImage(
      url: json['url']?.toString() ?? '',
      width: _parseDouble(json['width']),
      height: _parseDouble(json['height']),
      isGif: _parseInt(json['is_gif']) == 1,
      type: json['type']?.toString() ?? '',
    );
  }

}

class HupuHotRankLightReply {
  const HupuHotRankLightReply({
    required this.nickname,
    required this.header,
    required this.puid,
    required this.content,
    required this.lightCount,
    required this.createTime,
    required this.pics,
  });

  final String nickname;
  final String header;
  final String puid;
  final String content;
  final int lightCount;
  final int createTime;
  final List<HupuHotRankImage> pics;

  factory HupuHotRankLightReply.fromJson(Map<String, dynamic> json) {
    return HupuHotRankLightReply(
      nickname: json['nickname']?.toString() ?? '',
      header: json['header']?.toString() ?? '',
      puid: resolveHupuPuid(
        directValues: <dynamic>[
          json['puid'],
          json['userId'],
          json['uid'],
        ],
        schemaCandidates: <String>[
          json['schemaUrl']?.toString() ?? '',
          json['schema_url']?.toString() ?? '',
          json['url']?.toString() ?? '',
        ],
      ),
      content: json['content']?.toString() ?? '',
      lightCount: _parseInt(json['light_count']),
      createTime: _parseInt(json['createTime']),
      pics: _parseHotRankImages(json['pics']),
    );
  }

}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _parseDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

List<HupuHotTagItem> _parseHotTagItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuHotTagItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuHotTagItem.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuHotRankCategory> parseHotRankCategories(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuHotRankCategory>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuHotRankCategory.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuHotRankItem> _parseHotRankItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuHotRankItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuHotRankItem.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuHotRankImage> _parseHotRankImages(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuHotRankImage>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuHotRankImage.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuHotRankLightReply> _parseHotRankLightReplies(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuHotRankLightReply>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) =>
            HupuHotRankLightReply.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

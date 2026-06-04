import 'user_identity.dart';

class HupuHotListResponse {
  const HupuHotListResponse({
    required this.items,
    required this.notice,
    required this.isEmpty,
  });

  final List<HupuFeedItem> items;
  final String notice;
  final bool isEmpty;

  factory HupuHotListResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    if (result is! Map<String, dynamic>) {
      throw StateError('Unexpected Hupu payload');
    }

    return HupuHotListResponse(
      items: _parseFeedItems(result['data']),
      notice: result['notice']?.toString() ?? '',
      isEmpty: result['empty'] == true,
    );
  }
}

class HupuFeedItem {
  const HupuFeedItem({
    required this.xid,
    required this.label,
    required this.schemaUrl,
    required this.puid,
    required this.type,
    required this.itemId,
    required this.tid,
    required this.fid,
    required this.topicId,
    required this.title,
    required this.summary,
    required this.nickname,
    required this.header,
    required this.forumName,
    required this.topicName,
    required this.createTime,
    required this.lastPostTime,
    required this.replies,
    required this.lights,
    required this.shareNum,
    required this.visits,
    required this.pics,
    required this.lightReplies,
    required this.video,
  });

  final String xid;
  final String label;
  final String schemaUrl;
  final String puid;
  final String type;
  final String itemId;
  final String tid;
  final String fid;
  final int topicId;
  final String title;
  final String summary;
  final String nickname;
  final String header;
  final String forumName;
  final String topicName;
  final int createTime;
  final int lastPostTime;
  final int replies;
  final int lights;
  final int shareNum;
  final int visits;
  final List<HupuImageItem> pics;
  final List<HupuLightReply> lightReplies;
  final HupuVideoItem? video;

  String get uniqueKey => itemId.isNotEmpty ? itemId : xid;

  factory HupuFeedItem.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final payload =
        data is Map<String, dynamic> ? data : const <String, dynamic>{};

    return HupuFeedItem(
      xid: json['xid']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      schemaUrl: json['schema_url']?.toString() ?? '',
      puid: resolveHupuPuid(
        directValues: <dynamic>[
          payload['puid'],
          payload['user_id'],
          payload['uid'],
          json['puid'],
          json['userId'],
          json['uid'],
        ],
        schemaCandidates: <String>[
          payload['schema_url']?.toString() ?? '',
          payload['schemaUrl']?.toString() ?? '',
          json['schema_url']?.toString() ?? '',
        ],
      ),
      type: payload['type']?.toString() ?? json['type']?.toString() ?? '',
      itemId: payload['itemId']?.toString() ?? json['itemId']?.toString() ?? '',
      tid: payload['tid']?.toString() ?? '',
      fid: payload['fid']?.toString() ?? '',
      topicId: _parseInt(payload['topic_id']),
      title: payload['title']?.toString() ?? '',
      summary: payload['summary']?.toString() ?? '',
      nickname: payload['nickname']?.toString() ?? '',
      header: payload['header']?.toString() ?? '',
      forumName: payload['forum_name']?.toString() ?? '',
      topicName: payload['topic_name']?.toString() ?? '',
      createTime: _parseInt(payload['create_time']),
      lastPostTime: _parseInt(payload['lastpost_time']),
      replies: _parseInt(payload['replies']),
      lights: _parseInt(payload['lights']),
      shareNum: _parseInt(payload['share_num']),
      visits: _parseInt(payload['visits']),
      pics: _parseImageItems(payload['pics']),
      lightReplies: _parseLightReplies(payload['light_replies']),
      video: payload['video'] is Map<String, dynamic>
          ? HupuVideoItem.fromJson(payload['video'] as Map<String, dynamic>)
          : null,
    );
  }
}

class HupuImageItem {
  const HupuImageItem({
    required this.url,
    required this.width,
    required this.height,
    required this.type,
  });

  final String url;
  final double width;
  final double height;
  final String type;

  factory HupuImageItem.fromJson(Map<String, dynamic> json) {
    return HupuImageItem(
      url: json['url']?.toString() ?? '',
      width: _parseDouble(json['width']),
      height: _parseDouble(json['height']),
      type: json['type']?.toString() ?? '',
    );
  }
}

class HupuLightReply {
  const HupuLightReply({
    required this.nickname,
    required this.content,
    required this.header,
    required this.puid,
    required this.lightCount,
    required this.pics,
    required this.quoteNickname,
    required this.quoteContent,
  });

  final String nickname;
  final String content;
  final String header;
  final String puid;
  final int lightCount;
  final List<HupuImageItem> pics;
  final String quoteNickname;
  final String quoteContent;

  factory HupuLightReply.fromJson(Map<String, dynamic> json) {
    final quote = json['quote'];

    return HupuLightReply(
      nickname: json['nickname']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      header: json['header']?.toString() ?? '',
      puid: resolveHupuPuid(
        directValues: <dynamic>[
          json['puid'],
          json['userId'],
          json['uid'],
          quote is Map<String, dynamic> ? quote['puid'] : null,
        ],
        schemaCandidates: <String>[
          json['schema_url']?.toString() ?? '',
          json['schemaUrl']?.toString() ?? '',
          json['url']?.toString() ?? '',
        ],
      ),
      lightCount: _parseInt(json['light_count']),
      pics: _parseImageItems(json['pics']),
      quoteNickname: quote is Map<String, dynamic>
          ? quote['nickname']?.toString() ?? ''
          : '',
      quoteContent: quote is Map<String, dynamic>
          ? quote['content']?.toString() ?? ''
          : '',
    );
  }
}

class HupuVideoItem {
  const HupuVideoItem({
    required this.cover,
    required this.backgroundImage,
    required this.duration,
    required this.playCount,
    required this.videoUrl,
    required this.size,
    required this.width,
    required this.height,
    required this.bulletCommentCount,
  });

  final String cover;
  final String backgroundImage;
  final String duration;
  final String playCount;
  final String videoUrl;
  final String size;
  final double width;
  final double height;
  final String bulletCommentCount;

  bool get isPlayable => videoUrl.isNotEmpty;

  double? get aspectRatio {
    if (width <= 0 || height <= 0) {
      return null;
    }
    return width / height;
  }

  factory HupuVideoItem.fromJson(Map<String, dynamic> json) {
    return HupuVideoItem(
      cover: json['img']?.toString() ?? '',
      backgroundImage: json['bg_img']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      playCount: json['play_num']?.toString() ?? '',
      videoUrl: json['url']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      width: _parseDouble(json['width']),
      height: _parseDouble(json['height']),
      bulletCommentCount: json['bullet_comment_num']?.toString() ?? '',
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

List<HupuFeedItem> _parseFeedItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuFeedItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map((item) => HupuFeedItem.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<HupuImageItem> _parseImageItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuImageItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map((item) => HupuImageItem.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<HupuLightReply> _parseLightReplies(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuLightReply>[];
  }

  return rawItems
      .whereType<Map>()
      .map((item) => HupuLightReply.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

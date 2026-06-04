import 'user_identity.dart';

class HupuPostDetail {
  const HupuPostDetail({
    required this.tid,
    required this.fid,
    required this.topicId,
    required this.authorPuid,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorAvatar,
    required this.authorPublishTime,
    required this.forumName,
    required this.topicName,
    required this.replyCount,
    required this.recommendCount,
    required this.shareCount,
    required this.viewCount,
    required this.lightCount,
    required this.tagInfoList,
    required this.cardList,
    required this.videoInfo,
  });

  final String tid;
  final String fid;
  final int topicId;
  final String authorPuid;
  final String title;
  final String content;
  final String authorName;
  final String authorAvatar;
  final String authorPublishTime;
  final String forumName;
  final String topicName;
  final int replyCount;
  final int recommendCount;
  final int shareCount;
  final int viewCount;
  final int lightCount;
  final List<HupuPostTagInfo> tagInfoList;
  final List<HupuPostRelatedCard> cardList;
  final HupuPostVideoInfo? videoInfo;

  bool get hasVideo => videoInfo?.videoUrl.trim().isNotEmpty == true;

  factory HupuPostDetail.fromJson(Map<String, dynamic> json) {
    final offlineData = json['offline_data'];
    final offlinePayload =
        offlineData is Map<String, dynamic> ? offlineData['data'] : null;
    final payload =
        offlinePayload is Map<String, dynamic> ? offlinePayload : json;
    final author = json['author'];
    final authorPayload =
        author is Map<String, dynamic> ? author : const <String, dynamic>{};
    final forum = payload['forum'];
    final forumPayload =
        forum is Map<String, dynamic> ? forum : const <String, dynamic>{};
    final topic = payload['topic'];
    final topicPayload =
        topic is Map<String, dynamic> ? topic : const <String, dynamic>{};

    return HupuPostDetail(
      tid: payload['tid']?.toString() ?? json['tid']?.toString() ?? '',
      fid: payload['fid']?.toString() ?? json['fid']?.toString() ?? '',
      topicId: _parseInt(
        payload['topic_id'] ?? topicPayload['topic_id'] ?? json['topic_id'],
      ),
      authorPuid: payload['author_puid']?.toString() ??
          payload['puid']?.toString() ??
          json['authorPuid']?.toString() ??
          '',
      title: payload['title']?.toString() ?? json['title']?.toString() ?? '',
      content:
          payload['content']?.toString() ?? json['content']?.toString() ?? '',
      authorName: authorPayload['name']?.toString() ??
          payload['username']?.toString() ??
          json['userName']?.toString() ??
          '',
      authorAvatar: authorPayload['header']?.toString() ??
          payload['userImg']?.toString() ??
          '',
      authorPublishTime: authorPayload['time']?.toString() ??
          payload['time']?.toString() ??
          '',
      forumName: forumPayload['name']?.toString() ??
          json['forum_name']?.toString() ??
          '',
      topicName: topicPayload['name']?.toString() ?? '',
      replyCount: _parseInt(payload['replies'] ?? json['replies']),
      recommendCount: _parseInt(
        payload['recommend_num'] ?? payload['nps'] ?? json['nps'],
      ),
      shareCount: _parseInt(payload['share_num'] ?? json['share_num']),
      viewCount: _parseInt(authorPayload['view'] ?? payload['visits']),
      lightCount: _parseInt(payload['lights'] ?? json['lights']),
      tagInfoList: _parseTagInfoList(json['tagInfoList']),
      cardList: _parseRelatedCardList(json['cardList']),
      videoInfo: _parseVideoInfo(
        json['video_info'] ?? payload['video_info'],
      ),
    );
  }
}

class HupuPostVideoInfo {
  const HupuPostVideoInfo({
    required this.videoUrl,
    required this.coverUrl,
    required this.posterUrl,
    required this.backgroundUrl,
    required this.originUrl,
    required this.videoId,
    required this.durationText,
    required this.playCountText,
    required this.width,
    required this.height,
  });

  final String videoUrl;
  final String coverUrl;
  final String posterUrl;
  final String backgroundUrl;
  final String originUrl;
  final String videoId;
  final String durationText;
  final String playCountText;
  final double width;
  final double height;

  double? get aspectRatio {
    if (width <= 0 || height <= 0) {
      return null;
    }
    return width / height;
  }

  factory HupuPostVideoInfo.fromJson(Map<String, dynamic> json) {
    return HupuPostVideoInfo(
      videoUrl: json['src']?.toString() ?? '',
      coverUrl: json['cover_url']?.toString() ?? '',
      posterUrl: json['img']?.toString() ?? '',
      backgroundUrl: json['bg_img']?.toString() ?? '',
      originUrl: json['from_url']?.toString() ?? '',
      videoId: json['vid']?.toString() ?? '',
      durationText: json['duration']?.toString() ?? '',
      playCountText: json['play_num']?.toString() ?? '',
      width: _parseDouble(json['width']),
      height: _parseDouble(json['height']),
    );
  }
}

class HupuPostTagInfo {
  const HupuPostTagInfo({
    required this.tagId,
    required this.tagName,
    required this.tagSchema,
    required this.description,
    required this.followNum,
    required this.discussNum,
    required this.icon,
    required this.banner,
    required this.bannerRgb,
    required this.followed,
    required this.aggregationType,
    required this.heat,
    required this.activityJumpUrl,
    required this.activityIcon,
  });

  final int tagId;
  final String tagName;
  final String tagSchema;
  final String description;
  final int followNum;
  final int discussNum;
  final String icon;
  final String banner;
  final String bannerRgb;
  final int followed;
  final String aggregationType;
  final String heat;
  final String activityJumpUrl;
  final String activityIcon;

  factory HupuPostTagInfo.fromJson(Map<String, dynamic> json) {
    return HupuPostTagInfo(
      tagId: _parseInt(json['tagId']),
      tagName: json['tagName']?.toString() ?? '',
      tagSchema: json['tagSchema']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      followNum: _parseInt(json['followNum']),
      discussNum: _parseInt(json['discussNum']),
      icon: json['icon']?.toString() ?? '',
      banner: json['banner']?.toString() ?? '',
      bannerRgb: json['bannerRgb']?.toString() ?? '',
      followed: _parseInt(json['followed']),
      aggregationType: json['aggregationType']?.toString() ?? '',
      heat: json['heat']?.toString() ?? '',
      activityJumpUrl: json['activityJumpUrl']?.toString() ?? '',
      activityIcon: json['activityIcon']?.toString() ?? '',
    );
  }
}

class HupuPostRelatedCard {
  const HupuPostRelatedCard({
    required this.image,
    required this.bizId,
    required this.cardType,
    required this.title,
    required this.url,
    required this.isNational,
  });

  final String image;
  final String bizId;
  final int cardType;
  final String title;
  final String url;
  final bool isNational;

  factory HupuPostRelatedCard.fromJson(Map<String, dynamic> json) {
    return HupuPostRelatedCard(
      image: json['image']?.toString() ?? '',
      bizId: json['bizId']?.toString() ?? '',
      cardType: _parseInt(json['cardType']),
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      isNational: json['isNational'] == true,
    );
  }
}

class HupuPostCommentResponse {
  const HupuPostCommentResponse({
    required this.comments,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
  });

  final List<HupuPostComment> comments;
  final int totalCount;
  final int totalPages;
  final int currentPage;

  factory HupuPostCommentResponse.fromJson(
    Map<String, dynamic> json, {
    required bool isLightReplies,
    int currentPage = 1,
  }) {
    final data = json['data'];
    final dataPayload = data is Map<String, dynamic> ? data : json;
    final result = dataPayload['result'];
    final payload = result is Map<String, dynamic> ? result : dataPayload;
    final list = payload['list'];
    final comments = list is List
        ? list
            .whereType<Map>()
            .map(
              (item) => HupuPostComment.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
        : const <HupuPostComment>[];

    return HupuPostCommentResponse(
      comments: comments,
      totalCount: _parseInt(
        payload[isLightReplies ? 'all_count' : 'all_page'],
      ),
      totalPages:
          isLightReplies ? 1 : _parseInt(payload['all_page']).clamp(1, 999999),
      currentPage: currentPage,
    );
  }
}

class HupuPostComment {
  const HupuPostComment({
    required this.commentId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.timeText,
    required this.location,
    required this.content,
    required this.lightCount,
    required this.replyCount,
    required this.createdAt,
    required this.floor,
    required this.quote,
  });

  final String commentId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String timeText;
  final String location;
  final String content;
  final int lightCount;
  final int replyCount;
  final int createdAt;
  final int floor;
  final HupuPostQuote? quote;

  factory HupuPostComment.fromJson(Map<String, dynamic> json) {
    final checkReplyInfo = json['check_reply_info'];
    final checkReplyPayload = checkReplyInfo is Map<String, dynamic>
        ? checkReplyInfo
        : const <String, dynamic>{};
    final quoteList = json['quote'];
    HupuPostQuote? quote;
    if (quoteList is List && quoteList.isNotEmpty) {
      final first = quoteList.first;
      if (first is Map<String, dynamic>) {
        quote = HupuPostQuote.fromJson(first);
      } else if (first is Map) {
        quote = HupuPostQuote.fromJson(Map<String, dynamic>.from(first));
      }
    }

    return HupuPostComment(
      commentId: json['pid']?.toString() ?? '',
      userId: json['puid']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      userAvatar: json['userImg']?.toString() ?? '',
      timeText: json['time']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      lightCount: _parseInt(json['light_count'] ?? json['allLightCount']),
      replyCount: _parseInt(checkReplyPayload['num']),
      createdAt: _parseInt(json['create_time']),
      floor: _parseInt(json['floor']),
      quote: quote,
    );
  }
}

class HupuPostQuote {
  const HupuPostQuote({
    required this.userName,
    required this.userId,
    required this.content,
  });

  final String userName;
  final String userId;
  final String content;

  factory HupuPostQuote.fromJson(Map<String, dynamic> json) {
    var userName = '';
    final header = json['header'];
    if (header is List && header.isNotEmpty) {
      final headerText = header.first?.toString() ?? '';
      final userNameMatch = RegExp(r'>([^<]+)<').firstMatch(headerText);
      if (userNameMatch != null) {
        userName = userNameMatch.group(1) ?? '';
      }
    }

    return HupuPostQuote(
      userName: userName,
      userId: resolveHupuPuid(
        directValues: <dynamic>[
          json['puid'],
          json['userId'],
          json['uid'],
        ],
        schemaCandidates: <String>[
          json['schema_url']?.toString() ?? '',
          json['schemaUrl']?.toString() ?? '',
          json['url']?.toString() ?? '',
          if (header is List) ...header.map((item) => item?.toString() ?? ''),
        ],
      ),
      content: json['content']?.toString() ?? '',
    );
  }
}

class HupuCheckReplyResponse {
  const HupuCheckReplyResponse({
    required this.post,
    required this.replies,
  });

  final HupuPostComment post;
  final List<HupuPostComment> replies;

  factory HupuCheckReplyResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final payload = result is Map<String, dynamic> ? result : json;
    final postInfo = payload['post_info'];
    final postPayload =
        postInfo is Map<String, dynamic> ? postInfo : const <String, dynamic>{};
    final list = payload['list'];
    final replies = list is List
        ? list
            .whereType<Map>()
            .map(
              (item) => HupuPostComment.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
        : const <HupuPostComment>[];

    return HupuCheckReplyResponse(
      post: HupuPostComment.fromJson(postPayload),
      replies: replies,
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

List<HupuPostTagInfo> _parseTagInfoList(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuPostTagInfo>[];
  }

  return rawItems
      .whereType<Map>()
      .map((item) => HupuPostTagInfo.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

List<HupuPostRelatedCard> _parseRelatedCardList(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuPostRelatedCard>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuPostRelatedCard.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

HupuPostVideoInfo? _parseVideoInfo(dynamic rawData) {
  if (rawData is Map<String, dynamic>) {
    return HupuPostVideoInfo.fromJson(rawData);
  }
  if (rawData is Map) {
    return HupuPostVideoInfo.fromJson(Map<String, dynamic>.from(rawData));
  }
  return null;
}

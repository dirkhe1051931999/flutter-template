class HupuUserProfile {
  const HupuUserProfile({
    required this.puid,
    required this.nickname,
    required this.header,
    required this.headerBack,
    required this.gender,
    required this.location,
    required this.locationText,
    required this.regTimeText,
    required this.reputationValue,
    required this.levelText,
    required this.followStatus,
    required this.followCount,
    required this.fansCount,
    required this.beLightCount,
    required this.beRecommendCount,
    required this.postCount,
    required this.replyCount,
    required this.recommendCount,
    required this.followButtonText,
  });

  final String puid;
  final String nickname;
  final String header;
  final String headerBack;
  final int gender;
  final String location;
  final String locationText;
  final String regTimeText;
  final int reputationValue;
  final String levelText;
  final int followStatus;
  final int followCount;
  final int fansCount;
  final int beLightCount;
  final int beRecommendCount;
  final int postCount;
  final int replyCount;
  final int recommendCount;
  final String followButtonText;

  factory HupuUserProfile.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final payload = result is Map<String, dynamic> ? result : json;
    final reputation = payload['reputation'];
    final reputationPayload = reputation is Map<String, dynamic>
        ? reputation
        : const <String, dynamic>{};

    return HupuUserProfile(
      puid: payload['puid']?.toString() ?? '',
      nickname: payload['nickname']?.toString() ?? '',
      header: payload['header']?.toString() ?? '',
      headerBack: payload['header_back']?.toString() ?? '',
      gender: _parseInt(payload['gender']),
      location: payload['location']?.toString() ?? '',
      locationText: payload['location_str']?.toString() ?? '',
      regTimeText: payload['reg_time_str']?.toString() ?? '',
      reputationValue: _parseInt(reputationPayload['value']),
      levelText: payload['bbsUserLevelDesc']?.toString() ?? '',
      followStatus: _parseInt(payload['follow_status']),
      followCount: _parseInt(payload['follow_count']),
      fansCount: _parseInt(payload['be_follow_count']),
      beLightCount: _parseInt(payload['be_light_count']),
      beRecommendCount: _parseInt(payload['be_recommend_count']),
      postCount: _parseInt(payload['bbs_post_count']),
      replyCount: _parseInt(payload['bbs_msg_count']),
      recommendCount: _parseInt(payload['bbs_recommend_count']),
      followButtonText: payload['followContent']?.toString() ?? '',
    );
  }
}

class HupuUserThreadPage {
  const HupuUserThreadPage({
    required this.items,
    required this.page,
    required this.totalPage,
    required this.hasNextPage,
  });

  final List<HupuUserThreadRecord> items;
  final int page;
  final int totalPage;
  final bool hasNextPage;

  factory HupuUserThreadPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final payload = data is Map<String, dynamic> ? data : json;
    final list = payload['content'] ?? payload['list'] ?? payload['data'];
    final page = _parseInt(payload['page']);
    final totalPage = _parseInt(payload['totalPage']);
    final totalElements = _parseInt(payload['totalElements']);
    final pageSize = _parseInt(payload['pageSize']);
    final inferredHasNext = totalPage > 0 && page > 0 && page < totalPage;
    final fallbackHasNext =
        pageSize > 0 && totalElements > 0 && page * pageSize < totalElements;

    return HupuUserThreadPage(
      items: _parseThreadRecords(list),
      page: page <= 0 ? 1 : page,
      totalPage: totalPage <= 0 ? 1 : totalPage,
      hasNextPage: inferredHasNext || fallbackHasNext,
    );
  }
}

class HupuUserThreadRecord {
  const HupuUserThreadRecord({
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
    required this.recommendCount,
    required this.lightCount,
    required this.shareCount,
    required this.visitCount,
    required this.pics,
    required this.video,
  });

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
  final int recommendCount;
  final int lightCount;
  final int shareCount;
  final int visitCount;
  final List<HupuUserMediaImage> pics;
  final HupuUserMediaVideo? video;

  factory HupuUserThreadRecord.fromJson(Map<String, dynamic> json) {
    return HupuUserThreadRecord(
      tid: json['tid']?.toString() ?? '',
      fid: json['fid']?.toString() ?? '',
      topicId: _parseInt(json['topic_id'] ?? json['topicId']),
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      header: json['header']?.toString() ?? '',
      forumName: json['forum_name']?.toString() ?? '',
      topicName: json['topic_name']?.toString() ?? '',
      createTime: _parseInt(json['create_time']),
      lastPostTime: _parseInt(json['lastpost_time']),
      replies: _parseInt(json['replies']),
      recommendCount: _parseInt(json['recommend_num']),
      lightCount: _parseInt(json['lights']),
      shareCount: _parseInt(json['share_num']),
      visitCount: _parseInt(json['visits']),
      pics: _parseMediaImages(json['pics']),
      video: json['video'] is Map<String, dynamic>
          ? HupuUserMediaVideo.fromJson(json['video'] as Map<String, dynamic>)
          : null,
    );
  }
}

class HupuUserReplyPage {
  const HupuUserReplyPage({
    required this.items,
    required this.nextMaxTime,
    required this.hasNextPage,
  });

  final List<HupuUserReplyRecord> items;
  final int nextMaxTime;
  final bool hasNextPage;

  factory HupuUserReplyPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final payload = data is Map<String, dynamic> ? data : json;
    return HupuUserReplyPage(
      items: _parseReplyRecords(payload['replyWithQuoteDtoList']),
      nextMaxTime: _parseInt(payload['maxTime']),
      hasNextPage: payload['nextPage'] == true,
    );
  }
}

class HupuUserReplyRecord {
  const HupuUserReplyRecord({
    required this.tid,
    required this.pid,
    required this.title,
    required this.content,
    required this.username,
    required this.header,
    required this.formatTime,
    required this.lightCount,
    required this.picInfos,
    required this.quoteInfo,
  });

  final String tid;
  final String pid;
  final String title;
  final String content;
  final String username;
  final String header;
  final String formatTime;
  final int lightCount;
  final List<HupuUserMediaImage> picInfos;
  final HupuUserReplyQuote? quoteInfo;

  factory HupuUserReplyRecord.fromJson(Map<String, dynamic> json) {
    return HupuUserReplyRecord(
      tid: json['tid']?.toString() ?? '',
      pid: json['pid']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      header: json['header']?.toString() ?? '',
      formatTime: json['formatTime']?.toString() ?? '',
      lightCount: _parseInt(json['lightCount']),
      picInfos: _parseMediaImages(json['picInfos']),
      quoteInfo: json['quoteInfo'] is Map<String, dynamic>
          ? HupuUserReplyQuote.fromJson(
              json['quoteInfo'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class HupuUserReplyQuote {
  const HupuUserReplyQuote({
    required this.pid,
    required this.title,
    required this.content,
    required this.username,
    required this.picInfos,
  });

  final String pid;
  final String title;
  final String content;
  final String username;
  final List<HupuUserMediaImage> picInfos;

  factory HupuUserReplyQuote.fromJson(Map<String, dynamic> json) {
    return HupuUserReplyQuote(
      pid: json['pid']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      picInfos: _parseMediaImages(json['picInfos']),
    );
  }
}

class HupuUserMediaImage {
  const HupuUserMediaImage({
    required this.url,
    required this.width,
    required this.height,
    required this.type,
  });

  final String url;
  final double width;
  final double height;
  final String type;

  factory HupuUserMediaImage.fromJson(Map<String, dynamic> json) {
    return HupuUserMediaImage(
      url: json['url']?.toString() ?? '',
      width: _parseDouble(json['width']),
      height: _parseDouble(json['height']),
      type: json['type']?.toString() ?? '',
    );
  }
}

class HupuUserMediaVideo {
  const HupuUserMediaVideo({
    required this.cover,
    required this.videoUrl,
    required this.duration,
    required this.playCount,
    required this.width,
    required this.height,
  });

  final String cover;
  final String videoUrl;
  final String duration;
  final String playCount;
  final double width;
  final double height;

  factory HupuUserMediaVideo.fromJson(Map<String, dynamic> json) {
    return HupuUserMediaVideo(
      cover: json['img']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? json['url']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      playCount: json['play_num']?.toString() ?? '',
      width: _parseDouble(json['width']),
      height: _parseDouble(json['height']),
    );
  }
}

List<HupuUserThreadRecord> _parseThreadRecords(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuUserThreadRecord>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuUserThreadRecord.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList(growable: false);
}

List<HupuUserReplyRecord> _parseReplyRecords(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuUserReplyRecord>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuUserReplyRecord.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList(growable: false);
}

List<HupuUserMediaImage> _parseMediaImages(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuUserMediaImage>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuUserMediaImage.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList(growable: false);
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

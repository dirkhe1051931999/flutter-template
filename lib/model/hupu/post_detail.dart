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
    final payload = data is Map<String, dynamic> ? data : json;
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
    required this.content,
  });

  final String userName;
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

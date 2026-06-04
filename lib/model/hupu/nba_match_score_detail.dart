import 'user_identity.dart';

class HupuNbaMatchScoreDetail {
  const HupuNbaMatchScoreDetail({
    required this.scoreBizId,
    required this.nodeId,
    required this.name,
    required this.logoUrl,
    required this.teamLogo,
    required this.matchName,
    required this.playerId,
    required this.labelText,
    required this.scoreAvg,
    required this.scorePersonCount,
    required this.commentCount,
    required this.scoreDistribution,
    required this.minutes,
    required this.points,
    required this.rebounds,
    required this.assists,
    required this.steals,
    required this.blocks,
    required this.plusMinus,
    required this.hotComment,
  });

  final String scoreBizId;
  final int nodeId;
  final String name;
  final String logoUrl;
  final String teamLogo;
  final String matchName;
  final String playerId;
  final String labelText;
  final double scoreAvg;
  final int scorePersonCount;
  final int commentCount;
  final Map<int, int> scoreDistribution;
  final String minutes;
  final int points;
  final int rebounds;
  final int assists;
  final int steals;
  final int blocks;
  final String plusMinus;
  final String hotComment;

  String get scoreText => scoreAvg <= 0 ? '--' : scoreAvg.toStringAsFixed(1);

  String get scoreCountText {
    if (scorePersonCount <= 0) {
      return '暂无JR评分';
    }
    return '${_countText(scorePersonCount)} JR评分';
  }

  String get commentTitle => '亮回复 /$commentCount';

  factory HupuNbaMatchScoreDetail.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final detail = _asMap(data['detail']);
    final self = _asMap(data['self']);
    final node = detail.isNotEmpty ? detail : _asMap(self['node']);
    final infoJson = _asMap(node['infoJson']);
    final labels = infoJson['playerLabel'];
    final firstLabel =
        labels is List && labels.isNotEmpty ? _asMap(labels.first) : const {};
    final hotCommentModels = node['hotCommentModels'];
    final firstHotComment =
        hotCommentModels is List && hotCommentModels.isNotEmpty
            ? _asMap(hotCommentModels.first)
            : const <String, dynamic>{};
    final hottestComments = node['hottestComments'];
    final fallbackHotComment =
        hottestComments is List && hottestComments.isNotEmpty
            ? _stringValue(hottestComments.first)
            : '';
    return HupuNbaMatchScoreDetail(
      scoreBizId: _stringValue(node['bizId']),
      nodeId: _intValue(data['nodeId']) > 0
          ? _intValue(data['nodeId'])
          : _intValue(self['nodeId']),
      name: _stringValue(node['name']),
      logoUrl: _firstString(node['image']),
      teamLogo: _firstString(infoJson['teamLogo']),
      matchName: _firstString(infoJson['basketball_match']),
      playerId: _firstString(infoJson['itemId']),
      labelText: _stringValue(firstLabel['text']),
      scoreAvg: _doubleValue(node['scoreAvg']),
      scorePersonCount: _intValue(node['summedScorePersonCount']),
      commentCount: _intValue(node['summedCommentCount']),
      scoreDistribution: _parseDistribution(node['scoreDistribution']),
      minutes: _firstString(infoJson['minutes']),
      points: _intValue(_firstString(infoJson['pts'])),
      rebounds: _intValue(_firstString(infoJson['reb'])),
      assists: _intValue(_firstString(infoJson['ast'])),
      steals: _intValue(_firstString(infoJson['stl'])),
      blocks: _intValue(_firstString(infoJson['blk'])),
      plusMinus: _firstString(infoJson['plusMinus']),
      hotComment: _stringValue(firstHotComment['commentContent']).isNotEmpty
          ? _stringValue(firstHotComment['commentContent'])
          : fallbackHotComment,
    );
  }
}

class HupuNbaMatchScoreCommentPage {
  const HupuNbaMatchScoreCommentPage({
    required this.comments,
    required this.cursorPublishTime,
    required this.commentCount,
    required this.hasMore,
  });

  final List<HupuNbaMatchScoreComment> comments;
  final String cursorPublishTime;
  final int commentCount;
  final bool hasMore;

  factory HupuNbaMatchScoreCommentPage.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final rawComments = data['comments'] ?? json['data'];
    final comments = rawComments is List
        ? rawComments
            .whereType<Map>()
            .map(
              (item) => HupuNbaMatchScoreComment.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
        : const <HupuNbaMatchScoreComment>[];
    final cursor = _asMap(data['cursor']);
    return HupuNbaMatchScoreCommentPage(
      comments: comments,
      cursorPublishTime: _stringValue(cursor['publishTime']),
      commentCount: _intValue(data['commentCount']),
      hasMore: data['hasMore'] == true,
    );
  }
}

class HupuNbaMatchScoreComment {
  const HupuNbaMatchScoreComment({
    required this.commentId,
    required this.subjectId,
    required this.puid,
    required this.userName,
    required this.avatarUrl,
    required this.content,
    required this.dateText,
    required this.ipLocation,
    required this.lightCount,
    required this.score,
    required this.replyCount,
    required this.imageUrls,
    required this.subComments,
  });

  final String commentId;
  final String subjectId;
  final String puid;
  final String userName;
  final String avatarUrl;
  final String content;
  final String dateText;
  final String ipLocation;
  final int lightCount;
  final int score;
  final int replyCount;
  final List<String> imageUrls;
  final List<HupuNbaMatchScoreSubComment> subComments;

  bool get hasContent => content.trim().isNotEmpty || imageUrls.isNotEmpty;
  bool get hasReplies => subComments.isNotEmpty || replyCount > 0;

  factory HupuNbaMatchScoreComment.fromJson(Map<String, dynamic> json) {
    return HupuNbaMatchScoreComment(
      commentId: _stringValue(json['commentId']),
      subjectId: _stringValue(json['subjectId']),
      puid: resolveHupuPuid(
        directValues: <dynamic>[
          json['commentUserId'],
          json['puid'],
          json['userId'],
          json['uid'],
        ],
        schemaCandidates: <String>[
          _stringValue(json['commentUserSchema']),
          _stringValue(json['commentUserUrl']),
          _stringValue(json['schemaUrl']),
          _stringValue(json['url']),
        ],
      ),
      userName: _stringValue(json['commentUserName']),
      avatarUrl: _stringValue(json['commentUserHeadImg']),
      content: _stringValue(json['commentContent']),
      dateText: _stringValue(json['commentDate']),
      ipLocation: _stringValue(json['ipLocation']),
      lightCount: _intValue(json['lightCount']),
      score: _intValue(json['score']),
      replyCount: _intValue(json['descendantCount'] ?? json['subCommentCount']),
      imageUrls: _parseCommentImages(json['commentContentImages']),
      subComments: _parseSubComments(json['subCommentList']),
    );
  }
}

class HupuNbaMatchScoreSubComment {
  const HupuNbaMatchScoreSubComment({
    required this.commentId,
    required this.puid,
    required this.userName,
    required this.avatarUrl,
    required this.content,
    required this.dateText,
    required this.ipLocation,
    required this.lightCount,
    required this.imageUrls,
  });

  final String commentId;
  final String puid;
  final String userName;
  final String avatarUrl;
  final String content;
  final String dateText;
  final String ipLocation;
  final int lightCount;
  final List<String> imageUrls;

  bool get hasContent => content.trim().isNotEmpty || imageUrls.isNotEmpty;

  factory HupuNbaMatchScoreSubComment.fromJson(Map<String, dynamic> json) {
    return HupuNbaMatchScoreSubComment(
      commentId: _stringValue(json['commentId']),
      puid: resolveHupuPuid(
        directValues: <dynamic>[
          json['commentUserId'],
          json['puid'],
          json['userId'],
          json['uid'],
        ],
        schemaCandidates: <String>[
          _stringValue(json['commentUserSchema']),
          _stringValue(json['commentUserUrl']),
          _stringValue(json['schemaUrl']),
          _stringValue(json['url']),
        ],
      ),
      userName: _stringValue(json['commentUserName']),
      avatarUrl: _stringValue(json['commentUserHeadImg']),
      content: _stringValue(json['commentContent']),
      dateText: _stringValue(json['commentDate']),
      ipLocation: _stringValue(json['ipLocation']),
      lightCount: _intValue(json['lightCount']),
      imageUrls: _parseCommentImages(json['commentContentImages']),
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

String _firstString(dynamic value) {
  if (value is List && value.isNotEmpty) {
    return _stringValue(value.first);
  }
  return _stringValue(value);
}

int _intValue(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _doubleValue(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

Map<int, int> _parseDistribution(dynamic raw) {
  final map = _asMap(raw);
  final result = <int, int>{};
  for (final key in const <int>[10, 8, 6, 4, 2]) {
    result[key] = _intValue(map['$key']);
  }
  return result;
}

List<String> _parseCommentImages(dynamic rawItems) {
  if (rawItems is! List) {
    return const <String>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => _stringValue(item['commentContent']))
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

List<HupuNbaMatchScoreSubComment> _parseSubComments(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuNbaMatchScoreSubComment>[];
  }
  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuNbaMatchScoreSubComment.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .where((item) => item.hasContent)
      .toList(growable: false);
}

String _countText(int count) {
  if (count >= 10000) {
    final value = count / 10000;
    return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}万';
  }
  return '$count';
}

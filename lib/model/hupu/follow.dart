class HupuFollowContent {
  const HupuFollowContent({
    required this.hasMore,
    required this.threads,
    required this.recommendedUsers,
  });

  final bool hasMore;
  final List<HupuFollowRecommendThread> threads;
  final List<HupuFollowRecommendUser> recommendedUsers;

  factory HupuFollowContent.fromJson(Map<String, dynamic> json) {
    final result = _mapValue(json['result']);
    return HupuFollowContent(
      hasMore: _intValue(result['hasMore']) > 0,
      threads: _listValue(result['threads'])
          .map(HupuFollowRecommendThread.fromJson)
          .toList(growable: false),
      recommendedUsers: _listValue(result['verticalRecommend'])
          .map(HupuFollowRecommendUser.fromJson)
          .toList(growable: false),
    );
  }
}

class HupuFollowRecommendUser {
  const HupuFollowRecommendUser({
    required this.puid,
    required this.nickname,
    required this.avatar,
    required this.reasons,
    required this.threads,
  });

  final String puid;
  final String nickname;
  final String avatar;
  final List<String> reasons;
  final List<HupuFollowRecommendThread> threads;

  factory HupuFollowRecommendUser.fromJson(Map<String, dynamic> json) {
    return HupuFollowRecommendUser(
      puid: _stringValue(json['puid']),
      nickname: _stringValue(json['nickname']),
      avatar: _stringValue(json['header']),
      reasons: _rawListValue(json['reasons'])
          .map(_stringValue)
          .where((reason) => reason.isNotEmpty)
          .toList(growable: false),
      threads: _listValue(json['threads'])
          .map(HupuFollowRecommendThread.fromJson)
          .toList(growable: false),
    );
  }
}

class HupuFollowRecommendThread {
  const HupuFollowRecommendThread({
    required this.tid,
    required this.title,
    required this.visits,
    required this.replies,
  });

  final String tid;
  final String title;
  final int visits;
  final int replies;

  factory HupuFollowRecommendThread.fromJson(Map<String, dynamic> json) {
    return HupuFollowRecommendThread(
      tid: _stringValue(json['tid']),
      title: _stringValue(json['title']),
      visits: _intValue(json['visits']),
      replies: _intValue(json['replies']),
    );
  }
}

Map<String, dynamic> _mapValue(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map(
      (key, dynamic item) => MapEntry<String, dynamic>(key.toString(), item),
    );
  }
  return const <String, dynamic>{};
}

List<Map<String, dynamic>> _listValue(dynamic value) {
  return _rawListValue(value).map(_mapValue).toList(growable: false);
}

List<dynamic> _rawListValue(dynamic value) {
  if (value is List) {
    return value;
  }
  return const <dynamic>[];
}

String _stringValue(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
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

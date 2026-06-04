class HupuNbaMatchScoreData {
  const HupuNbaMatchScoreData({
    required this.matchId,
    required this.matchScoreBizId,
    required this.rootNodeId,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.homePlayers,
    required this.awayPlayers,
  });

  final String matchId;
  final String matchScoreBizId;
  final int rootNodeId;
  final String homeTeamId;
  final String awayTeamId;
  final String homeTeamName;
  final String awayTeamName;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final List<HupuNbaMatchScorePlayer> homePlayers;
  final List<HupuNbaMatchScorePlayer> awayPlayers;

  bool get hasItems => homePlayers.isNotEmpty || awayPlayers.isNotEmpty;

  List<HupuNbaMatchScoreTeam> get teams {
    return <HupuNbaMatchScoreTeam>[
      HupuNbaMatchScoreTeam(
        teamId: awayTeamId,
        teamName: awayTeamName,
        teamLogo: awayTeamLogo,
        players: awayPlayers,
      ),
      HupuNbaMatchScoreTeam(
        teamId: homeTeamId,
        teamName: homeTeamName,
        teamLogo: homeTeamLogo,
        players: homePlayers,
      ),
    ];
  }
}

class HupuNbaMatchScoreTeam {
  const HupuNbaMatchScoreTeam({
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.players,
  });

  final String teamId;
  final String teamName;
  final String teamLogo;
  final List<HupuNbaMatchScorePlayer> players;
}

class HupuNbaMatchScorePlayer {
  const HupuNbaMatchScorePlayer({
    required this.teamId,
    required this.playerId,
    required this.name,
    required this.photo,
    required this.minutes,
    required this.points,
    required this.rebounds,
    required this.assists,
    required this.turnovers,
    required this.steals,
    required this.blocks,
    required this.plusMinus,
    required this.scoreBizId,
    required this.scoreAvg,
    required this.scorePersonCount,
    required this.hotComment,
    required this.sort,
    required this.didNotPlay,
  });

  final String teamId;
  final String playerId;
  final String name;
  final String photo;
  final String minutes;
  final int points;
  final int rebounds;
  final int assists;
  final int turnovers;
  final int steals;
  final int blocks;
  final String plusMinus;
  final String scoreBizId;
  final double scoreAvg;
  final int scorePersonCount;
  final String hotComment;
  final int sort;
  final bool didNotPlay;

  String get displayName => name;

  String get displayScore => scoreAvg <= 0 ? '--' : scoreAvg.toStringAsFixed(1);

  String get scoreCountText {
    if (scorePersonCount <= 0) {
      return '暂无JR评分';
    }
    return '${_countText(scorePersonCount)} JR评分';
  }

  String get statSummary {
    if (didNotPlay) {
      return '该球员未上场';
    }
    final parts = <String>[
      if (minutes.isNotEmpty && minutes != '-') minutes,
      '$points分',
      '$rebounds板',
      '$assists助',
    ];
    if (turnovers > 0) {
      parts.add('$turnovers失误');
    }
    if (steals > 0) {
      parts.add('$steals断');
    }
    if (blocks > 0) {
      parts.add('$blocks帽');
    }
    return parts.join(' ');
  }
}

HupuNbaMatchScoreData parseHupuNbaMatchScoreData({
  required Map<String, dynamic> scoreSelfJson,
  required Map<String, dynamic> groupJson,
  required String matchScoreBizId,
}) {
  final selfData = _asMap(scoreSelfJson['data']);
  final detail = _asMap(selfData['detail']);
  final infoJson = _asMap(detail['infoJson']);
  final players = parseHupuNbaMatchScorePlayers(groupJson);

  return HupuNbaMatchScoreData(
    matchId: _firstString(infoJson['matchId']),
    matchScoreBizId: matchScoreBizId,
    rootNodeId: _intValue(selfData['nodeId']),
    homeTeamId: _firstString(infoJson['homeTeamId']),
    awayTeamId: _firstString(infoJson['awayTeamId']),
    homeTeamName: _firstString(infoJson['homeTeamName']),
    awayTeamName: _firstString(infoJson['awayTeamName']),
    homeTeamLogo: _firstString(infoJson['homeTeamLogo']),
    awayTeamLogo: _firstString(infoJson['awayTeamLogo']),
    homePlayers: _playersForTeam(
      players: players,
      teamId: _firstString(infoJson['homeTeamId']),
    ),
    awayPlayers: _playersForTeam(
      players: players,
      teamId: _firstString(infoJson['awayTeamId']),
    ),
  );
}

List<HupuNbaMatchScorePlayer> parseHupuNbaMatchScorePlayers(
  Map<String, dynamic> json,
) {
  final data = _asMap(json['data']);
  final pageResult = _asMap(data['nodePageResult']);
  final rawItems = pageResult['data'];
  if (rawItems is! List) {
    return const <HupuNbaMatchScorePlayer>[];
  }
  final result = <HupuNbaMatchScorePlayer>[];
  for (var index = 0; index < rawItems.length; index += 1) {
    final item = rawItems[index];
    if (item is! Map) {
      continue;
    }
    final player = _parseScorePlayer(
      Map<String, dynamic>.from(item),
      index: index,
    );
    if (player != null) {
      result.add(player);
    }
  }
  result.sort((a, b) => a.sort.compareTo(b.sort));
  return result;
}

int parseHupuNbaMatchScoreRootNodeId(Map<String, dynamic> json) {
  final data = _asMap(json['data']);
  return _intValue(data['nodeId']);
}

HupuNbaMatchScorePlayer? _parseScorePlayer(
  Map<String, dynamic> json, {
  required int index,
}) {
  final node = _asMap(json['node']);
  final infoJson = _asMap(node['infoJson']);
  if (_firstString(infoJson['type']).isNotEmpty &&
      _firstString(infoJson['type']) != 'player') {
    return null;
  }

  final displayName = _stringValue(node['name']).isNotEmpty
      ? _stringValue(node['name'])
      : _firstString(infoJson['selfName']);
  final photo = _firstString(node['image']).isNotEmpty
      ? _firstString(node['image'])
      : _firstString(infoJson['cover_87x122']);
  final hotComment = _resolveHotComment(node);

  return HupuNbaMatchScorePlayer(
    teamId: _firstString(infoJson['teamId']),
    playerId: _firstString(infoJson['itemId']),
    name: displayName,
    photo: photo,
    minutes: _firstString(infoJson['minutes']),
    points: _intValue(_firstString(infoJson['pts'])),
    rebounds: _intValue(_firstString(infoJson['reb'])),
    assists: _intValue(_firstString(infoJson['ast'])),
    turnovers: _intValue(_firstString(infoJson['to'])),
    steals: _intValue(_firstString(infoJson['stl'])),
    blocks: _intValue(_firstString(infoJson['blk'])),
    plusMinus: _firstString(infoJson['plusMinus']),
    scoreBizId: _stringValue(node['bizId']),
    scoreAvg: _doubleValue(node['scoreAvg']),
    scorePersonCount: _intValue(node['summedScorePersonCount']),
    hotComment: hotComment,
    sort: _intValue(json['sort']) > 0 ? _intValue(json['sort']) : index,
    didNotPlay: _firstString(infoJson['desc']).contains('未上场'),
  );
}

List<HupuNbaMatchScorePlayer> _playersForTeam({
  required List<HupuNbaMatchScorePlayer> players,
  required String teamId,
}) {
  if (teamId.isEmpty) {
    return const <HupuNbaMatchScorePlayer>[];
  }
  return players
      .where((player) => player.teamId == teamId)
      .toList(growable: false);
}

String _resolveHotComment(Map<String, dynamic> node) {
  final hotCommentModels = node['hotCommentModels'];
  if (hotCommentModels is List && hotCommentModels.isNotEmpty) {
    final firstComment = _asMap(hotCommentModels.first);
    final content = _stringValue(firstComment['commentContent']);
    if (content.isNotEmpty) {
      return content;
    }
  }
  final hottestComments = node['hottestComments'];
  if (hottestComments is List && hottestComments.isNotEmpty) {
    return _stringValue(hottestComments.first);
  }
  return '';
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

String _countText(int count) {
  if (count >= 10000) {
    final value = count / 10000;
    return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}万';
  }
  return '$count';
}

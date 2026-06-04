class HupuNbaMatchStatsData {
  const HupuNbaMatchStatsData({
    required this.matchId,
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
  final String homeTeamId;
  final String awayTeamId;
  final String homeTeamName;
  final String awayTeamName;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final List<HupuNbaMatchStatsPlayer> homePlayers;
  final List<HupuNbaMatchStatsPlayer> awayPlayers;

  bool get hasItems => homePlayers.isNotEmpty || awayPlayers.isNotEmpty;

  List<HupuNbaMatchStatsTeam> get teams {
    return <HupuNbaMatchStatsTeam>[
      HupuNbaMatchStatsTeam(
        teamId: awayTeamId,
        teamName: awayTeamName,
        teamLogo: awayTeamLogo,
        players: awayPlayers,
      ),
      HupuNbaMatchStatsTeam(
        teamId: homeTeamId,
        teamName: homeTeamName,
        teamLogo: homeTeamLogo,
        players: homePlayers,
      ),
    ];
  }

  factory HupuNbaMatchStatsData.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    return HupuNbaMatchStatsData(
      matchId: _stringValue(result['matchId']),
      homeTeamId: _stringValue(result['homeTeamId']),
      awayTeamId: _stringValue(result['awayTeamId']),
      homeTeamName: _stringValue(result['homeTeamName']),
      awayTeamName: _stringValue(result['awayTeamName']),
      homeTeamLogo: _stringValue(result['homeTeamLogo']),
      awayTeamLogo: _stringValue(result['awayTeamLogo']),
      homePlayers: _parsePlayers(result['homePlayers']),
      awayPlayers: _parsePlayers(result['awayPlayers']),
    );
  }
}

class HupuNbaMatchStatsTeam {
  const HupuNbaMatchStatsTeam({
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.players,
  });

  final String teamId;
  final String teamName;
  final String teamLogo;
  final List<HupuNbaMatchStatsPlayer> players;
}

class HupuNbaMatchStatsPlayer {
  const HupuNbaMatchStatsPlayer({
    required this.teamId,
    required this.playerId,
    required this.name,
    required this.alias,
    required this.photo,
    required this.minutes,
    required this.points,
    required this.rebounds,
    required this.assists,
    required this.twoPoints,
    required this.threePoints,
    required this.freeThrows,
    required this.effectiveFieldGoalPercentage,
    required this.trueShootingPercentage,
    required this.turnovers,
    required this.steals,
    required this.blocks,
    required this.blocked,
    required this.offensiveRebounds,
    required this.defensiveRebounds,
    required this.foulsDrawn,
    required this.personalFouls,
    required this.plusMinus,
    required this.number,
    required this.position,
    required this.sort,
    required this.didNotPlay,
  });

  final String teamId;
  final String playerId;
  final String name;
  final String alias;
  final String photo;
  final String minutes;
  final int points;
  final int rebounds;
  final int assists;
  final String twoPoints;
  final String threePoints;
  final String freeThrows;
  final String effectiveFieldGoalPercentage;
  final String trueShootingPercentage;
  final int turnovers;
  final int steals;
  final int blocks;
  final int blocked;
  final int offensiveRebounds;
  final int defensiveRebounds;
  final int foulsDrawn;
  final int personalFouls;
  final String plusMinus;
  final String number;
  final String position;
  final int sort;
  final bool didNotPlay;

  bool get isTeamSummary => playerId.contains('-team-');

  String get displayName => alias.isNotEmpty ? alias : name;

  String get numberText => number.trim().isEmpty ? '--' : number.trim();

  String get positionText => position.trim().isEmpty ? '--' : position.trim();

  String statValue(String key) {
    switch (key) {
      case 'mins':
        return _displayString(minutes);
      case 'pts':
        return '$points';
      case 'reb':
        return '$rebounds';
      case 'asts':
        return '$assists';
      case 'twoPoints':
        return _displayString(twoPoints);
      case 'threePoints':
        return _displayString(threePoints);
      case 'ft':
        return _displayString(freeThrows);
      case 'efgp':
        return _displayString(effectiveFieldGoalPercentage);
      case 'tsp':
        return _displayString(trueShootingPercentage);
      case 'stl':
        return '$steals';
      case 'to':
        return '$turnovers';
      case 'blk':
        return '$blocks';
      case 'blkr':
        return '$blocked';
      case 'oreb':
        return '$offensiveRebounds';
      case 'dreb':
        return '$defensiveRebounds';
      case 'foulr':
        return '$foulsDrawn';
      case 'pf':
        return '$personalFouls';
      case 'plusMinus':
        return _displayString(plusMinus);
      default:
        return '--';
    }
  }

  factory HupuNbaMatchStatsPlayer.fromJson(Map<String, dynamic> json) {
    return HupuNbaMatchStatsPlayer(
      teamId: _stringValue(json['teamId']),
      playerId: _stringValue(json['playerId']),
      name: _stringValue(json['name']),
      alias: _stringValue(json['alias']),
      photo: _stringValue(json['photo'] ?? json['logoUrl']),
      minutes: _stringValue(json['mins']),
      points: _intValue(json['pts']),
      rebounds: _intValue(json['reb']),
      assists: _intValue(json['asts']),
      twoPoints: _stringValue(json['twoPoints']),
      threePoints: _stringValue(json['threePoints']),
      freeThrows: _stringValue(json['ft']),
      effectiveFieldGoalPercentage: _stringValue(json['efgp']),
      trueShootingPercentage: _stringValue(json['tsp']),
      turnovers: _intValue(json['to']),
      steals: _intValue(json['stl']),
      blocks: _intValue(json['blk']),
      blocked: _intValue(json['blkr']),
      offensiveRebounds: _intValue(json['oreb']),
      defensiveRebounds: _intValue(json['dreb']),
      foulsDrawn: _intValue(json['foulr']),
      personalFouls: _intValue(json['pf']),
      plusMinus: _stringValue(json['plusMinus']),
      number: _stringValue(json['number']),
      position: _stringValue(json['position']),
      sort: _intValue(json['sort']),
      didNotPlay: _intValue(json['dnp']) == 1,
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

List<HupuNbaMatchStatsPlayer> _parsePlayers(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuNbaMatchStatsPlayer>[];
  }
  final players = rawItems
      .whereType<Map>()
      .map(
        (item) => HupuNbaMatchStatsPlayer.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .where((item) => !item.isTeamSummary)
      .toList();
  players.sort((a, b) => a.sort.compareTo(b.sort));
  return players;
}

String _stringValue(dynamic value) => value?.toString() ?? '';

String _displayString(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed == 'null') {
    return '--';
  }
  return trimmed;
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

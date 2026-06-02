class HupuNbaDataTab {
  const HupuNbaDataTab({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
  });

  final String id;
  final String name;
  final String type;
  final String url;

  factory HupuNbaDataTab.fromJson(Map<String, dynamic> json) {
    return HupuNbaDataTab(
      id: _stringValue(json['id']),
      name: _stringValue(json['name']),
      type: _stringValue(json['type']),
      url: _stringValue(json['url']),
    );
  }
}

class HupuNbaScheduleData {
  const HupuNbaScheduleData({
    required this.stats,
    required this.days,
  });

  final HupuNbaScheduleStats stats;
  final List<HupuNbaScheduleDay> days;

  factory HupuNbaScheduleData.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    return HupuNbaScheduleData(
      stats: HupuNbaScheduleStats.fromJson(
        _asMap(result['scheduleListStats']),
      ),
      days: _parseScheduleDays(result['gameList']),
    );
  }
}

class HupuNbaScheduleStats {
  const HupuNbaScheduleStats({
    required this.earliestDate,
    required this.latestDate,
    required this.currentDate,
    required this.anchorMatchId,
  });

  final String earliestDate;
  final String latestDate;
  final String currentDate;
  final String anchorMatchId;

  factory HupuNbaScheduleStats.fromJson(Map<String, dynamic> json) {
    return HupuNbaScheduleStats(
      earliestDate: _stringValue(json['earliestDate']),
      latestDate: _stringValue(json['latestDate']),
      currentDate: _stringValue(json['currentDate']),
      anchorMatchId: _stringValue(json['anchorMatchId']),
    );
  }
}

class HupuNbaScheduleDay {
  const HupuNbaScheduleDay({
    required this.day,
    required this.dayBlock,
    required this.matches,
  });

  final String day;
  final String dayBlock;
  final List<HupuNbaScheduleMatch> matches;

  factory HupuNbaScheduleDay.fromJson(Map<String, dynamic> json) {
    return HupuNbaScheduleDay(
      day: _stringValue(json['day']),
      dayBlock: _stringValue(json['dayBlock']),
      matches: _parseScheduleMatches(json['matchList']),
    );
  }
}

class HupuNbaScheduleMatch {
  const HupuNbaScheduleMatch({
    required this.matchId,
    required this.matchStatus,
    required this.statusText,
    required this.stageText,
    required this.iconText,
    required this.scoreText,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.homeScore,
    required this.awayScore,
    required this.homeBigScore,
    required this.awayBigScore,
    required this.matchTime,
  });

  final String matchId;
  final String matchStatus;
  final String statusText;
  final String stageText;
  final String iconText;
  final String scoreText;
  final String homeTeamName;
  final String awayTeamName;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final int? homeScore;
  final int? awayScore;
  final int? homeBigScore;
  final int? awayBigScore;
  final String matchTime;

  bool get isCompleted => matchStatus == 'COMPLETED';

  String get timeText {
    if (matchStatus == 'CANCELLED') {
      return '取消';
    }
    if (matchTime.length >= 16) {
      return matchTime.substring(11, 16);
    }
    return statusText;
  }

  String get rightTitle => isCompleted ? '已结束' : '未开始';

  factory HupuNbaScheduleMatch.fromJson(Map<String, dynamic> json) {
    final status = _asMap(json['frontEndMatchStatus']);
    return HupuNbaScheduleMatch(
      matchId: _stringValue(json['matchId']),
      matchStatus: _stringValue(json['matchStatus']),
      statusText: _stringValue(status['desc']),
      stageText: _stringValue(json['competitionStageDesc']),
      iconText: _stringValue(json['iconText']),
      scoreText: _stringValue(json['score']),
      homeTeamName: _stringValue(json['homeTeamName']),
      awayTeamName: _stringValue(json['awayTeamName']),
      homeTeamLogo: _stringValue(json['homeTeamLogo']),
      awayTeamLogo: _stringValue(json['awayTeamLogo']),
      homeScore: _nullableInt(json['homeScore']),
      awayScore: _nullableInt(json['awayScore']),
      homeBigScore: _nullableInt(json['homeBigScore']),
      awayBigScore: _nullableInt(json['awayBigScore']),
      matchTime: _stringValue(json['matchTime']),
    );
  }
}

class HupuNbaPlayoffBracketData {
  const HupuNbaPlayoffBracketData({
    required this.items,
    required this.season,
  });

  final List<HupuNbaPlayoffMatchup> items;
  final String season;

  factory HupuNbaPlayoffBracketData.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    final rawItems = result['planChartItemList'];
    if (rawItems is! List) {
      return const HupuNbaPlayoffBracketData(
        items: <HupuNbaPlayoffMatchup>[],
        season: '',
      );
    }
    return HupuNbaPlayoffBracketData(
      season: _stringValue(result['season']),
      items: rawItems
          .whereType<Map>()
          .map(
            (item) => HupuNbaPlayoffMatchup.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
    );
  }
}

class HupuNbaPlayoffMatchup {
  const HupuNbaPlayoffMatchup({
    required this.planChartNumber,
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.oppoTeamId,
    required this.oppoTeamName,
    required this.oppoTeamLogo,
    required this.score,
    required this.oppoScore,
    required this.rank,
    required this.oppoRank,
    required this.winnerTeamId,
  });

  final String planChartNumber;
  final String teamId;
  final String teamName;
  final String teamLogo;
  final String oppoTeamId;
  final String oppoTeamName;
  final String oppoTeamLogo;
  final int score;
  final int oppoScore;
  final int rank;
  final int oppoRank;
  final String winnerTeamId;

  int get round => int.tryParse(planChartNumber.split('-').first) ?? 0;
  int get slot => int.tryParse(planChartNumber.split('-').last) ?? 0;
  bool get canOpenSeries {
    return teamId.isNotEmpty &&
        oppoTeamId.isNotEmpty &&
        (score > 0 || oppoScore > 0 || winnerTeamId.isNotEmpty);
  }

  String get teamIds => '$teamId,$oppoTeamId';
  bool hasTeam(String id) =>
      id.isNotEmpty && (teamId == id || oppoTeamId == id);

  factory HupuNbaPlayoffMatchup.fromJson(Map<String, dynamic> json) {
    return HupuNbaPlayoffMatchup(
      planChartNumber: _stringValue(json['planChartNumber']),
      teamId: _stringValue(json['teamId']),
      teamName: _stringValue(json['teamName']),
      teamLogo: _stringValue(json['teamLogo']),
      oppoTeamId: _stringValue(json['oppoTeamId']),
      oppoTeamName: _stringValue(json['oppoTeamName']),
      oppoTeamLogo: _stringValue(json['oppoTeamLogo']),
      score: _nullableInt(json['score']) ?? 0,
      oppoScore: _nullableInt(json['oppoScore']) ?? 0,
      rank: _nullableInt(json['rank']) ?? 0,
      oppoRank: _nullableInt(json['oppoRank']) ?? 0,
      winnerTeamId: _stringValue(json['winnerTeamId']),
    );
  }
}

class HupuNbaPlayoffSeriesMatch {
  const HupuNbaPlayoffSeriesMatch({
    required this.matchId,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.homeScore,
    required this.awayScore,
    required this.matchStatus,
    required this.matchStatusChinese,
    required this.matchTime,
    required this.scoreText,
  });

  final String matchId;
  final String homeTeamId;
  final String awayTeamId;
  final String homeTeamName;
  final String awayTeamName;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final int? homeScore;
  final int? awayScore;
  final String matchStatus;
  final String matchStatusChinese;
  final String matchTime;
  final String scoreText;

  String get dateText {
    if (matchTime.length < 10) {
      return '';
    }
    final month = int.tryParse(matchTime.substring(5, 7))?.toString() ?? '';
    final day = int.tryParse(matchTime.substring(8, 10))?.toString() ?? '';
    if (month.isEmpty || day.isEmpty) {
      return '';
    }
    return '$month/$day';
  }

  String get displayStatus {
    return matchStatusChinese.isNotEmpty ? matchStatusChinese : matchStatus;
  }

  bool get homeWon {
    final home = homeScore;
    final away = awayScore;
    return home != null && away != null && home > away;
  }

  bool get awayWon {
    final home = homeScore;
    final away = awayScore;
    return home != null && away != null && away > home;
  }

  factory HupuNbaPlayoffSeriesMatch.fromJson(Map<String, dynamic> json) {
    return HupuNbaPlayoffSeriesMatch(
      matchId: _stringValue(json['matchId']),
      homeTeamId: _stringValue(json['homeTeamId']),
      awayTeamId: _stringValue(json['awayTeamId']),
      homeTeamName: _stringValue(json['homeTeamName']),
      awayTeamName: _stringValue(json['awayTeamName']),
      homeTeamLogo: _stringValue(json['homeTeamLogo']),
      awayTeamLogo: _stringValue(json['awayTeamLogo']),
      homeScore: _nullableInt(json['homeScore']),
      awayScore: _nullableInt(json['awayScore']),
      matchStatus: _stringValue(json['matchStatus']),
      matchStatusChinese: _stringValue(json['matchStatusChinese']),
      matchTime: _stringValue(json['matchTime']),
      scoreText: _stringValue(json['score']),
    );
  }
}

class HupuNbaRankSeasonData {
  const HupuNbaRankSeasonData({required this.seasons});

  final List<HupuNbaRankSeason> seasons;

  HupuNbaRankSeason get selected {
    return seasons.firstWhere(
      (item) => item.select,
      orElse: () => seasons.first,
    );
  }

  factory HupuNbaRankSeasonData.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    final rawItems = result['seasonData'];
    if (rawItems is! List) {
      return const HupuNbaRankSeasonData(seasons: <HupuNbaRankSeason>[]);
    }
    return HupuNbaRankSeasonData(
      seasons: rawItems
          .whereType<Map>()
          .map(
            (item) =>
                HupuNbaRankSeason.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
    );
  }
}

class HupuNbaRankSeason {
  const HupuNbaRankSeason({
    required this.season,
    required this.shortSeason,
    required this.seasonType,
    required this.seasonTypeName,
    required this.select,
  });

  final String season;
  final String shortSeason;
  final String seasonType;
  final String seasonTypeName;
  final bool select;

  String get displayName => '$shortSeason$seasonTypeName';

  factory HupuNbaRankSeason.fromJson(Map<String, dynamic> json) {
    return HupuNbaRankSeason(
      season: _stringValue(json['season']),
      shortSeason: _stringValue(json['shortSeason']),
      seasonType: _stringValue(json['seasonType']),
      seasonTypeName: _stringValue(json['seasonTypeName']),
      select: json['select'] == true,
    );
  }
}

class HupuNbaPlayerRankData {
  const HupuNbaPlayerRankData({required this.dimensions});

  final List<HupuNbaRankDimension> dimensions;

  factory HupuNbaPlayerRankData.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    final rawItems = result['dimensionList'];
    if (rawItems is! List) {
      return const HupuNbaPlayerRankData(dimensions: <HupuNbaRankDimension>[]);
    }
    return HupuNbaPlayerRankData(
      dimensions: rawItems
          .whereType<Map>()
          .map(
            (item) =>
                HupuNbaRankDimension.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
    );
  }
}

class HupuNbaRankDimension {
  const HupuNbaRankDimension({
    required this.engName,
    required this.chineseName,
    required this.items,
  });

  final String engName;
  final String chineseName;
  final List<HupuNbaRankItem> items;

  factory HupuNbaRankDimension.fromJson(Map<String, dynamic> json) {
    final rawItems = json['itemList'];
    return HupuNbaRankDimension(
      engName: _stringValue(json['engName']),
      chineseName: _stringValue(json['chineseName']),
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    HupuNbaRankItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
          : const <HupuNbaRankItem>[],
    );
  }
}

class HupuNbaRankItem {
  const HupuNbaRankItem({
    required this.engName,
    required this.chineseName,
    required this.players,
    required this.hasMore,
    required this.allUrl,
  });

  final String engName;
  final String chineseName;
  final List<HupuNbaRankPlayer> players;
  final bool hasMore;
  final String allUrl;

  factory HupuNbaRankItem.fromJson(Map<String, dynamic> json) {
    final rawItems = json['rankInfoList'];
    return HupuNbaRankItem(
      engName: _stringValue(json['engName']),
      chineseName: _stringValue(json['chineseName']),
      players: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map(
                (item) => HupuNbaRankPlayer.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
          : const <HupuNbaRankPlayer>[],
      hasMore: json['hasMore'] == true,
      allUrl: _stringValue(json['allUrl']),
    );
  }
}

class HupuNbaRankPlayer {
  const HupuNbaRankPlayer({
    required this.rank,
    required this.playerName,
    required this.photo,
    required this.value,
    required this.teamShortName,
    required this.pts,
    required this.reb,
    required this.ast,
  });

  final int rank;
  final String playerName;
  final String photo;
  final String value;
  final String teamShortName;
  final String pts;
  final String reb;
  final String ast;

  String get statSummary => '$pts分 $reb板 $ast助';

  factory HupuNbaRankPlayer.fromJson(Map<String, dynamic> json) {
    return HupuNbaRankPlayer(
      rank: _nullableInt(json['rank']) ?? 0,
      playerName: _stringValue(json['playerName']),
      photo: _stringValue(json['photo']),
      value: _stringValue(json['value']),
      teamShortName: _stringValue(json['teamShortName'] ?? json['teamName']),
      pts: _stringValue(json['pts']),
      reb: _stringValue(json['reb']),
      ast: _stringValue(json['ast']),
    );
  }
}

class HupuNbaTeamStandingData {
  const HupuNbaTeamStandingData({
    required this.season,
    required this.competitionStageType,
    required this.eastRows,
    required this.westRows,
    required this.divisionGroups,
  });

  final String season;
  final String competitionStageType;
  final List<HupuNbaTeamStandingRow> eastRows;
  final List<HupuNbaTeamStandingRow> westRows;
  final List<HupuNbaTeamStandingDivisionGroup> divisionGroups;

  factory HupuNbaTeamStandingData.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    final rankTypeListMap = _asMap(result['rankTypeListMap']);
    final divRankTypeListMap = _asMap(result['divRankTypeListMap']);
    final seasonStageType = _asMap(result['competitionSeasonStageType']);
    final seasonType = _asMap(seasonStageType['competitionSeasonType']);

    return HupuNbaTeamStandingData(
      season: _stringValue(seasonType['season']),
      competitionStageType: _stringValue(
        seasonStageType['competitionStageTypeName'],
      ),
      eastRows: _parseTeamStandingRows(rankTypeListMap['E']),
      westRows: _parseTeamStandingRows(rankTypeListMap['W']),
      divisionGroups: divRankTypeListMap.entries
          .map(
            (entry) => HupuNbaTeamStandingDivisionGroup(
              key: entry.key,
              title: _resolveDivisionTitle(entry.value),
              rows: _parseTeamStandingRows(entry.value),
            ),
          )
          .where((group) => group.rows.isNotEmpty)
          .toList(growable: false),
    );
  }
}

class HupuNbaTeamStandingDivisionGroup {
  const HupuNbaTeamStandingDivisionGroup({
    required this.key,
    required this.title,
    required this.rows,
  });

  final String key;
  final String title;
  final List<HupuNbaTeamStandingRow> rows;
}

class HupuNbaTeamStandingRow {
  const HupuNbaTeamStandingRow({
    required this.rank,
    required this.teamName,
    required this.teamShortName,
    required this.logoLink,
    required this.won,
    required this.lost,
    required this.winRate,
    required this.gb,
    required this.strk,
    required this.confWins,
    required this.confLosses,
    required this.divWins,
    required this.divLosses,
  });

  final int rank;
  final String teamName;
  final String teamShortName;
  final String logoLink;
  final int won;
  final int lost;
  final String winRate;
  final String gb;
  final String strk;
  final int confWins;
  final int confLosses;
  final int divWins;
  final int divLosses;

  String get wl => '$won-$lost';
  String get confWl => '$confWins-$confLosses';
  String get divWl => '$divWins-$divLosses';
  String get streakText {
    final value = strk.trim();
    if (value.isEmpty || value == '0') {
      return '--';
    }
    if (value.startsWith('-')) {
      return '${value.substring(1)}连败';
    }
    return '$value连胜';
  }

  factory HupuNbaTeamStandingRow.fromJson(Map<String, dynamic> json) {
    return HupuNbaTeamStandingRow(
      rank: _nullableInt(json['rank']) ?? 0,
      teamName: _stringValue(json['teamName']),
      teamShortName: _stringValue(json['teamShortName'] ?? json['teamName']),
      logoLink: _stringValue(json['logoLink']),
      won: _nullableInt(json['won']) ?? 0,
      lost: _nullableInt(json['lost']) ?? 0,
      winRate: _stringValue(json['winRate']),
      gb: _stringValue(json['gb']),
      strk: _stringValue(json['strk']),
      confWins: _nullableInt(json['confWins']) ?? 0,
      confLosses: _nullableInt(json['confLosses']) ?? 0,
      divWins: _nullableInt(json['divWins']) ?? 0,
      divLosses: _nullableInt(json['divLosses']) ?? 0,
    );
  }
}

class HupuNbaTeamRankData {
  const HupuNbaTeamRankData({required this.categories});

  final List<HupuNbaTeamRankCategory> categories;

  factory HupuNbaTeamRankData.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    if (result is! List) {
      return const HupuNbaTeamRankData(categories: <HupuNbaTeamRankCategory>[]);
    }
    return HupuNbaTeamRankData(
      categories: result
          .whereType<Map>()
          .map(
            (item) => HupuNbaTeamRankCategory.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((item) => item.rows.isNotEmpty)
          .toList(growable: false),
    );
  }
}

class HupuNbaTeamRankCategory {
  const HupuNbaTeamRankCategory({
    required this.name,
    required this.rankType,
    required this.rows,
  });

  final String name;
  final String rankType;
  final List<HupuNbaTeamRankRow> rows;

  factory HupuNbaTeamRankCategory.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return HupuNbaTeamRankCategory(
      name: _stringValue(json['name']),
      rankType: _stringValue(json['rankType']),
      rows: data is List
          ? data
              .whereType<Map>()
              .map(
                (item) => HupuNbaTeamRankRow.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
          : const <HupuNbaTeamRankRow>[],
    );
  }
}

class HupuNbaTeamRankRow {
  const HupuNbaTeamRankRow({
    required this.rank,
    required this.teamName,
    required this.teamShortName,
    required this.logoUrl,
    required this.value,
  });

  final int rank;
  final String teamName;
  final String teamShortName;
  final String logoUrl;
  final String value;

  factory HupuNbaTeamRankRow.fromJson(Map<String, dynamic> json) {
    return HupuNbaTeamRankRow(
      rank: _nullableInt(json['rank']) ?? 0,
      teamName: _stringValue(json['teamName']),
      teamShortName: _stringValue(json['teamShortName'] ?? json['teamName']),
      logoUrl: _stringValue(json['logoUrl']),
      value: _stringValue(json['value']),
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

int? _nullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}

List<HupuNbaScheduleDay> _parseScheduleDays(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuNbaScheduleDay>[];
  }
  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuNbaScheduleDay.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .where((item) => item.day.isNotEmpty)
      .toList(growable: false);
}

List<HupuNbaScheduleMatch> _parseScheduleMatches(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuNbaScheduleMatch>[];
  }
  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuNbaScheduleMatch.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList(growable: false);
}

List<HupuNbaTeamStandingRow> _parseTeamStandingRows(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuNbaTeamStandingRow>[];
  }
  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuNbaTeamStandingRow.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList(growable: false);
}

String _resolveDivisionTitle(dynamic rawItems) {
  if (rawItems is! List) {
    return '';
  }
  for (final item in rawItems) {
    if (item is Map) {
      final title = _stringValue(item['rankTypeDesc']);
      if (title.isNotEmpty) {
        return title;
      }
    }
  }
  return '';
}

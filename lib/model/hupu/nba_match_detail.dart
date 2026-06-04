class HupuNbaMatchDetail {
  const HupuNbaMatchDetail({
    required this.matchId,
    required this.matchStatus,
    required this.matchStatusChinese,
    required this.statusText,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.homeScore,
    required this.awayScore,
    required this.homeRank,
    required this.awayRank,
    required this.homeArea,
    required this.awayArea,
    required this.homeFouls,
    required this.awayFouls,
    required this.homeSurplusPause,
    required this.awaySurplusPause,
    required this.competitionStageDesc,
    required this.currentQuarter,
    required this.costTime,
    required this.sectionEndTime,
    required this.homeBigScore,
    required this.awayBigScore,
    required this.scoreBizId,
  });

  final String matchId;
  final String matchStatus;
  final String matchStatusChinese;
  final String statusText;
  final String homeTeamName;
  final String awayTeamName;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final int? homeScore;
  final int? awayScore;
  final int? homeRank;
  final int? awayRank;
  final String homeArea;
  final String awayArea;
  final int? homeFouls;
  final int? awayFouls;
  final int? homeSurplusPause;
  final int? awaySurplusPause;
  final String competitionStageDesc;
  final int? currentQuarter;
  final String costTime;
  final String sectionEndTime;
  final int homeBigScore;
  final int awayBigScore;
  final String scoreBizId;

  String get displayStatusText {
    if (statusText.isNotEmpty) {
      return statusText;
    }
    if (matchStatusChinese.isNotEmpty) {
      return matchStatusChinese;
    }
    return matchStatus;
  }

  String get displayQuarterText {
    final statusQuarter = _statusParts.first;
    if (statusQuarter.isNotEmpty) {
      return statusQuarter;
    }
    final quarter = currentQuarter;
    if (quarter != null && quarter > 0) {
      return '第$quarter节';
    }
    return displayStatusText;
  }

  String get displayClockText {
    if (costTime.isNotEmpty) {
      return costTime;
    }
    final statusClock = _statusParts.second;
    if (statusClock.isNotEmpty) {
      return statusClock;
    }
    if (sectionEndTime.isNotEmpty && matchStatus == 'INPROGRESS') {
      return '节间休息';
    }
    return matchStatusChinese;
  }

  String get awayRankText => _formatRank(awayRank);

  String get homeRankText => _formatRank(homeRank);

  String get bigScoreText {
    if (homeBigScore <= 0 && awayBigScore <= 0) {
      return '';
    }
    return '$awayBigScore - $homeBigScore';
  }

  _StatusParts get _statusParts {
    final value = statusText.trim();
    if (value.isEmpty) {
      return const _StatusParts('', '');
    }
    final parts = value.split(RegExp(r'\s+'));
    if (parts.length <= 1) {
      return _StatusParts(value, '');
    }
    return _StatusParts(parts.first, parts.skip(1).join(' '));
  }

  factory HupuNbaMatchDetail.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    final status = _asMap(result['frontEndMatchStatus']);
    return HupuNbaMatchDetail(
      matchId: _stringValue(result['matchId']),
      matchStatus: _stringValue(result['matchStatus']),
      matchStatusChinese: _stringValue(result['matchStatusChinese']),
      statusText: _stringValue(status['desc']),
      homeTeamName: _stringValue(result['homeTeamName']),
      awayTeamName: _stringValue(result['awayTeamName']),
      homeTeamLogo: _stringValue(result['homeTeamLogo']),
      awayTeamLogo: _stringValue(result['awayTeamLogo']),
      homeScore: _nullableInt(result['homeScore']),
      awayScore: _nullableInt(result['awayScore']),
      homeRank: _nullableInt(result['homeRank']),
      awayRank: _nullableInt(result['awayRank']),
      homeArea: _stringValue(result['homeArea']),
      awayArea: _stringValue(result['awayArea']),
      homeFouls: _nullableInt(result['homeFouls']),
      awayFouls: _nullableInt(result['awayFouls']),
      homeSurplusPause: _nullableInt(result['homeSurplusPause']),
      awaySurplusPause: _nullableInt(result['awaySurplusPause']),
      competitionStageDesc: _stringValue(result['competitionStageDesc']),
      currentQuarter: _nullableInt(result['currentQuarter']),
      costTime: _stringValue(result['costTime']),
      sectionEndTime: _stringValue(result['sectionEndTime']),
      homeBigScore: _nullableInt(result['homeBigScore']) ?? 0,
      awayBigScore: _nullableInt(result['awayBigScore']) ?? 0,
      scoreBizId: _resolveScoreBizId(result),
    );
  }
}

class _StatusParts {
  const _StatusParts(this.first, this.second);

  final String first;
  final String second;
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

String _resolveScoreBizId(Map<String, dynamic> result) {
  for (final key in const <String>[
    'scoreBizId',
    'scoreId',
    'scoreNumber',
    'selfBizId',
    'outBizNo',
  ]) {
    final value = _stringValue(result[key]);
    if (value.isNotEmpty && value != 'null') {
      return value;
    }
  }
  final score = _asMap(result['score']);
  for (final key in const <String>[
    'scoreBizId',
    'scoreId',
    'scoreNumber',
    'selfBizId',
    'outBizNo',
  ]) {
    final value = _stringValue(score[key]);
    if (value.isNotEmpty && value != 'null') {
      return value;
    }
  }
  return '';
}

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

String _formatRank(int? rank) {
  if (rank == null || rank <= 0) {
    return '';
  }
  return '[$rank]';
}

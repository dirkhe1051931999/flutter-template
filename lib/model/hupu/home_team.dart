class HupuAttentionTeamListData {
  const HupuAttentionTeamListData({
    required this.teams,
    required this.showRedDot,
    required this.teamIcon,
  });

  final List<HupuAttentionTeam> teams;
  final bool showRedDot;
  final String teamIcon;

  factory HupuAttentionTeamListData.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    return HupuAttentionTeamListData(
      teams: _parseAttentionTeams(result['teamDTOList']),
      showRedDot: result['showRedDot'] == true,
      teamIcon: _stringValue(result['teamIcon']),
    );
  }
}

class HupuAttentionTeam {
  const HupuAttentionTeam({
    required this.teamId,
    required this.teamName,
    required this.tagName,
    required this.teamIcon,
    required this.topicId,
    required this.topicName,
    required this.latestNewsId,
  });

  final String teamId;
  final String teamName;
  final String tagName;
  final String teamIcon;
  final int topicId;
  final String topicName;
  final String latestNewsId;

  factory HupuAttentionTeam.fromJson(Map<String, dynamic> json) {
    final threadInfo = _asMap(json['threadInfo']);
    final extraMap = _asMap(json['extraMap']);
    return HupuAttentionTeam(
      teamId: _stringValue(json['teamId']),
      teamName: _stringValue(json['teamName']),
      tagName: _stringValue(json['tagName']),
      teamIcon: _stringValue(json['teamIcon']),
      topicId: _intValue(threadInfo['topicId']),
      topicName: _stringValue(threadInfo['topicName']),
      latestNewsId: _stringValue(extraMap['latestNewsId']),
    );
  }
}

class HupuHomeTeamTab {
  const HupuHomeTeamTab({
    required this.key,
    required this.name,
    required this.url,
    required this.showTab,
  });

  final String key;
  final String name;
  final String url;
  final bool showTab;

  factory HupuHomeTeamTab.fromJson(Map<String, dynamic> json) {
    return HupuHomeTeamTab(
      key: _stringValue(json['key']),
      name: _stringValue(json['name']),
      url: _stringValue(json['url']),
      showTab: json['showTab'] == true,
    );
  }
}

class HupuHomeTeamNewsPage {
  const HupuHomeTeamNewsPage({required this.items});

  final List<HupuHomeTeamNewsItem> items;

  String get nextNewsId {
    if (items.isEmpty) {
      return '0';
    }
    return items.last.nid;
  }

  factory HupuHomeTeamNewsPage.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    if (result is List) {
      return HupuHomeTeamNewsPage(items: _parseHomeTeamNewsItems(result));
    }
    final resultMap = _asMap(result);
    return HupuHomeTeamNewsPage(items: _parseHomeTeamNewsItems(resultMap['data']));
  }
}

class HupuHomeTeamNewsItem {
  const HupuHomeTeamNewsItem({
    required this.nid,
    required this.tid,
    required this.title,
    required this.imageUrl,
    required this.replies,
    required this.lights,
    required this.link,
    required this.publishTime,
  });

  final String nid;
  final String tid;
  final String title;
  final String imageUrl;
  final int replies;
  final int lights;
  final String link;
  final String publishTime;

  String get replySummary => '$replies 回复 / $lights 亮回复';

  factory HupuHomeTeamNewsItem.fromJson(Map<String, dynamic> json) {
    return HupuHomeTeamNewsItem(
      nid: _stringValue(json['nid']),
      tid: _stringValue(json['tid']),
      title: _stringValue(json['title']),
      imageUrl: _stringValue(json['img']),
      replies: _intValue(json['replies']),
      lights: _intValue(json['lights']),
      link: _stringValue(json['link']),
      publishTime: _stringValue(json['publishTime']),
    );
  }
}

class HupuHomeTeamTopicThreadPage {
  const HupuHomeTeamTopicThreadPage({
    required this.items,
    required this.hasNextPage,
    required this.cursor,
    required this.stamp,
  });

  final List<HupuHomeTeamTopicThread> items;
  final bool hasNextPage;
  final String cursor;
  final int stamp;

  factory HupuHomeTeamTopicThreadPage.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    return HupuHomeTeamTopicThreadPage(
      items: _parseHomeTeamTopicThreads(data['list']),
      hasNextPage: data['next_page'] == true || data['nextPage'] == true,
      cursor: _stringValue(data['cursor']),
      stamp: _intValue(data['stamp']),
    );
  }
}

class HupuHomeTeamTopicThread {
  const HupuHomeTeamTopicThread({
    required this.tid,
    required this.title,
    required this.userName,
    required this.timeText,
    required this.replies,
    required this.lightReplies,
    required this.imageUrl,
  });

  final String tid;
  final String title;
  final String userName;
  final String timeText;
  final int replies;
  final int lightReplies;
  final String imageUrl;

  factory HupuHomeTeamTopicThread.fromJson(Map<String, dynamic> json) {
    return HupuHomeTeamTopicThread(
      tid: _stringValue(json['tid']),
      title: _stringValue(json['title']),
      userName: _stringValue(json['user_name']),
      timeText: _stringValue(json['time']),
      replies: _intValue(json['replys']),
      lightReplies: _intValue(json['light_replys']),
      imageUrl: _resolveThreadImage(json),
    );
  }
}

class HupuHomeTeamScheduleData {
  const HupuHomeTeamScheduleData({
    required this.stats,
    required this.days,
  });

  final HupuHomeTeamScheduleStats stats;
  final List<HupuHomeTeamScheduleDay> days;

  factory HupuHomeTeamScheduleData.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    final payload = _asMap(result['data']).isNotEmpty
        ? _asMap(result['data'])
        : _asMap(result['scheduleData']).isNotEmpty
            ? _asMap(result['scheduleData'])
            : result;
    return HupuHomeTeamScheduleData(
      stats: HupuHomeTeamScheduleStats.fromJson(
        _asMap(
          payload['scheduleListStats'].toString().isNotEmpty
              ? payload['scheduleListStats']
              : payload['stats'],
        ),
      ),
      days: _parseHomeTeamScheduleDays(
        payload['dayGameData'] ??
            payload['gameList'] ??
            payload['dayList'] ??
            payload['list'] ??
            payload['scheduleList'] ??
            payload['matchDayList'] ??
            payload['data'],
      ),
    );
  }
}

class HupuHomeTeamScheduleStats {
  const HupuHomeTeamScheduleStats({
    required this.earliestDate,
    required this.latestDate,
    required this.currentDate,
    required this.anchorMatchId,
  });

  final String earliestDate;
  final String latestDate;
  final String currentDate;
  final String anchorMatchId;

  factory HupuHomeTeamScheduleStats.fromJson(Map<String, dynamic> json) {
    return HupuHomeTeamScheduleStats(
      earliestDate: _stringValue(json['earliestDate']),
      latestDate: _stringValue(json['latestDate']),
      currentDate: _stringValue(json['currentDate']),
      anchorMatchId: _stringValue(json['anchorMatchId']),
    );
  }
}

class HupuHomeTeamScheduleDay {
  const HupuHomeTeamScheduleDay({
    required this.day,
    required this.dayBlock,
    required this.matches,
  });

  final String day;
  final String dayBlock;
  final List<HupuHomeTeamScheduleMatch> matches;

  factory HupuHomeTeamScheduleDay.fromJson(Map<String, dynamic> json) {
    final dayRaw = _stringValue(json['day']);
    final dayTime = _stringValue(json['dayTime']);
    final dateText = _stringValue(json['dateText']);
    final dateValue = _stringValue(json['date']);
    final matchDate = _stringValue(json['matchDate']);
    final gameDate = _stringValue(json['gameDate']);
    final dayBlockRaw = _stringValue(json['dayBlock']);
    final day = dayRaw.isNotEmpty
        ? dayRaw
        : dayTime.isNotEmpty
            ? dayTime
            : dateValue.isNotEmpty
                ? dateValue
                : matchDate.isNotEmpty
                    ? matchDate
                    : gameDate.isNotEmpty
                        ? gameDate
                        : dateText;
    return HupuHomeTeamScheduleDay(
      day: day,
      dayBlock: dayBlockRaw.isNotEmpty
          ? dayBlockRaw
          : dateText.isNotEmpty
              ? dateText
              : day,
      matches: _parseHomeTeamScheduleMatches(
        json['matchData'] ??
            json['matchList'] ??
            json['gameList'] ??
            json['list'] ??
            json['matchInfoList'] ??
            json['data'],
      ),
    );
  }
}

class HupuHomeTeamScheduleMatch {
  const HupuHomeTeamScheduleMatch({
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

  factory HupuHomeTeamScheduleMatch.fromJson(Map<String, dynamic> json) {
    final status = _asMap(json['frontEndMatchStatus']);
    final homeTeam = _asMap(json['homeTeam']);
    final awayTeam = _asMap(json['awayTeam']);
    final againstInfo = _asMap(json['againstInfo']);
    final memberInfos = _mapList(againstInfo['memberInfos']);
    final firstMember = memberInfos.isNotEmpty ? memberInfos.first : const <String, dynamic>{};
    final secondMember =
        memberInfos.length > 1 ? memberInfos[1] : const <String, dynamic>{};
    final fallbackHomeTeam = _resolveHomeTeamMap(
      json: json,
      againstInfo: againstInfo,
      firstMember: firstMember,
      secondMember: secondMember,
    );
    final fallbackAwayTeam = _resolveAwayTeamMap(
      json: json,
      againstInfo: againstInfo,
      firstMember: firstMember,
      secondMember: secondMember,
    );
    final normalizedStatusText = _stringValue(status['desc']).isNotEmpty
        ? _stringValue(status['desc'])
        : _stringValue(json['matchStatusDesc']);
    return HupuHomeTeamScheduleMatch(
      matchId: _stringValue(json['matchId']),
      matchStatus: _stringValue(json['matchStatus']),
      statusText: normalizedStatusText,
      stageText: _stringValue(json['competitionStageDesc']).isNotEmpty
          ? _stringValue(json['competitionStageDesc'])
          : _stringValue(json['matchIntroduction']).isNotEmpty
              ? _stringValue(json['matchIntroduction'])
              : _stringValue(json['matchName']),
      iconText: _stringValue(json['iconText']),
      scoreText: _stringValue(json['score']).isNotEmpty
          ? _stringValue(json['score'])
          : _stringValue(json['scoreCountText']),
      homeTeamName: _stringValue(json['homeTeamName']).isNotEmpty
          ? _stringValue(json['homeTeamName'])
          : _stringValue(homeTeam['name']).isNotEmpty
              ? _stringValue(homeTeam['name'])
              : _stringValue(fallbackHomeTeam['memberName']),
      awayTeamName: _stringValue(json['awayTeamName']).isNotEmpty
          ? _stringValue(json['awayTeamName'])
          : _stringValue(awayTeam['name']).isNotEmpty
              ? _stringValue(awayTeam['name'])
              : _stringValue(fallbackAwayTeam['memberName']),
      homeTeamLogo: _stringValue(json['homeTeamLogo']).isNotEmpty
          ? _stringValue(json['homeTeamLogo'])
          : _stringValue(homeTeam['logo']).isNotEmpty
              ? _stringValue(homeTeam['logo'])
              : _stringValue(fallbackHomeTeam['memberLogo']),
      awayTeamLogo: _stringValue(json['awayTeamLogo']).isNotEmpty
          ? _stringValue(json['awayTeamLogo'])
          : _stringValue(awayTeam['logo']).isNotEmpty
              ? _stringValue(awayTeam['logo'])
              : _stringValue(fallbackAwayTeam['memberLogo']),
      homeScore: _nullableInt(json['homeScore']) ??
          _nullableInt(fallbackHomeTeam['memberBaseScore']),
      awayScore: _nullableInt(json['awayScore']) ??
          _nullableInt(fallbackAwayTeam['memberBaseScore']),
      homeBigScore: _nullableInt(json['homeBigScore']) ??
          _nullableInt(fallbackHomeTeam['memberBigScore']),
      awayBigScore: _nullableInt(json['awayBigScore']) ??
          _nullableInt(fallbackAwayTeam['memberBigScore']),
      matchTime: _stringValue(json['matchTime']).isNotEmpty
          ? _stringValue(json['matchTime'])
          : _stringValue(json['matchStartDate']),
    );
  }
}

class HupuHomeTeamPlayerData {
  const HupuHomeTeamPlayerData({
    required this.teamInfo,
    required this.staff,
    required this.players,
    required this.statColumns,
  });

  final HupuHomeTeamPlayerTeamInfo teamInfo;
  final List<HupuHomeTeamStaffMember> staff;
  final List<HupuHomeTeamPlayer> players;
  final List<HupuHomeTeamPlayerStatColumn> statColumns;

  factory HupuHomeTeamPlayerData.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    final payload = _asMap(result['data']).isNotEmpty
        ? _asMap(result['data'])
        : _asMap(result['teamPlayers']).isNotEmpty
            ? _asMap(result['teamPlayers'])
            : result;
    return HupuHomeTeamPlayerData(
      teamInfo: HupuHomeTeamPlayerTeamInfo.fromJson(_asMap(payload['info'])),
      staff: _parseHomeTeamStaffMembers(
        payload['offical'] ?? payload['official'] ?? payload['staff'],
      ),
      players: _parseHomeTeamPlayers(
        payload['list'] ?? payload['playerList'] ?? payload['data'],
      ),
      statColumns: HupuHomeTeamPlayerStatColumn.fromGlossary(
        payload['players_stats_glossary'],
      ),
    );
  }
}

class HupuHomeTeamPlayerTeamInfo {
  const HupuHomeTeamPlayerTeamInfo({
    required this.teamId,
    required this.name,
    required this.fullName,
    required this.logoUrl,
    required this.arena,
  });

  final String teamId;
  final String name;
  final String fullName;
  final String logoUrl;
  final String arena;

  factory HupuHomeTeamPlayerTeamInfo.fromJson(Map<String, dynamic> json) {
    return HupuHomeTeamPlayerTeamInfo(
      teamId: _stringValue(json['teamId']),
      name: _stringValue(json['name']),
      fullName: _stringValue(json['full_name']),
      logoUrl: _stringValue(json['logo_link']),
      arena: _stringValue(json['arena']),
    );
  }
}

class HupuHomeTeamStaffMember {
  const HupuHomeTeamStaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.photo,
  });

  final String id;
  final String name;
  final String role;
  final String photo;

  factory HupuHomeTeamStaffMember.fromJson(Map<String, dynamic> json) {
    return HupuHomeTeamStaffMember(
      id: _stringValue(json['id']),
      name: _stringValue(json['name']),
      role: _stringValue(json['category_name']).isNotEmpty
          ? _stringValue(json['category_name'])
          : _stringValue(json['role']),
      photo: _stringValue(json['photo']),
    );
  }
}

class HupuHomeTeamPlayerStatColumn {
  const HupuHomeTeamPlayerStatColumn({
    required this.key,
    required this.label,
  });

  final String key;
  final String label;

  static List<HupuHomeTeamPlayerStatColumn> fromGlossary(dynamic rawGlossary) {
    if (rawGlossary is! List || rawGlossary.length < 2) {
      return const <HupuHomeTeamPlayerStatColumn>[];
    }
    final rawKeys = rawGlossary[0];
    final rawLabels = rawGlossary[1];
    if (rawKeys is! List || rawLabels is! List) {
      return const <HupuHomeTeamPlayerStatColumn>[];
    }
    final length = rawKeys.length < rawLabels.length ? rawKeys.length : rawLabels.length;
    return List<HupuHomeTeamPlayerStatColumn>.generate(length, (index) {
      return HupuHomeTeamPlayerStatColumn(
        key: rawKeys[index].toString().trim(),
        label: rawLabels[index].toString().trim(),
      );
    }, growable: false);
  }
}

class HupuHomeTeamPlayer {
  const HupuHomeTeamPlayer({
    required this.playerId,
    required this.playerName,
    required this.number,
    required this.position,
    required this.avatar,
    required this.height,
    required this.weight,
    required this.age,
    required this.nationality,
    required this.birthday,
    required this.teamName,
    required this.salary,
    required this.salaryText,
    required this.isInjured,
    required this.stats,
  });

  final String playerId;
  final String playerName;
  final String number;
  final String position;
  final String avatar;
  final String height;
  final String weight;
  final String age;
  final String nationality;
  final String birthday;
  final String teamName;
  final String salary;
  final String salaryText;
  final bool isInjured;
  final Map<String, String> stats;

  String statValue(String key) {
    final normalizedKey = key.trim();
    final value = stats[normalizedKey]?.trim() ?? '';
    if (value.isNotEmpty) {
      return value;
    }
    return '--';
  }

  String get profileSummary {
    final values = <String>[
      if (position.isNotEmpty) position,
      if (height.isNotEmpty) '身高$height',
      if (weight.isNotEmpty) '体重$weight',
      if (age.isNotEmpty) '$age岁',
    ];
    return values.join(' · ');
  }

  factory HupuHomeTeamPlayer.fromJson(Map<String, dynamic> json) {
    return HupuHomeTeamPlayer(
      playerId: _stringValue(json['playerId']).isNotEmpty
          ? _stringValue(json['playerId'])
          : _stringValue(json['player_id']).isNotEmpty
              ? _stringValue(json['player_id'])
          : _stringValue(json['id']).isNotEmpty
              ? _stringValue(json['id'])
              : _stringValue(json['personId']),
      playerName: _stringValue(json['playerName']).isNotEmpty
          ? _stringValue(json['playerName'])
          : _stringValue(json['player_name']).isNotEmpty
              ? _stringValue(json['player_name'])
          : _stringValue(json['name']).isNotEmpty
              ? _stringValue(json['name'])
              : _stringValue(json['nameCn']).isNotEmpty
                  ? _stringValue(json['nameCn'])
                  : _stringValue(json['fullName']),
      number: _stringValue(json['jerseyNumber']).isNotEmpty
          ? _stringValue(json['jerseyNumber'])
          : _stringValue(json['number']).isNotEmpty
              ? _stringValue(json['number'])
              : _stringValue(json['shirtNumber']),
      position: _stringValue(json['position']).isNotEmpty
          ? _stringValue(json['position'])
          : _stringValue(json['positionName']).isNotEmpty
              ? _stringValue(json['positionName'])
              : _stringValue(json['pos']),
      avatar: _stringValue(json['photo']).isNotEmpty
          ? _stringValue(json['photo'])
          : _stringValue(json['player_header']).isNotEmpty
              ? _stringValue(json['player_header'])
          : _stringValue(json['player_header_big']).isNotEmpty
              ? _stringValue(json['player_header_big'])
          : _stringValue(json['playerLogo']).isNotEmpty
              ? _stringValue(json['playerLogo'])
              : _stringValue(json['avatar']).isNotEmpty
                  ? _stringValue(json['avatar'])
                  : _stringValue(json['head']).isNotEmpty
                      ? _stringValue(json['head'])
                      : _stringValue(json['headUrl']),
      height: _stringValue(json['height']).isNotEmpty
          ? _stringValue(json['height'])
          : _stringValue(json['heightCm']),
      weight: _stringValue(json['weight']).isNotEmpty
          ? _stringValue(json['weight'])
          : _stringValue(json['weightKg']),
      age: _stringValue(json['age']),
      nationality: _stringValue(json['nationality']).isNotEmpty
          ? _stringValue(json['nationality'])
          : _stringValue(json['country']).isNotEmpty
              ? _stringValue(json['country'])
              : _stringValue(json['nation']),
      birthday: _stringValue(json['birthday']).isNotEmpty
          ? _stringValue(json['birthday'])
          : _stringValue(json['birthDay']).isNotEmpty
              ? _stringValue(json['birthDay'])
              : _stringValue(json['birthDate']),
      teamName: _stringValue(json['teamName']),
      salary: _stringValue(json['salary']),
      salaryText: _stringValue(json['salary_str']),
      isInjured: _intValue(json['is_injured']) == 1,
      stats: _parsePlayerStats(json),
    );
  }
}

String _resolveThreadImage(Map<String, dynamic> json) {
  final cover = _stringValue(json['cover']);
  if (cover.isNotEmpty) {
    return cover;
  }
  final imgs = json['imgs'];
  if (imgs is List && imgs.isNotEmpty) {
    final first = imgs.first;
    if (first is Map) {
      return _stringValue(first['url']);
    }
    return _stringValue(first);
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

int _intValue(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
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

List<HupuAttentionTeam> _parseAttentionTeams(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuAttentionTeam>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => HupuAttentionTeam.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.teamId.isNotEmpty)
      .toList(growable: false);
}

List<HupuHomeTeamNewsItem> _parseHomeTeamNewsItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuHomeTeamNewsItem>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => HupuHomeTeamNewsItem.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.nid.isNotEmpty)
      .toList(growable: false);
}

List<HupuHomeTeamTopicThread> _parseHomeTeamTopicThreads(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuHomeTeamTopicThread>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => HupuHomeTeamTopicThread.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.tid.isNotEmpty)
      .toList(growable: false);
}

List<HupuHomeTeamScheduleDay> _parseHomeTeamScheduleDays(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuHomeTeamScheduleDay>[];
  }
  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuHomeTeamScheduleDay.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .where((item) => item.day.isNotEmpty || item.dayBlock.isNotEmpty)
      .toList(growable: false);
}

List<Map<String, dynamic>> _mapList(dynamic rawItems) {
  if (rawItems is! List) {
    return const <Map<String, dynamic>>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Map<String, dynamic> _resolveHomeTeamMap({
  required Map<String, dynamic> json,
  required Map<String, dynamic> againstInfo,
  required Map<String, dynamic> firstMember,
  required Map<String, dynamic> secondMember,
}) {
  final winnerMemberId = _stringValue(againstInfo['winnerMemberId']);
  final homeTeamName = _stringValue(json['homeTeamName']);
  if (homeTeamName.isNotEmpty) {
    return firstMember;
  }
  if (_stringValue(firstMember['memberName']).isEmpty) {
    return secondMember;
  }
  if (_stringValue(secondMember['memberName']).isEmpty) {
    return firstMember;
  }
  if (winnerMemberId.isNotEmpty &&
      winnerMemberId == _stringValue(firstMember['memberId']) &&
      _stringValue(json['matchStatus']) == 'COMPLETED') {
    return firstMember;
  }
  return firstMember;
}

Map<String, dynamic> _resolveAwayTeamMap({
  required Map<String, dynamic> json,
  required Map<String, dynamic> againstInfo,
  required Map<String, dynamic> firstMember,
  required Map<String, dynamic> secondMember,
}) {
  final homeTeam = _resolveHomeTeamMap(
    json: json,
    againstInfo: againstInfo,
    firstMember: firstMember,
    secondMember: secondMember,
  );
  if (identical(homeTeam, firstMember)) {
    return secondMember;
  }
  return firstMember;
}

List<HupuHomeTeamScheduleMatch> _parseHomeTeamScheduleMatches(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuHomeTeamScheduleMatch>[];
  }
  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuHomeTeamScheduleMatch.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList(growable: false);
}

List<HupuHomeTeamPlayer> _parseHomeTeamPlayers(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuHomeTeamPlayer>[];
  }
  final players = rawItems
      .whereType<Map>()
      .map((item) => HupuHomeTeamPlayer.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.playerName.isNotEmpty || item.playerId.isNotEmpty)
      .toList(growable: true);
  players.sort((left, right) {
    final rightPoints = _doubleValue(right.stats['pts']);
    final leftPoints = _doubleValue(left.stats['pts']);
    return rightPoints.compareTo(leftPoints);
  });
  return players;
}

List<HupuHomeTeamStaffMember> _parseHomeTeamStaffMembers(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuHomeTeamStaffMember>[];
  }
  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuHomeTeamStaffMember.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .where((item) => item.name.isNotEmpty)
      .toList(growable: false);
}

Map<String, String> _parsePlayerStats(Map<String, dynamic> json) {
  const keys = <String>[
    'game_played_start',
    'min',
    'pts',
    'reb',
    'asts',
    'fgp',
    'tpp',
    'ftp',
    'oreb',
    'dreb',
    'stl',
    'to',
    'blk',
    'pf',
  ];
  final result = <String, String>{};
  for (final key in keys) {
    result[key] = _stringValue(json[key]);
  }
  return result;
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

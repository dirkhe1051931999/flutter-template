import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

enum HupuNbaScheduleDirection {
  prev('prev'),
  next('next');

  const HupuNbaScheduleDirection(this.value);

  final String value;
}

Future<List<HupuNbaDataTab>> getHupuNbaDataTabs() async {
  final queryParameters = createHupuCommonQueryParameters(
    crt: DateTime.now().millisecondsSinceEpoch.toString(),
  )..addAll(const <String, String>{
      'tabType': 'nba',
    });

  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/v2/dataTabList',
    queryParameters: queryParameters,
  );
  final result = decoded['result'];
  if (result is! List) {
    return const <HupuNbaDataTab>[];
  }
  return result
      .whereType<Map>()
      .map((item) => HupuNbaDataTab.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

Future<HupuNbaScheduleData> getHupuNbaScheduleList({
  String cursor = '',
  HupuNbaScheduleDirection? direction,
}) async {
  final queryParameters = createHupuCommonQueryParameters(
    crt: DateTime.now().millisecondsSinceEpoch.toString(),
  )..addAll(const <String, String>{
      'competitionTag': 'nba',
    });
  if (cursor.isNotEmpty && direction != null) {
    queryParameters['cursor'] = cursor;
    queryParameters['direc'] = direction.value;
  }

  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/scheduleList',
    queryParameters: queryParameters,
  );
  return HupuNbaScheduleData.fromJson(decoded);
}

Future<HupuNbaMatchDetail> getHupuNbaMatchDetail({
  required String matchId,
}) async {
  final queryParameters = createHupuCommonQueryParameters(
    crt: DateTime.now().millisecondsSinceEpoch.toString(),
  )..addAll(<String, String>{
      'matchId': matchId,
    });

  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/singleMatch',
    queryParameters: queryParameters,
  );
  return HupuNbaMatchDetail.fromJson(decoded);
}

Future<HupuNbaMatchLiveData> getHupuNbaMatchLiveData({
  required String matchId,
}) async {
  final queryParameters = createHupuCommonQueryParameters(
    crt: DateTime.now().millisecondsSinceEpoch.toString(),
  )..addAll(<String, String>{
      'matchId': matchId,
    });

  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/teamMatchScoreTrendStats',
    queryParameters: queryParameters,
  );
  return HupuNbaMatchLiveData.fromJson(decoded);
}

Future<HupuNbaPlayoffBracketData> getHupuNbaPlayoffBracket() async {
  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/against-plan-chart',
    queryParameters: const <String, String>{
      'offline': 'json',
      'planChartType': 'NBA_PLAYOFF',
      'client': '74e7c34827bddcf2',
    },
    shouldSign: false,
  );
  return HupuNbaPlayoffBracketData.fromJson(decoded);
}

Future<List<HupuNbaPlayoffSeriesMatch>> getHupuNbaPlayoffSeriesMatches({
  required String teamIds,
  required String season,
}) async {
  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/against-plan-match',
    queryParameters: <String, String>{
      'offline': 'json',
      'teamIds': teamIds,
      'season': season,
      'planChartType': 'NBA_PLAYOFF',
      'client': '74e7c34827bddcf2',
    },
    shouldSign: false,
  );
  final result = decoded['result'];
  if (result is! List) {
    return const <HupuNbaPlayoffSeriesMatch>[];
  }
  return result
      .whereType<Map>()
      .map(
        (item) => HupuNbaPlayoffSeriesMatch.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList(growable: false);
}

Future<HupuNbaRankSeasonData> getHupuNbaRankSeasons() async {
  final decoded = await _getGamesJson(
    '/1/undefined/basketballapi/switchableRankSeasonList',
    queryParameters: const <String, String>{
      'offline': 'json',
      'clientId': '106819853',
      'rankType': 'NBA_PLAYER_RANK',
    },
    shouldSign: false,
  );
  return HupuNbaRankSeasonData.fromJson(decoded);
}

Future<HupuNbaPlayerRankData> getHupuNbaPlayerRank({
  required String season,
  required String competitionStageType,
}) async {
  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/playerSeasonRank',
    queryParameters: <String, String>{
      'offline': 'json',
      'competitionLeagueType': 'nba',
      'competitionType': 'nba',
      'season': season,
      'competitionStageType': competitionStageType,
      'client': '74e7c34827bddcf2',
    },
    shouldSign: false,
  );
  return HupuNbaPlayerRankData.fromJson(decoded);
}

Future<HupuNbaRankItem> getHupuNbaSingleDimensionPlayerRank({
  required String rankType,
  required String season,
  required String competitionStageType,
  int pageNo = 1,
}) async {
  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/playerSingleDimensionSeasonRank',
    queryParameters: <String, String>{
      'night': '0',
      'rankType': rankType,
      'competitionLeagueType': 'NBA',
      'competitionType': 'NBA',
      'season': season,
      'playerType': 'normal',
      'competitionStageType': competitionStageType,
      'pageNo': '$pageNo',
    },
    shouldSign: false,
  );
  final result = decoded['result'];
  if (result is! Map) {
    return const HupuNbaRankItem(
      engName: '',
      chineseName: '',
      players: <HupuNbaRankPlayer>[],
      hasMore: false,
      allUrl: '',
    );
  }
  return HupuNbaRankItem.fromJson(Map<String, dynamic>.from(result));
}

Future<HupuNbaTeamStandingData> getHupuNbaTeamStandingList({
  required String season,
  required String competitionStageType,
}) async {
  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/teamStandingList',
    queryParameters: <String, String>{
      'offline': 'json',
      'competitionLeagueType': 'nba',
      'competitionType': 'nba',
      'season': season,
      'competitionStageType': competitionStageType,
      'client': 'bc9e1ef8570ddf7e',
    },
    shouldSign: false,
  );
  return HupuNbaTeamStandingData.fromJson(decoded);
}

Future<HupuNbaTeamRankData> getHupuNbaTeamSeasonRank({
  required String season,
  required String competitionStageType,
}) async {
  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/teamSeasonRank',
    queryParameters: <String, String>{
      'offline': 'json',
      'competitionLeagueType': 'nba',
      'competitionType': 'nba',
      'season': season,
      'competitionStageType': competitionStageType,
      'client': 'bc9e1ef8570ddf7e',
    },
    shouldSign: false,
  );
  return HupuNbaTeamRankData.fromJson(decoded);
}

Future<Map<String, dynamic>> _getGamesJson(
  String path, {
  required Map<String, String> queryParameters,
  bool shouldSign = true,
}) async {
  final signedQuery = Map<String, String>.from(queryParameters);
  if (shouldSign) {
    signedQuery['sign'] = buildHupuSign(signedQuery);
  }
  final response = await hupuGamesClient.get(
    path,
    queryParameters: signedQuery,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );
  return decodeHupuJson(response.data);
}

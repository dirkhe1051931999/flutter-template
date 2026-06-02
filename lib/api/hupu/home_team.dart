import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

const String _nbaLeagueType = 'nba';
const String _basketballCategoryCode = 'basketball';

enum HupuHomeTeamScheduleDirection {
  prev('prev'),
  next('next');

  const HupuHomeTeamScheduleDirection(this.value);

  final String value;
}

Future<HupuAttentionTeamListData> getHupuAttentionTeamList({
  String leagueType = _nbaLeagueType,
}) async {
  final queryParameters = _createBasketballQueryParameters()
    ..addAll(<String, String>{
      'leagueType': leagueType,
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/news/v2/attentionTeamList',
    queryParameters: queryParameters,
  );
  return HupuAttentionTeamListData.fromJson(decoded);
}

Future<List<HupuHomeTeamTab>> getHupuHomeTeamTabs({
  required String teamId,
}) async {
  final queryParameters = _createBasketballQueryParameters()
    ..addAll(<String, String>{
      'teamId': teamId,
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/teamTabList',
    queryParameters: queryParameters,
  );
  final result = decoded['result'];
  if (result is! List) {
    return const <HupuHomeTeamTab>[];
  }
  return result
      .whereType<Map>()
      .map((item) => HupuHomeTeamTab.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

Future<HupuHomeTeamNewsPage> getHupuHomeTeamNewsPage({
  required String teamId,
  String newsId = '0',
}) async {
  final queryParameters = _createBasketballQueryParameters()
    ..addAll(<String, String>{
      'cateGoryCode': _basketballCategoryCode,
      'newsId': newsId,
      'teamId': teamId,
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getGamesJson(
    '/3/7.5.60/basketballapi/news/v2/teamNewsById',
    queryParameters: queryParameters,
  );
  return HupuHomeTeamNewsPage.fromJson(decoded);
}

Future<HupuHomeTeamTopicThreadPage> getHupuHomeTeamTopicThreads({
  required int topicId,
  int page = 1,
  int stamp = 0,
  int width = 518,
  int tabType = 2,
}) async {
  final queryParameters = <String, String>{
    'topic_id': '$topicId',
    'tab_type': '$tabType',
    'page': '$page',
    'stamp': '$stamp',
    'width': '$width',
    ...createHupuCommonQueryParameters(
      crt: '${DateTime.now().millisecondsSinceEpoch}',
    ),
  };
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuBbsClient.get(
    '/1/8.0.32/topics/getTopicThreads',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuHomeTeamTopicThreadPage.fromJson(decodeHupuJson(response.data));
}

Future<HupuHomeTeamScheduleData> getHupuHomeTeamScheduleList({
  required String teamId,
  String cursor = '',
  HupuHomeTeamScheduleDirection? direction,
}) async {
  final queryParameters = <String, String>{
    'businessType': 'team',
    'businessId': teamId,
    'datasource': 'basketball',
  };
  if (cursor.isNotEmpty && direction != null) {
    queryParameters['cursor'] = cursor;
    queryParameters['direc'] = direction.value;
  }

  final decoded = await _getMatchApiJson(
    '/1/8.2.10/matchallapi/bff/standard/getScheduleListByTagForH5',
    queryParameters: queryParameters,
  );
  return HupuHomeTeamScheduleData.fromJson(decoded);
}

Future<HupuHomeTeamPlayerData> getHupuHomeTeamPlayerData({
  required String teamId,
}) async {
  final queryParameters = _createBasketballPlayerQueryParameters()
    ..addAll(<String, String>{
      'teamId': teamId,
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getGamesJson(
    '/3/7.5.60/basketballapi/teamPlayerList',
    queryParameters: queryParameters,
  );
  return HupuHomeTeamPlayerData.fromJson(decoded);
}

Map<String, String> _createBasketballQueryParameters() {
  return createHupuCommonQueryParameters(
    crt: DateTime.now().millisecondsSinceEpoch.toString(),
  );
}

Map<String, String> _createBasketballPlayerQueryParameters() {
  return createHupuPlayerQueryParameters(
    crt: DateTime.now().millisecondsSinceEpoch.toString(),
  );
}

Future<Map<String, dynamic>> _getGamesJson(
  String path, {
  required Map<String, String> queryParameters,
}) async {
  final response = await hupuGamesClient.get(
    path,
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );
  return decodeHupuJson(response.data);
}

Future<Map<String, dynamic>> _getMatchApiJson(
  String path, {
  required Map<String, String> queryParameters,
}) async {
  final response = await hupuGamesClient.get(
    'https://match-api.hupu.com$path',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );
  return decodeHupuJson(response.data);
}

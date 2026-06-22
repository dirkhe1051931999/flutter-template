import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<HupuSportsNewsPage> getHupuSportsNewsPage({
  required String categoryCode,
  required String tagCode,
  String newsId = '',
  int preCount = 0,
}) async {
  final queryParameters = _createSportsQueryParameters()
    ..addAll(<String, String>{
      'cateGoryCode': categoryCode,
      'newsId': newsId,
      'tagCode': tagCode,
      'preCount': '$preCount',
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getGamesJson(
    '/1/8.0.37/basketballapi/news/v2/newsList',
    queryParameters: queryParameters,
  );
  return HupuSportsNewsPage.fromJson(decoded);
}

Future<HupuSportsHotNewsData> getHupuSportsHotNews({
  required String categoryCode,
  required String tagCode,
  int page = 1,
  int size = 30,
}) async {
  final queryParameters = _createSportsQueryParameters()
    ..addAll(<String, String>{
      'cateGoryCode': categoryCode,
      'tagCode': tagCode,
      'size': '$size',
      'page': '$page',
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getGamesJson(
    '/1/8.0.37/basketballapi/news/v2/hotList',
    queryParameters: queryParameters,
  );
  return HupuSportsHotNewsData.fromJson(decoded);
}

Future<List<HupuCompetitionTopic>> getHupuCompetitionTopicList({
  required String code,
}) async {
  final queryParameters = _createSportsQueryParameters()
    ..addAll(<String, String>{
      'code': code,
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getGamesJson(
    '/1/8.0.37/bbsallapi/competition/getCompetitionTopicList',
    queryParameters: queryParameters,
  );
  return parseHupuCompetitionTopics(decoded);
}

Map<String, String> _createSportsQueryParameters() {
  return createHupuCommonQueryParameters(
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
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );
  return decodeHupuJson(response.data);
}

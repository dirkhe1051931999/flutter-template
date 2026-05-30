import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

const String _basketballCategoryCode = 'basketball';
const String _nbaTagCode = 'nba';

Future<HupuNbaTopTabData> getHupuNbaTopTabData() async {
  final responses = await Future.wait([
    getHupuNbaShortcuts(),
    getHupuNbaRecommendedMatch(),
    getHupuNbaHotNews(),
    getHupuNbaNewsPage(),
  ]);

  final shortcuts = responses[0] as List<HupuNbaShortcut>;
  final recommendedMatch = responses[1] as HupuNbaRecommendedMatch?;
  final hotNews = responses[2] as HupuNbaHotNewsData;
  final news = responses[3] as HupuNbaNewsPage;

  return HupuNbaTopTabData(
    shortcuts: shortcuts,
    recommendedMatch: recommendedMatch,
    hotNews: hotNews.items,
    news: news.items,
    topNewsCount: news.topNewsCount,
  );
}

Future<List<HupuNbaShortcut>> getHupuNbaShortcuts() async {
  final queryParameters = _createBasketballQueryParameters()
    ..addAll(const <String, String>{
      'cateGoryCode': _basketballCategoryCode,
      'tagCode': _nbaTagCode,
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/news/v3/tab',
    queryParameters: queryParameters,
  );
  final result = decoded['result'];
  if (result is! List) {
    return const <HupuNbaShortcut>[];
  }
  return result
      .whereType<Map>()
      .map((item) => HupuNbaShortcut.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

Future<HupuNbaRecommendedMatch?> getHupuNbaRecommendedMatch() async {
  final now = DateTime.now();
  final queryParameters = _createBasketballQueryParameters()
    ..addAll(<String, String>{
      'experimentPlan': '3',
      'leagueType': _nbaTagCode,
      'competitionTag': _nbaTagCode,
      'experimentCode': 'BBallHome',
      'recommendDate': _formatCompactDate(now),
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/recommendMatch',
    queryParameters: queryParameters,
  );
  final matchList = decoded['matchList'];
  if (matchList is! List || matchList.isEmpty) {
    return null;
  }
  return HupuNbaRecommendedMatch.fromJson(decoded);
}

Future<HupuNbaHotNewsData> getHupuNbaHotNews({
  int page = 1,
  int size = 30,
}) async {
  final queryParameters = _createBasketballQueryParameters()
    ..addAll(<String, String>{
      'cateGoryCode': _basketballCategoryCode,
      'tagCode': _nbaTagCode,
      'size': '$size',
      'page': '$page',
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/news/v2/hotList',
    queryParameters: queryParameters,
  );
  return HupuNbaHotNewsData.fromJson(decoded);
}

Future<HupuNbaNewsPage> getHupuNbaNewsPage({
  String newsId = '',
  int preCount = 0,
}) async {
  final queryParameters = _createBasketballQueryParameters()
    ..addAll(<String, String>{
      'cateGoryCode': _basketballCategoryCode,
      'newsId': newsId,
      'tagCode': _nbaTagCode,
      'preCount': '$preCount',
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getGamesJson(
    '/1/8.0.32/basketballapi/news/v2/newsList',
    queryParameters: queryParameters,
  );
  return HupuNbaNewsPage.fromJson(decoded);
}

Map<String, String> _createBasketballQueryParameters() {
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

String _formatCompactDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}$month$day';
}

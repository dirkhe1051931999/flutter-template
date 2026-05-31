import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<HupuHotTagPage> getHupuHotTags({
  int page = 1,
  int pageSize = 30,
}) async {
  final queryParameters = <String, String>{
    'page': '$page',
    'pageSize': '$pageSize',
    ...createHupuCommonQueryParameters(crt: '${DateTime.now().millisecondsSinceEpoch}'),
  };
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuGamesClient.get(
    '/1/8.0.32/bbsallapi/tag/v1/heatTag',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  final decoded = decodeHupuJson(response.data);
  return HupuHotTagPage.fromJson(decoded);
}

Future<List<HupuHotRankCategory>> getHupuHotRankCategories() async {
  final queryParameters = <String, String>{
    ...createHupuCommonQueryParameters(crt: '${DateTime.now().millisecondsSinceEpoch}'),
  };
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuGamesClient.get(
    '/1/8.0.32/hot/category',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  final decoded = decodeHupuJson(response.data);
  final rawData = decoded['data'];
  return parseHotRankCategories(rawData);
}

Future<HupuHotRankResponse> getHupuHotRankList({
  required int categoryId,
}) async {
  final queryParameters = <String, String>{
    'category': '$categoryId',
    'cid': '174865444',
    ...createHupuCommonQueryParameters(crt: '${DateTime.now().millisecondsSinceEpoch}'),
  };
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuGamesClient.get(
    '/1/8.0.32/hotRank/',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  final decoded = decodeHupuJson(response.data);
  return HupuHotRankResponse.fromJson(decoded);
}

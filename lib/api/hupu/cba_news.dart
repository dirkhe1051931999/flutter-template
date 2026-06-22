import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

const String _basketballCategoryCode = 'basketball';
const String _cbaTagCode = 'cba';

Future<HupuCbaNewsPage> getHupuCbaNewsPage({
  String newsId = '',
  int preCount = 0,
}) async {
  final queryParameters = _createBasketballQueryParameters()
    ..addAll(<String, String>{
      'cateGoryCode': _basketballCategoryCode,
      'newsId': newsId,
      'tagCode': _cbaTagCode,
      'preCount': '$preCount',
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getGamesJson(
    '/1/8.0.37/basketballapi/news/v2/newsList',
    queryParameters: queryParameters,
  );
  return HupuCbaNewsPage.fromJson(decoded);
}

Future<HupuCbaHotNewsData> getHupuCbaHotNews({
  int page = 1,
  int size = 30,
}) async {
  final queryParameters = _createBasketballQueryParameters()
    ..addAll(<String, String>{
      'cateGoryCode': _basketballCategoryCode,
      'tagCode': _cbaTagCode,
      'size': '$size',
      'page': '$page',
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getGamesJson(
    '/1/8.0.37/basketballapi/news/v2/hotList',
    queryParameters: queryParameters,
  );
  return HupuCbaHotNewsData.fromJson(decoded);
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

import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<HupuHotListResponse> getHupuForumFeed({
  required String forumName,
  required bool isFirst,
  required bool isRefresh,
}) async {
  final queryParameters = <String, String>{
    'is_first': isFirst ? '1' : '0',
    'is_refresh': isRefresh ? '1' : '0',
    'deviceRegisterTime': '',
    'ab_items': '1',
    'puid': '0',
    'personalized': '1',
    'name': forumName,
    ...createHupuCommonQueryParameters(
      crt: '${DateTime.now().millisecondsSinceEpoch}',
    ),
  };
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuGamesClient.get(
    '/1/8.0.32/forum/index',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuHotListResponse.fromJson(decodeHupuJson(response.data));
}

import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<HupuTagDetail> getHupuTagDetail({
  required int tagId,
}) async {
  final queryParameters = <String, String>{
    'tagId': '$tagId',
    ...createHupuCommonQueryParameters(
      crt: '${DateTime.now().millisecondsSinceEpoch}',
    ),
  };
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuBbsClient.get(
    '/1/8.0.32/bbsallapi/tag/v1/tagInfo',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuTagDetail.fromJson(decodeHupuJson(response.data));
}

Future<HupuTagThreadPage> getHupuTagThreadList({
  required int tagId,
  required int tabType,
  required int page,
  String lastCursor = '',
}) async {
  final queryParameters = <String, String>{
    'tagId': '$tagId',
    'tabType': '$tabType',
    'page': '$page',
    'lastCursor': lastCursor,
    ...createHupuCommonQueryParameters(
      crt: '${DateTime.now().millisecondsSinceEpoch}',
    ),
  };
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuBbsClient.get(
    '/1/8.0.32/bbsallapi/tag/v1/getTagThreadList',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuTagThreadPage.fromJson(decodeHupuJson(response.data));
}

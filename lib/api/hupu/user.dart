import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<HupuUserProfile> getHupuUserProfile({
  required String puid,
}) async {
  final formData = <String, String>{
    ...createHupuCommonQueryParameters(
      crt: DateTime.now().millisecondsSinceEpoch.toString(),
    ),
    'puid': puid,
  };
  formData['sign'] = buildHupuSign(formData);

  final response = await hupuGamesClient.postFormData(
    '/1/8.0.32/bplapi/user/v1/page',
    data: formData,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuUserProfile.fromJson(decodeHupuJson(response.data));
}

Future<HupuUserThreadPage> getHupuUserThreads({
  required String puid,
  required int page,
  int pageSize = 10,
}) async {
  final queryParameters = <String, String>{
    ...createHupuCommonQueryParameters(
      crt: DateTime.now().millisecondsSinceEpoch.toString(),
    ),
    'puid': puid,
    'page': '$page',
    'pageSize': '$pageSize',
  };
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuBbsClient.get(
    '/1/8.0.32/bbsthreadapi/v2/queryThreadByPuid',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuUserThreadPage.fromJson(decodeHupuJson(response.data));
}

Future<HupuUserReplyPage> getHupuUserReplies({
  required String puid,
  required int maxTime,
  int pageSize = 10,
}) async {
  final queryParameters = <String, String>{
    ...createHupuCommonQueryParameters(
      crt: DateTime.now().millisecondsSinceEpoch.toString(),
    ),
    'puid': puid,
    'maxTime': '$maxTime',
    'pageSize': '$pageSize',
  };
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuBbsClient.get(
    '/1/8.0.32/bbsreplyapi/reply/v1/getUserReplyRecord',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuUserReplyPage.fromJson(decodeHupuJson(response.data));
}

Future<HupuUserThreadPage> getHupuUserRecommendations({
  required String puid,
  required int page,
  int pageSize = 10,
}) async {
  final queryParameters = <String, String>{
    ...createHupuCommonQueryParameters(
      crt: DateTime.now().millisecondsSinceEpoch.toString(),
    ),
    'puid': puid,
    'page': '$page',
    'pageSize': '$pageSize',
  };
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuBbsClient.get(
    '/1/8.0.32/bbsthreadapi/v1/getUserR7dThreads',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuUserThreadPage.fromJson(decodeHupuJson(response.data));
}

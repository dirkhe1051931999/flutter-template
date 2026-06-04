import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<HupuTopicCategoryResponse> getHupuTopicCategories() async {
  final queryParameters = createHupuCommonQueryParameters(
    crt: DateTime.now().millisecondsSinceEpoch.toString(),
  )..addAll(<String, String>{
      'all': '1',
      'tV2': '1',
    });

  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getBbsJson(
    '/1/8.0.32/topics',
    queryParameters: queryParameters,
  );
  return HupuTopicCategoryResponse.fromJson(decoded);
}

Future<HupuTopicAdminResponse> getHupuTopicAdmins({
  required int topicId,
}) async {
  final queryParameters = createHupuCommonQueryParameters(
    crt: DateTime.now().millisecondsSinceEpoch.toString(),
  )..addAll(<String, String>{
      'topicId': '$topicId',
    });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getBbsJson(
    '/1/8.0.32/bbsadmin/v1/data/listAdmins',
    queryParameters: queryParameters,
  );
  return HupuTopicAdminResponse.fromJson(decoded);
}

Future<HupuTopicDetailResponse> getHupuTopicDetail({
  required int topicId,
}) async {
  final queryParameters = createHupuCommonQueryParameters(
    crt: DateTime.now().millisecondsSinceEpoch.toString(),
  );
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getBbsJson(
    '/1/8.0.32/topics/$topicId',
    queryParameters: queryParameters,
  );
  return HupuTopicDetailResponse.fromJson(decoded);
}

Future<HupuTopicThreadPage> getHupuTopicThreads({
  required int topicId,
  required int tabType,
  int page = 1,
  int stamp = 0,
  int width = 518,
  int? zoneId,
}) async {
  final queryParameters = createHupuCommonQueryParameters(
    crt: DateTime.now().millisecondsSinceEpoch.toString(),
  )..addAll(<String, String>{
      'topic_id': '$topicId',
      'tab_type': '$tabType',
      'page': '$page',
      'stamp': '$stamp',
      'width': '$width',
    });
  if (zoneId != null && zoneId > 0) {
    queryParameters['zoneId'] = '$zoneId';
  }
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final decoded = await _getBbsJson(
    '/1/8.0.32/topics/getTopicThreads',
    queryParameters: queryParameters,
  );
  return HupuTopicThreadPage.fromJson(decoded);
}

Future<Map<String, dynamic>> _getBbsJson(
  String path, {
  required Map<String, String> queryParameters,
}) async {
  final response = await hupuBbsClient.get(
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

import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/follow.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<HupuFollowContent> getHupuFollowContent({
  required int pageIndex,
  required String lastViewTime,
}) async {
  final crt = DateTime.now().millisecondsSinceEpoch.toString();
  final queryParameters = <String, String>{
    'lastViewTime': lastViewTime,
    'pageIndex': pageIndex.toString(),
    ...createHupuCommonQueryParameters(crt: crt),
  };
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuBbsClient.get(
    '/1/8.0.37/bbsallapi/follow/v1/content',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const {'Accept': 'application/json'},
    ),
  );
  return HupuFollowContent.fromJson(decodeHupuJson(response.data));
}

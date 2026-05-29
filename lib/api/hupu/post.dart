import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<HupuPostDetail> getHupuPostDetail({
  required String tid,
}) async {
  final queryParameters = createHupuCommonQueryParameters(crt: '1780023256979');
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuBbsClient.get(
    '/1/8.0.32/threads/$tid',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  final decoded = decodeHupuJson(response.data);
  return HupuPostDetail.fromJson(decoded);
}

Future<HupuPostCommentResponse> getHupuPostLightReplies({
  required String tid,
  required String fid,
  required int topicId,
}) async {
  final queryParameters = createHupuCommonQueryParameters(crt: '1780023257763');
  queryParameters.addAll(<String, String>{
    'tid': tid,
    'fid': fid,
    'topicId': '$topicId',
    'order': 'asc',
  });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuBbsClient.get(
    '/1/8.0.32/threads/getsThreadLightReplyList',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  final decoded = decodeHupuJson(response.data);
  return HupuPostCommentResponse.fromJson(
    decoded,
    isLightReplies: true,
  );
}

Future<HupuPostCommentResponse> getHupuPostComments({
  required String tid,
  required String fid,
  required int page,
}) async {
  final queryParameters = createHupuCommonQueryParameters(crt: '1780023257814');
  queryParameters.addAll(<String, String>{
    'tid': tid,
    'fid': fid,
    'page': '$page',
    'sort': '0',
    'order': 'asc',
  });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuBbsClient.get(
    '/1/8.0.32/threads/getsThreadPostList',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  final decoded = decodeHupuJson(response.data);
  return HupuPostCommentResponse.fromJson(
    decoded,
    isLightReplies: false,
    currentPage: page,
  );
}

Future<HupuCheckReplyResponse> getHupuPostCheckReplies({
  required String tid,
  required String fid,
  required String pid,
  String order = 'light',
  int type = 1,
}) async {
  final queryParameters = createHupuCommonQueryParameters(
    crt: DateTime.now().millisecondsSinceEpoch.toString(),
  );
  queryParameters.addAll(<String, String>{
    'tid': tid,
    'fid': fid,
    'pid': pid,
    'order': order,
    'type': '$type',
  });
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuBbsClient.get(
    '/1/8.0.32/threads/getCheckReply',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  final decoded = decodeHupuJson(response.data);
  return HupuCheckReplyResponse.fromJson(decoded);
}

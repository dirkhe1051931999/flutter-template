import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<HupuNbaMatchScoreDetail> getHupuNbaMatchScoreDetail({
  required String scoreBizId,
}) async {
  final decoded = await _getScoreDetailJson(
    '/1/8.0.32/bplcommentapi/bpl/score_tree/getSelfByBizKey',
    queryParameters: <String, String>{
      'outBizNo': scoreBizId,
      'outBizType': 'basketball_item',
    },
  );
  return HupuNbaMatchScoreDetail.fromJson(decoded);
}

Future<HupuNbaMatchScoreCommentPage> getHupuNbaMatchScoreHotComments({
  required String scoreBizId,
}) async {
  final decoded = await _getScoreDetailJson(
    '/1/8.0.32/bplcommentapi/bpl/comment/list/primarySingleRow/hottest',
    queryParameters: <String, String>{
      'outBizNo': scoreBizId,
      'outBizType': 'basketball_item',
      'clientCode': 'bc9e1ef8570ddf7e',
      'cid': '174865444',
    },
  );
  return HupuNbaMatchScoreCommentPage.fromJson(decoded);
}

Future<HupuNbaMatchScoreCommentPage> getHupuNbaMatchScoreLatestComments({
  required String scoreBizId,
  String publishTime = '',
  String order = 'desc',
}) async {
  final queryParameters = <String, String>{
    'publishTime': publishTime.isNotEmpty
        ? publishTime
        : DateTime.now().millisecondsSinceEpoch.toString(),
    'order': order,
    'outBizNo': scoreBizId,
    'outBizType': 'basketball_item',
    'clientCode': 'bc9e1ef8570ddf7e',
    'cid': '174865444',
  };
  final decoded = await _getScoreDetailJson(
    '/1/8.0.32/bplcommentapi/bpl/comment/list/primarySingleRow',
    queryParameters: queryParameters,
  );
  return HupuNbaMatchScoreCommentPage.fromJson(decoded);
}

Future<Map<String, dynamic>> _getScoreDetailJson(
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

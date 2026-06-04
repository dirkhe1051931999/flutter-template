import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<HupuNbaMatchScoreData> getHupuNbaMatchScoreData({
  required String matchId,
}) async {
  final scoreBizKey = await _getMatchScoreBizKey(matchId: matchId);
  if (scoreBizKey == null) {
    throw StateError('未找到评分业务标识');
  }
  final scoreSelfJson = await _getScoreSelfJson(scoreBizKey: scoreBizKey);
  final scoreRootNodeId = parseHupuNbaMatchScoreRootNodeId(scoreSelfJson);
  if (scoreRootNodeId <= 0) {
    throw StateError('未找到评分节点');
  }
  final groupJson = await _getScoreTreeJson(
    '/1/8.0.32/bplcommentapi/bff/bpl/score_tree/groupAndSubNodes',
    queryParameters: <String, String>{
      'nodeId': '$scoreRootNodeId',
      'page': '1',
      'pageSize': '100',
    },
  );
  return parseHupuNbaMatchScoreData(
    scoreSelfJson: scoreSelfJson,
    groupJson: groupJson,
    matchScoreBizId: scoreBizKey.outBizNo,
  );
}

Future<Map<String, dynamic>> _getScoreSelfJson({
  required _HupuNbaMatchScoreBizKey scoreBizKey,
}) async {
  return _getScoreTreeJson(
    '/1/8.0.32/bplcommentapi/bpl/score_tree/getSelfByBizKey',
    queryParameters: <String, String>{
      'outBizNo': scoreBizKey.outBizNo,
      'outBizType': scoreBizKey.outBizType,
    },
  );
}

Future<_HupuNbaMatchScoreBizKey?> _getMatchScoreBizKey({
  required String matchId,
}) async {
  final queryParameters = createHupuCommonQueryParameters(
    crt: DateTime.now().millisecondsSinceEpoch.toString(),
  )..addAll(<String, String>{
      'competitionType': 'nba',
      'competitionLeagueType': 'nba',
      'matchId': matchId,
    });

  final decoded = await _getScoreJson(
    '/1/8.0.32/basketballapi/v2/liveTabList',
    queryParameters: queryParameters,
  );
  return _parseLiveScoreBizKey(decoded);
}

_HupuNbaMatchScoreBizKey? _parseLiveScoreBizKey(Map<String, dynamic> json) {
  final result = json['result'];
  if (result is! Map) {
    return null;
  }
  final category = result['category'];
  if (category is! Map) {
    return null;
  }
  for (final value in category.values) {
    final link = _findLiveScoreLink(value);
    if (link.isEmpty) {
      continue;
    }
    final uri = Uri.tryParse(link);
    final outBizNo = uri?.queryParameters['outBizNo'] ?? '';
    final outBizType = uri?.queryParameters['outBizType'] ?? '';
    if (outBizNo.isNotEmpty && outBizType.isNotEmpty) {
      return _HupuNbaMatchScoreBizKey(
        outBizNo: outBizNo,
        outBizType: outBizType,
      );
    }
  }
  return null;
}

String _findLiveScoreLink(dynamic rawCategory) {
  if (rawCategory is! Map) {
    return '';
  }
  final category = Map<String, dynamic>.from(rawCategory);
  final categoryList = category['categoryList'];
  if (categoryList is! List) {
    return '';
  }
  for (final item in categoryList) {
    if (item is! Map) {
      continue;
    }
    final map = Map<String, dynamic>.from(item);
    if (map['categoryId'] == 'live_score') {
      return map['link']?.toString() ?? '';
    }
  }
  return '';
}

class _HupuNbaMatchScoreBizKey {
  const _HupuNbaMatchScoreBizKey({
    required this.outBizNo,
    required this.outBizType,
  });

  final String outBizNo;
  final String outBizType;
}

Future<Map<String, dynamic>> _getScoreJson(
  String path, {
  required Map<String, String> queryParameters,
}) async {
  final signedQuery = Map<String, String>.from(queryParameters)
    ..['sign'] = buildHupuSign(queryParameters);
  final response = await hupuGamesClient.get(
    path,
    queryParameters: signedQuery,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );
  return decodeHupuJson(response.data);
}

Future<Map<String, dynamic>> _getScoreTreeJson(
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

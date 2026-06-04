import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<HupuNbaMatchStatsData> getHupuNbaMatchStatsData({
  required String matchId,
}) async {
  final queryParameters = createHupuCommonQueryParameters(
    crt: DateTime.now().millisecondsSinceEpoch.toString(),
  )..addAll(<String, String>{
      'matchId': matchId,
    });

  final signedQuery = Map<String, String>.from(queryParameters)
    ..['sign'] = buildHupuSign(queryParameters);
  final response = await hupuGamesClient.get(
    '/1/8.0.32/basketballapi/playerMatchStats',
    queryParameters: signedQuery,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );
  return HupuNbaMatchStatsData.fromJson(decodeHupuJson(response.data));
}

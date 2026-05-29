import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<HupuHotListResponse> getHupuHotList({
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
    'clientId': '174865444',
    'crt': '1779962471925',
    'night': '0',
    'channel': 'wandoujia',
    'client': 'bc9e1ef8570ddf7e',
    '_ssid': 'PHVua25vd24gc3NpZD4=',
    '_imei': 'bc9e1ef8570ddf7e',
    'android_id': 'bc9e1ef8570ddf7e',
    'time_zone': 'Asia/Shanghai',
    'deviceId':
        'BHSHUue6eR8rYvoib0Qy4I8IE5PG8/LWFCIdPwp2qYat891x8RjOXItQM1tuvSMmwCQYI9ibVYg4Pqtg5AjPrDQ==',
  };

  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuGamesClient.get(
    '/1/8.0.32/buffer/hotList',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  final decoded = decodeHupuJson(response.data);
  return HupuHotListResponse.fromJson(decoded);
}

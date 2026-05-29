import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<HupuTopicCategoryResponse> getHupuTopicCategories() async {
  final queryParameters = <String, String>{
    'all': '1',
    'tV2': '1',
    'clientId': '174865444',
    'crt': '1780020064798',
    'night': '0',
    'channel': 'wandoujia',
    'client': 'bc9e1ef8570ddf7e',
    '_ssid': 'PHVua25vd24gc3NpZD4=',
    '_imei': 'bc9e1ef8570ddf7e',
    'android_id': 'bc9e1ef8570ddf7e',
    'time_zone': 'Asia/Shanghai',
    'deviceId':
        'BmLkUBaY8opLqljaY53mMP+BoqL4DdwyctGkpZAji8F1Fa0qGi/rF6jaNUzSdMcR6Ubbfhk2Xql0u737uOY3eRQ==',
  };

  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuBbsClient.get(
    '/1/8.0.32/topics',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  final decoded = decodeHupuJson(response.data);
  return HupuTopicCategoryResponse.fromJson(decoded);
}

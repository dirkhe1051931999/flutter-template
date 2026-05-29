import 'dart:convert';

import 'package:crypto/crypto.dart';

const String hupuSalt = 'HUPU_SALT_AKJfoiwer394Jeiow4u309';

String buildHupuSign(Map<String, String> queryParameters) {
  final keys = queryParameters.keys.toList()..sort();
  final content =
      keys.map((key) => '$key=${queryParameters[key] ?? ''}').join('&');
  return md5.convert(utf8.encode('$content$hupuSalt')).toString();
}

Map<String, String> createHupuCommonQueryParameters({
  required String crt,
}) {
  return <String, String>{
    'clientId': '174865444',
    'crt': crt,
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
}

Map<String, dynamic> decodeHupuJson(dynamic rawBytes) {
  if (rawBytes is! List<int>) {
    throw StateError('Unexpected Hupu response bytes');
  }
  final decoded = jsonDecode(utf8.decode(rawBytes));
  if (decoded is! Map<String, dynamic>) {
    throw StateError('Unexpected Hupu response payload');
  }
  return decoded;
}

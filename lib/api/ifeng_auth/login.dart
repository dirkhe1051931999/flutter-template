import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/ifeng_auth/common.dart';
import 'package:oolaf_flutted/model/ifeng_auth/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<IfengAuthSessionModel?> loginIfengBySms({
  required String mobile,
  required String smsCode,
  required String ltoken,
}) async {
  final Response<dynamic> response = await ifengPostForm(
    IfengRequestClients.userClient,
    smsFastPassPath,
    formData: <String, dynamic>{
      'u': mobile,
      'cert': smsCode,
      'ltoken': ltoken,
    },
    options: const IfengRequestOptions(includeAuth: false),
  );
  final json = asIfengAuthMap(response.data);
  final code = int.tryParse(json['code']?.toString() ?? '') ?? -1;
  final data = asIfengAuthMap(json['data']);
  if (code != 1 || data.isEmpty) {
    return null;
  }
  final session = IfengAuthSessionModel.fromSmsFastPass(data);
  return session.isLoggedIn ? session : null;
}

Future<IfengUserProfileModel?> completeIfengLogin({
  required IfengAuthSessionModel session,
}) async {
  final Response<dynamic> response = await ifengPostWithQuery(
    IfengRequestClients.userClient,
    loginCompletionPath,
    queryParameters: <String, dynamic>{
      'guid': session.guid,
      'token': session.token,
      'deviceid': '860250745769422',
      'os': 'android_28',
      'nickname': session.nickname,
      'userimg': session.userImage,
      'auth': session.auth.isNotEmpty ? session.auth : defaultIfengAuth,
      'username': session.username,
      'publishID': '2011',
      'current_ver': '7303',
      'os_ver': '9',
      'model': 'Asus:ASUS_AI2401_A',
      'resolution': '720x1280',
      'ramSize': '5.81',
      'IMEI': '860250745769422',
      'MAC': '0',
      'network': 'wifi',
      'carrier': '',
      'IPs': '192.168.232.2',
      'POI': '0.0,0.0',
      'proid': 'ifengnews',
    },
    options: const IfengRequestOptions(includeAuth: false),
  );
  final json = asIfengAuthMap(response.data);
  final userInfo = asIfengAuthMap(json['userinfo']);
  if (userInfo.isEmpty) {
    return null;
  }
  return IfengUserProfileModel.fromJson(userInfo);
}

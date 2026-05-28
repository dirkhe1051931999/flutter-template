import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:oolaf_flutted/model/ifeng_auth/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

const String _sendMsgByClickPath = '/api/sendMsgByClick';
const String _getCaptchaPath = '/api/getCaptcha';
const String _checkMobilePath = '/api/checkMobile';
const String _smsFastPassPath = '/Api_User_Userbasic/smsFastPass';
const String _loginCompletionPath = '/api_user_userbasic/login';
const String _getUserInfoPath = '/api_user_exp/timeline';
const String _logoutPath = '/Api_User_Userbasic/quit';
const String _defaultIfengAuth = '4A24BA8FCD63FF5F';

Future<IfengSmsSendResultModel> sendIfengLoginSms({
  required String mobile,
}) async {
  final Response<dynamic> response = await ifengPostForm(
    IfengRequestClients.idClient,
    _sendMsgByClickPath,
    formData: <String, dynamic>{
      'mobile': mobile,
      'channel': '1',
      'platform': 'c',
      'systemid': '7',
    },
    options: const IfengRequestOptions(includeAuth: false),
  );
  debugPrint('ifeng sendMsgByClick response: ${response.data}');
  return IfengSmsSendResultModel.fromJson(_asMap(response.data));
}

Future<IfengCaptchaModel?> getIfengCaptcha() async {
  final Response<dynamic> response = await ifengPostForm(
    IfengRequestClients.idClient,
    _getCaptchaPath,
    formData: <String, dynamic>{
      'type': '1',
      'platform': 'c',
      'systemid': '7',
    },
    options: const IfengRequestOptions(includeAuth: false),
  );
  debugPrint('ifeng getCaptcha response: ${response.data}');
  final json = _asMap(response.data);
  final data = _asMap(json['data']);
  if (data.isEmpty) {
    return null;
  }
  final model = IfengCaptchaModel.fromJson(data);
  return model.isValid ? model : null;
}

Future<IfengSmsSendResultModel> verifyIfengCaptchaAndSendSms({
  required String mobile,
  required String captchaId,
  required String positionsJson,
}) async {
  final Response<dynamic> response = await ifengPostForm(
    IfengRequestClients.idClient,
    _sendMsgByClickPath,
    formData: <String, dynamic>{
      'mobile': mobile,
      'channel': '1',
      'platform': 'c',
      'systemid': '7',
      'captcha_id': captchaId,
      'positions': positionsJson,
    },
    options: const IfengRequestOptions(includeAuth: false),
  );
  debugPrint('ifeng verify captcha sendMsgByClick response: ${response.data}');
  return IfengSmsSendResultModel.fromJson(_asMap(response.data));
}

Future<String> checkIfengMobileBeforeLogin({
  required String mobile,
}) async {
  final Response<dynamic> response = await ifengPostWithQuery(
    IfengRequestClients.idClient,
    _checkMobilePath,
    queryParameters: <String, dynamic>{
      'u': mobile,
      'so': '7',
    },
    options: const IfengRequestOptions(includeAuth: false),
  );
  final json = _asMap(response.data);
  final data = _asMap(json['data']);
  return data['res']?.toString() ?? '';
}

Future<IfengAuthSessionModel?> loginIfengBySms({
  required String mobile,
  required String smsCode,
  required String ltoken,
}) async {
  final Response<dynamic> response = await ifengPostForm(
    IfengRequestClients.userClient,
    _smsFastPassPath,
    formData: <String, dynamic>{
      'u': mobile,
      'cert': smsCode,
      'ltoken': ltoken,
    },
    options: const IfengRequestOptions(includeAuth: false),
  );
  final json = _asMap(response.data);
  final code = int.tryParse(json['code']?.toString() ?? '') ?? -1;
  final data = _asMap(json['data']);
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
    _loginCompletionPath,
    queryParameters: <String, dynamic>{
      'guid': session.guid,
      'token': session.token,
      'deviceid': '860250745769422',
      'os': 'android_28',
      'nickname': session.nickname,
      'userimg': session.userImage,
      'auth': session.auth.isNotEmpty ? session.auth : _defaultIfengAuth,
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
  final json = _asMap(response.data);
  final userInfo = _asMap(json['userinfo']);
  if (userInfo.isEmpty) {
    return null;
  }
  return IfengUserProfileModel.fromJson(userInfo);
}

Future<IfengUserProfileModel?> getIfengUserProfile() async {
  final Response<dynamic> response = await ifengPostWithQuery(
    IfengRequestClients.userClient,
    _getUserInfoPath,
  );
  final json = _asMap(response.data);
  final data = _asMap(json['data']);
  final userInfo = _asMap(data['user_info']).isNotEmpty
      ? _asMap(data['user_info'])
      : _asMap(json['userinfo']);
  if (userInfo.isEmpty) {
    return null;
  }
  return IfengUserProfileModel.fromJson(userInfo);
}

Future<void> logoutIfengUser() async {
  await ifengPost(
    IfengRequestClients.userClient,
    _logoutPath,
  );
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      return _asMap(decoded);
    } catch (_) {
      return <String, dynamic>{};
    }
  }
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, data) => MapEntry(key.toString(), data));
  }
  return <String, dynamic>{};
}

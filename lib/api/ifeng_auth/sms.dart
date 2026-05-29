import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:oolaf_flutted/api/ifeng_auth/common.dart';
import 'package:oolaf_flutted/model/ifeng_auth/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<IfengSmsSendResultModel> sendIfengLoginSms({
  required String mobile,
}) async {
  final Response<dynamic> response = await ifengPostForm(
    IfengRequestClients.idClient,
    sendMsgByClickPath,
    formData: <String, dynamic>{
      'mobile': mobile,
      'channel': '1',
      'platform': 'c',
      'systemid': '7',
    },
    options: const IfengRequestOptions(includeAuth: false),
  );
  debugPrint('ifeng sendMsgByClick response: ${response.data}');
  return IfengSmsSendResultModel.fromJson(asIfengAuthMap(response.data));
}

Future<IfengCaptchaModel?> getIfengCaptcha() async {
  final Response<dynamic> response = await ifengPostForm(
    IfengRequestClients.idClient,
    getCaptchaPath,
    formData: <String, dynamic>{
      'type': '1',
      'platform': 'c',
      'systemid': '7',
    },
    options: const IfengRequestOptions(includeAuth: false),
  );
  debugPrint('ifeng getCaptcha response: ${response.data}');
  final json = asIfengAuthMap(response.data);
  final data = asIfengAuthMap(json['data']);
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
    sendMsgByClickPath,
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
  return IfengSmsSendResultModel.fromJson(asIfengAuthMap(response.data));
}

Future<String> checkIfengMobileBeforeLogin({
  required String mobile,
}) async {
  final Response<dynamic> response = await ifengPostWithQuery(
    IfengRequestClients.idClient,
    checkMobilePath,
    queryParameters: <String, dynamic>{
      'u': mobile,
      'so': '7',
    },
    options: const IfengRequestOptions(includeAuth: false),
  );
  final json = asIfengAuthMap(response.data);
  final data = asIfengAuthMap(json['data']);
  return data['res']?.toString() ?? '';
}

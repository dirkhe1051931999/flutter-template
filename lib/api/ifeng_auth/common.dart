import 'dart:convert';

const String sendMsgByClickPath = '/api/sendMsgByClick';
const String getCaptchaPath = '/api/getCaptcha';
const String checkMobilePath = '/api/checkMobile';
const String smsFastPassPath = '/Api_User_Userbasic/smsFastPass';
const String loginCompletionPath = '/api_user_userbasic/login';
const String getUserInfoPath = '/api_user_exp/timeline';
const String logoutPath = '/Api_User_Userbasic/quit';
const String defaultIfengAuth = '4A24BA8FCD63FF5F';

Map<String, dynamic> asIfengAuthMap(dynamic value) {
  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      return asIfengAuthMap(decoded);
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

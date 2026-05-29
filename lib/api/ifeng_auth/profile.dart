import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/ifeng_auth/common.dart';
import 'package:oolaf_flutted/model/ifeng_auth/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<IfengUserProfileModel?> getIfengUserProfile() async {
  final Response<dynamic> response = await ifengPostWithQuery(
    IfengRequestClients.userClient,
    getUserInfoPath,
  );
  final json = asIfengAuthMap(response.data);
  final data = asIfengAuthMap(json['data']);
  final userInfo = asIfengAuthMap(data['user_info']).isNotEmpty
      ? asIfengAuthMap(data['user_info'])
      : asIfengAuthMap(json['userinfo']);
  if (userInfo.isEmpty) {
    return null;
  }
  return IfengUserProfileModel.fromJson(userInfo);
}

Future<void> logoutIfengUser() async {
  await ifengPost(
    IfengRequestClients.userClient,
    logoutPath,
  );
}

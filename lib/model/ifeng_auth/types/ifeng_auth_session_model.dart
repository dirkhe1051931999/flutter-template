class IfengAuthSessionModel {
  const IfengAuthSessionModel({
    required this.token,
    required this.guid,
    required this.username,
    required this.nickname,
    required this.userImage,
    required this.auth,
    required this.smsFastPass,
  });

  final String token;
  final String guid;
  final String username;
  final String nickname;
  final String userImage;
  final String auth;
  final Map<String, dynamic> smsFastPass;

  bool get isLoggedIn {
    return token.trim().isNotEmpty &&
        guid.trim().isNotEmpty &&
        username.trim().isNotEmpty;
  }

  factory IfengAuthSessionModel.fromSmsFastPass(Map<String, dynamic> json) {
    return IfengAuthSessionModel(
      token: json['token']?.toString() ?? '',
      guid: json['guid']?.toString() ?? '',
      username: json['uname']?.toString() ?? json['username']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      userImage: json['userimg']?.toString() ?? '',
      auth: json['auth']?.toString() ?? '',
      smsFastPass: json,
    );
  }
}

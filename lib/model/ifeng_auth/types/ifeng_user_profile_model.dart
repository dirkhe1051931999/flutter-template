class IfengUserCreditModel {
  const IfengUserCreditModel({
    required this.title1,
  });

  final String title1;

  factory IfengUserCreditModel.fromJson(Map<String, dynamic> json) {
    return IfengUserCreditModel(
      title1: json['title_1']?.toString() ?? '',
    );
  }
}

class IfengUserProfileModel {
  const IfengUserProfileModel({
    required this.nickname,
    required this.userImage,
    required this.followCount,
    required this.fansCount,
    required this.credit,
  });

  final String nickname;
  final String userImage;
  final int followCount;
  final int fansCount;
  final IfengUserCreditModel credit;

  bool get hasProfile => nickname.trim().isNotEmpty || userImage.trim().isNotEmpty;

  factory IfengUserProfileModel.fromJson(Map<String, dynamic> json) {
    final creditJson = json['credit'];
    return IfengUserProfileModel(
      nickname: json['nickname']?.toString() ?? '',
      userImage: json['userimg']?.toString() ?? '',
      followCount: int.tryParse(json['follow_num']?.toString() ?? '') ?? 0,
      fansCount: int.tryParse(json['fans_num']?.toString() ?? '') ?? 0,
      credit: creditJson is Map<String, dynamic>
          ? IfengUserCreditModel.fromJson(creditJson)
          : creditJson is Map
              ? IfengUserCreditModel.fromJson(
                  creditJson.map((key, value) => MapEntry(key.toString(), value)),
                )
              : const IfengUserCreditModel(title1: ''),
    );
  }
}

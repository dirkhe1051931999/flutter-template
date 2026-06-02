import 'package:oolaf_flutted/store/user/type.dart';

class ProfileViewData {
  const ProfileViewData({
    required this.age,
    required this.username,
    required this.infoItems,
  });

  final int age;
  final String username;
  final List<ProfileInfoItem> infoItems;

  factory ProfileViewData.fromUserInfo(UserInfo userInfo) {
    return ProfileViewData(
      age: userInfo.age,
      username: userInfo.username,
      infoItems: [
        ProfileInfoItem(label: 'name', value: userInfo.name),
        ProfileInfoItem(label: 'age', value: '${userInfo.age}'),
        ProfileInfoItem(label: 'username', value: userInfo.username),
        ProfileInfoItem(label: 'password', value: userInfo.password),
        ProfileInfoItem(label: 'token', value: userInfo.token),
        ProfileInfoItem(label: 'email', value: userInfo.email),
        ProfileInfoItem(label: 'phone', value: userInfo.phone),
      ],
    );
  }
}

class ProfileInfoItem {
  const ProfileInfoItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

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
        ProfileInfoItem(key: 'name', label: 'name', value: userInfo.name),
        ProfileInfoItem(
          key: 'age',
          label: 'age',
          value: userInfo.age < 0 ? '' : '${userInfo.age}',
        ),
        ProfileInfoItem(
          key: 'username',
          label: 'username',
          value: userInfo.username,
        ),
        ProfileInfoItem(
          key: 'password',
          label: 'password',
          value: userInfo.password,
        ),
        ProfileInfoItem(key: 'token', label: 'token', value: userInfo.token),
        ProfileInfoItem(key: 'email', label: 'email', value: userInfo.email),
        ProfileInfoItem(key: 'phone', label: 'phone', value: userInfo.phone),
      ],
    );
  }
}

class ProfileInfoItem {
  const ProfileInfoItem({
    required this.key,
    required this.label,
    required this.value,
  });

  final String key;
  final String label;
  final String value;
}

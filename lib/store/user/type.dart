import 'package:oolaf_flutted/store/action.dart';

class UserInfo {
  const UserInfo({
    required this.name,
    required this.age,
    required this.username,
    required this.password,
    required this.token,
    required this.email,
    required this.phone,
  });

  final String name;
  final int age;
  final String username;
  final String password;
  final String token;
  final String email;
  final String phone;

  dynamic operator [](String key) {
    switch (key) {
      case 'name':
        return name;
      case 'age':
        return age;
      case 'username':
        return username;
      case 'password':
        return password;
      case 'token':
        return token;
      case 'email':
        return email;
      case 'phone':
        return phone;
      default:
        throw ArgumentError('Key $key not found in UserInfo');
    }
  }

  factory UserInfo.fromMap(Map<String, dynamic> map) {
    return UserInfo(
      name: map['name'] as String,
      age: map['age'] as int,
      username: map['username'] as String,
      password: map['password'] as String,
      token: map['token'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
    );
  }

  static UserInfo initial() {
    return const UserInfo(
      name: '',
      age: -1,
      username: '',
      password: '',
      token: '',
      email: '',
      phone: '',
    );
  }

  UserInfo copyWith({
    String? name,
    int? age,
    String? username,
    String? password,
    String? token,
    String? email,
    String? phone,
  }) {
    return UserInfo(
      name: name ?? this.name,
      age: age ?? this.age,
      username: username ?? this.username,
      password: password ?? this.password,
      token: token ?? this.token,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  Map<String, Object> toMap() {
    return {
      'name': name,
      'age': age,
      'username': username,
      'password': password,
      'token': token,
      'email': email,
      'phone': phone,
    };
  }
}

class UpdateUserInfoAction extends AppAction {
  const UpdateUserInfoAction({
    this.name,
    this.age,
    this.username,
    this.password,
    this.token,
    this.email,
    this.phone,
  });

  final String? name;
  final int? age;
  final String? username;
  final String? password;
  final String? token;
  final String? email;
  final String? phone;
}

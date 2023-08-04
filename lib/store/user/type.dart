class IUserinfo {
  String name;
  int age;
  String username;
  String password;
  String token;
  String email;
  String phone;

  IUserinfo({
    required this.name,
    required this.age,
    required this.username,
    required this.password,
    required this.token,
    required this.email,
    required this.phone,
  });

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
        throw ArgumentError('Key $key not found in IUserinfo');
    }
  }

  factory IUserinfo.fromMap(Map<String, dynamic> map) {
    return IUserinfo(
      name: map['name'] as String,
      age: map['age'] as int,
      username: map['username'] as String,
      password: map['password'] as String,
      token: map['token'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
    );
  }

  toMap() {
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

class IUserUpdate {
  final Map<String, dynamic> fields;

  IUserUpdate({required this.fields});
}

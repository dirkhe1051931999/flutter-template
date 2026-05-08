import 'package:flutter_template_start/store/index.dart';
import 'package:flutter_template_start/store/user/type.dart';

AppState userReducer(AppState state, dynamic action) {
  if (action is UpdateUserInfoAction) {
    return state.copyWith(
      userInfo: state.userInfo.copyWith(
        name: action.name,
        age: action.age,
        username: action.username,
        password: action.password,
        token: action.token,
        email: action.email,
        phone: action.phone,
      ),
    );
  }
  return state;
}

import 'package:oolaf_flutted/store/action.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/user/type.dart';

AppState userReducer(AppState state, AppAction action) {
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

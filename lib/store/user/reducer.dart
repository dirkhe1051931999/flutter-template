import 'package:flutter_template_start/store/index.dart';
import 'package:flutter_template_start/store/user/type.dart';

AppState userReducer(AppState state, dynamic action) {
  if (action is IUserUpdate) {
    var userinfo = action.fields;
    // 如果要更改的userinfo key 在IUserinfo不存在，报错
    userinfo.forEach((key, value) {
      if (!state.userinfo.toMap().keys.contains(key)) {
        throw Exception('IUserinfo不存在key：$key');
      }
    });
    return state.update({'userinfo': userinfo});
  }
  return state;
}

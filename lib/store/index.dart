import 'package:flutter_template_start/store/todolist/reducer.dart';
import 'package:flutter_template_start/store/user/reducer.dart';
import 'package:flutter_template_start/store/user/type.dart';

class AppState {
  const AppState({
    required this.todos,
    required this.userInfo,
  });

  final List<String> todos;
  final UserInfo userInfo;

  UserInfo get userinfo => userInfo;

  AppState copyWith({
    List<String>? todos,
    UserInfo? userInfo,
  }) {
    return AppState(
      todos: todos ?? this.todos,
      userInfo: userInfo ?? this.userInfo,
    );
  }

  factory AppState.initial() {
    return AppState(
      todos: const ['initial item'],
      userInfo: UserInfo.initial(),
    );
  }
}

AppState appReducer(AppState state, dynamic action) {
  var updatedState = todoListReducer(state, action);
  updatedState = userReducer(updatedState, action);
  return updatedState;
}

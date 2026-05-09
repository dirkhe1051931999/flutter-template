import 'package:flutter_template_start/store/action.dart';
import 'package:flutter_template_start/store/oolaf_music/reducer.dart';
import 'package:flutter_template_start/store/oolaf_music/state.dart';
import 'package:flutter_template_start/store/todolist/reducer.dart';
import 'package:flutter_template_start/store/user/reducer.dart';
import 'package:flutter_template_start/store/user/type.dart';

class AppState {
  const AppState({
    required this.todos,
    required this.userInfo,
    required this.oolafMusic,
  });

  final List<String> todos;
  final UserInfo userInfo;
  final OolafMusicState oolafMusic;

  UserInfo get userinfo => userInfo;

  AppState copyWith({
    List<String>? todos,
    UserInfo? userInfo,
    OolafMusicState? oolafMusic,
  }) {
    return AppState(
      todos: todos ?? this.todos,
      userInfo: userInfo ?? this.userInfo,
      oolafMusic: oolafMusic ?? this.oolafMusic,
    );
  }

  factory AppState.initial() {
    return AppState(
      todos: const ['initial item'],
      userInfo: UserInfo.initial(),
      oolafMusic: OolafMusicState.initial(),
    );
  }
}

AppState appReducer(AppState state, AppAction action) {
  var updatedState = todoListReducer(state, action);
  updatedState = userReducer(updatedState, action);
  updatedState = oolafMusicReducer(updatedState, action);
  return updatedState;
}

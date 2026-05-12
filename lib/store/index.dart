import 'package:oolaf_flutted/store/action.dart';
import 'package:oolaf_flutted/store/oolaf_music/reducer.dart';
import 'package:oolaf_flutted/store/oolaf_music/state.dart';
import 'package:oolaf_flutted/store/short_video/reducer.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/store/todolist/reducer.dart';
import 'package:oolaf_flutted/store/user/reducer.dart';
import 'package:oolaf_flutted/store/user/type.dart';

class AppState {
  const AppState({
    required this.todos,
    required this.userInfo,
    required this.oolafMusic,
    required this.shortVideo,
  });

  final List<String> todos;
  final UserInfo userInfo;
  final OolafMusicState oolafMusic;
  final ShortVideoState shortVideo;

  UserInfo get userinfo => userInfo;

  AppState copyWith({
    List<String>? todos,
    UserInfo? userInfo,
    OolafMusicState? oolafMusic,
    ShortVideoState? shortVideo,
  }) {
    return AppState(
      todos: todos ?? this.todos,
      userInfo: userInfo ?? this.userInfo,
      oolafMusic: oolafMusic ?? this.oolafMusic,
      shortVideo: shortVideo ?? this.shortVideo,
    );
  }

  factory AppState.initial() {
    return AppState(
      todos: const ['initial item'],
      userInfo: UserInfo.initial(),
      oolafMusic: OolafMusicState.initial(),
      shortVideo: ShortVideoState.initial(),
    );
  }
}

AppState appReducer(AppState state, AppAction action) {
  var updatedState = todoListReducer(state, action);
  updatedState = userReducer(updatedState, action);
  updatedState = oolafMusicReducer(updatedState, action);
  updatedState = shortVideoReducer(updatedState, action);
  return updatedState;
}

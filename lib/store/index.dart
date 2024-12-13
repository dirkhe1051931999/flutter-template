import 'package:flutter_template_start/store/todolist/reducer.dart';
import 'package:flutter_template_start/store/user/reducer.dart';
import 'package:flutter_template_start/store/user/type.dart';
import 'package:flutter_template_start/utils/helper.dart';

class AppState {
  final Map<String, dynamic> _data;

  // Static initial state
  static const Map<String, dynamic> _initialState = {
    'todos': ['initial item'],
    'userinfo': {
      'name': '',
      'age': -1,
      'username': '',
      'password': '',
      'token': '',
      'email': '',
      'phone': '',
    },
    // ... add other initial states here
  };

  // Getters for each state piece
  List<String> get todos => _data['todos'] as List<String>;

  IUserinfo get userinfo =>
      IUserinfo.fromMap(_data['userinfo'] as Map<String, dynamic>);

  // Getter for initial state
  static Map<String, dynamic> get initialState => _initialState;

  AppState._(this._data);

  // copyWith-like method that works with map
  AppState update(dynamic changes) {
    return AppState._(recursiveMerge(_data, changes));
  }

  // Initial state factory
  factory AppState.initial() {
    return AppState._(_initialState);
  }
}

AppState appReducer(AppState state, dynamic action) {
  var updatedState = todoListReducer(state, action);
  updatedState = userReducer(updatedState, action);

  // 如果您有其他的，例如修改状态的“用户”部分的 userReducer：
  return updatedState;
}
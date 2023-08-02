import 'package:flutter_template_start/store/todolist/model.dart';

List<String> todoListReducer(List<String> state, dynamic action) {
  if (action is IAdd) {
    return [...state, action.name];
  }
  if (action is IRemove) {
    return state.where((item) => item != action.name).toList();
  }
  if (action == IClear) {
    return [];
  }
  return state;
}

import 'package:flutter_template_start/store/index.dart';
import 'package:flutter_template_start/store/todolist/type.dart';

AppState todoListReducer(AppState state, dynamic action) {
  if (action is ITodolistAdd) {
    return state.update({
      'todos': [...state.todos, action.name]
    });
  }
  if (action is ITodolistRemove) {
    return state.update(
      {'todos': state.todos.where((item) => item != action.name).toList()},
    );
  }
  if (action == ITodolistClear) {
    return state.update({'todos': <String>[]});
  }
  return state;
}

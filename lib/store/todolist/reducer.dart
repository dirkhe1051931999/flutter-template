import 'package:oolaf_flutted/store/action.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/todolist/type.dart';

AppState todoListReducer(AppState state, AppAction action) {
  if (action is AddTodoAction) {
    return state.copyWith(todos: [...state.todos, action.name]);
  }
  if (action is RemoveTodoAction) {
    return state.copyWith(
      todos: state.todos.where((item) => item != action.name).toList(),
    );
  }
  if (action is ClearTodoAction) {
    return state.copyWith(todos: const []);
  }
  return state;
}

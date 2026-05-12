import 'package:oolaf_flutted/store/action.dart';

class AddTodoAction extends AppAction {
  final String name;
  const AddTodoAction(this.name);
}

class RemoveTodoAction extends AppAction {
  final String name;
  const RemoveTodoAction(this.name);
}

class ClearTodoAction extends AppAction {
  const ClearTodoAction();
}

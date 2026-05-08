class AddTodoAction {
  final String name;
  AddTodoAction(this.name);
}

class RemoveTodoAction {
  final String name;
  RemoveTodoAction(this.name);
}

class ClearTodoAction {
  const ClearTodoAction();
}

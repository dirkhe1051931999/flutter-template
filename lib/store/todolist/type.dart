class ITodolistAdd {
  final String name;
  ITodolistAdd(this.name);
}

class ITodolistRemove {
  final String name;
  ITodolistRemove(this.name);

  get index => null;
}

class ITodolistClear {
  ITodolistClear();
}

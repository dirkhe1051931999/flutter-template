import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_template_start/store/index.dart';
import 'package:flutter_template_start/store/todolist/type.dart';

class ClearWidget extends StatelessWidget {
  const ClearWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, VoidCallback>(
      builder: (context, callback) {
        return ElevatedButton(
          onPressed: callback,
          child: const Text('Clear'),
        );
      },
      converter: (store) => () {
        store.dispatch(ITodolistClear);
      },
    );
  }
}

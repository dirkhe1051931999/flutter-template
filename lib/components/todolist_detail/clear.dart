import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_template_start/store/todolist/model.dart';

class ClearWidget extends StatelessWidget {
  const ClearWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<List<String>, VoidCallback>(
      builder: (context, callback) {
        return ElevatedButton(
          onPressed: callback,
          child: const Text('Clear'),
        );
      },
      converter: (store) => () {
        store.dispatch(IClear);
      },
    );
  }
}
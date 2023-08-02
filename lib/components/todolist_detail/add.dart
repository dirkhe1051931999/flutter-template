import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_template_start/store/todolist/model.dart';

class AddWidget extends StatelessWidget {
  const AddWidget({Key? key, required this.controller}) : super(key: key);
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<List<String>, VoidCallback>(
      builder: (context, callback) {
        return ElevatedButton(
          onPressed: callback,
          child: const Text('Add'),
        );
      },
      converter: (store) {
        return () {
          // 不能是空的
          if (controller!.text.isEmpty) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                // 多次点击只会显示一次
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
                content: const Text('Please input something'),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
            return;
          }
          // 不添加重复项
          if (store.state.contains(controller!.text)) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
                content: const Text('Item already exists'),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
            return;
          }
          store.dispatch(IAdd(controller!.text));
          controller!.clear();
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.greenAccent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
              content: const Text('Add successfully'),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        };
      },
    );
  }
}

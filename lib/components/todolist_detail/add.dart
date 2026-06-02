import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/todolist/type.dart';

class AddWidget extends StatelessWidget {
  const AddWidget({super.key, required this.controller});

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, VoidCallback>(
      builder: (context, callback) {
        return CupertinoButton.filled(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          borderRadius: BorderRadius.circular(16),
          onPressed: callback,
          child: const Text(
            '添加',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
      converter: (store) {
        return () {
          if (controller!.text.isEmpty) {
            EasyLoading.showToast('Please input something');
            return;
          }
          if (store.state.todos.contains(controller!.text)) {
            EasyLoading.showToast('Item already exists');
            return;
          }
          store.dispatch(AddTodoAction(controller!.text));
          controller!.clear();
          EasyLoading.showToast('Add successfully');
        };
      },
    );
  }
}

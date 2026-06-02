import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/todolist/type.dart';

class ClearWidget extends StatelessWidget {
  const ClearWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, VoidCallback>(
      builder: (context, callback) {
        return CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFF0F2F6),
          onPressed: callback,
          child: const Text(
            '清空',
            style: TextStyle(
              color: Color(0xFF596273),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
      converter: (store) => () {
        store.dispatch(const ClearTodoAction());
      },
    );
  }
}

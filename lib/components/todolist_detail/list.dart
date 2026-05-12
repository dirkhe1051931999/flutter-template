import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/components/todolist_detail/list_empty.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/todolist/type.dart';

class ListWidget extends StatelessWidget {
  const ListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<String>>(
      builder: (context, state) {
        final store = StoreProvider.of<AppState>(context);
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: state.isEmpty
                ? [const ListEmpytWidget()]
                : state.map(
                    (item) {
                      return Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(item),
                          IconButton(
                            onPressed: () {
                              store.dispatch(RemoveTodoAction(item));
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      );
                    },
                  ).toList(),
          ),
        );
      },
      converter: (store) => store.state.todos,
    );
  }
}

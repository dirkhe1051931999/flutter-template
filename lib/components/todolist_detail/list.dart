import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_template_start/components/todolist_detail/list_empty.dart';
import 'package:flutter_template_start/store/todolist/type.dart';

class ListWidget extends StatelessWidget {
  const ListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<List<String>, List<String>>(
      builder: (context, state) {
        final store = StoreProvider.of<List<String>>(context);
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: state.isEmpty
                ? [const ListEmpytWidget()]
                : state.map((item) {
                    return Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(item),
                        IconButton(
                          onPressed: () {
                            store.dispatch(ITodolistRemove(item));
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    );
                  }).toList(),
          ),
        );
      },
      converter: (store) => store.state,
    );
  }
}

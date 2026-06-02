import 'package:flutter/cupertino.dart';
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
        if (state.isEmpty) {
          return const ListEmpytWidget();
        }

        return Column(
          children: state
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xF7FFFFFF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x12000000)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.check_mark_circled_solid,
                            color: Color(0xFF9FA8B7),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Color(0xFF1F2329),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.all(8),
                            minimumSize: Size.zero,
                            onPressed: () {
                              store.dispatch(RemoveTodoAction(item));
                            },
                            child: const Icon(
                              CupertinoIcons.delete_simple,
                              color: Color(0xFFB3BAC6),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
      converter: (store) => store.state.todos,
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/todolist_detail/add.dart';
import 'package:oolaf_flutted/components/todolist_detail/clear.dart';
import 'package:oolaf_flutted/components/todolist_detail/input.dart';
import 'package:oolaf_flutted/components/todolist_detail/list.dart';
import 'package:oolaf_flutted/pages/todolist/widgets/todo_hero_card.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: <Widget>[
          const TodoHeroCard(),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xA8FFFFFF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x12FFFFFF)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '任务列表',
                    style: TextStyle(
                      color: Color(0xFF1F2329),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ListWidget(),
                  const SizedBox(height: 6),
                  InputWidget(controller: _controller!),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(child: AddWidget(controller: _controller)),
                      const SizedBox(width: 10),
                      const ClearWidget(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

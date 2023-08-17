import 'package:flutter/material.dart';
import 'package:flutter_template_start/components/todolist_detail/add.dart';
import 'package:flutter_template_start/components/todolist_detail/clear.dart';
import 'package:flutter_template_start/components/todolist_detail/input.dart';
import 'package:flutter_template_start/components/todolist_detail/list.dart';

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
    return Column(
      children: <Widget>[
        // 列表
        const ListWidget(),
        // 输入框
        InputWidget(controller: _controller!),
        // 按钮-添加和清空
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AddWidget(controller: _controller),
            const ClearWidget(),
          ],
        )
      ],
    );
  }
}

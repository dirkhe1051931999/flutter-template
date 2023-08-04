import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluro',
      home: Scaffold(
        body: const Center(
          child: Text('ROUTE WAS NOT FOUND !!!'),
        ),
        // 返回按钮
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_template_start/layouts/app_theme.dart';

class MaterialAppWrapWidget extends StatelessWidget {
  const MaterialAppWrapWidget({
    Key? key,
    required this.title,
    required this.widget,
  }) : super(key: key);
  final String title;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Header',
      debugShowCheckedModeBanner: false,
      theme: AppTheme().light,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: widget,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_template_start/layouts/app_wrap/index.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialAppWrapWidget(
      title: '404',
      widget: Center(
        child: Text('ROUTE WAS NOT FOUND !!!'),
      ),
    );
  }
}

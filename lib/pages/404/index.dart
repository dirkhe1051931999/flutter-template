import 'package:flutter/material.dart';
import 'package:oolaf_flutted/layouts/app_wrap/index.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: '404',
      widget: Center(
        child: Text('ROUTE WAS NOT FOUND !!!'),
      ),
    );
  }
}

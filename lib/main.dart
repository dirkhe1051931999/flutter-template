import 'package:flutter/material.dart';
import 'package:flutter_template_start/bootstrap.dart';
import 'package:flutter_template_start/layouts/index.dart';

void main() {
  final bootstrap = createAppBootstrap();
  runApp(
    Layout(
      router: bootstrap.router,
      store: bootstrap.store,
    ),
  );
}

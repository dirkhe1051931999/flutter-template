import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:oolaf_flutted/bootstrap.dart';
import 'package:oolaf_flutted/layouts/index.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final bootstrap = createAppBootstrap();
  runApp(
    Layout(
      router: bootstrap.router,
      store: bootstrap.store,
    ),
  );
}

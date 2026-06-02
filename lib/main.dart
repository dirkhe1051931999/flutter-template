import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:media_kit/media_kit.dart';
import 'package:oolaf_flutted/bootstrap.dart';
import 'package:oolaf_flutted/layouts/index.dart';
import 'package:oolaf_flutted/tools/developer_tools_center.dart';

void main() {
  FlutterError.onError = (details) {
    DeveloperToolsCenter.instance.recordFlutterError(details);
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    DeveloperToolsCenter.instance.recordError(
      source: 'PlatformDispatcher',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  };

  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    debugPaintBaselinesEnabled = false;
    debugPaintSizeEnabled = false;
    debugPaintPointersEnabled = false;
    debugRepaintRainbowEnabled = false;
    MediaKit.ensureInitialized();
    final bootstrap = createAppBootstrap();
    runApp(
      Layout(
        router: bootstrap.router,
        store: bootstrap.store,
      ),
    );
  }, (error, stackTrace) {
    DeveloperToolsCenter.instance.recordError(
      source: 'runZonedGuarded',
      error: error,
      stackTrace: stackTrace,
    );
  });
}

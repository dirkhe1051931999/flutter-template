import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oolaf_flutted/router/config.dart';
import 'package:oolaf_flutted/router/routes.dart';
import 'package:oolaf_flutted/store/action.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:redux/redux.dart';

class AppBootstrap {
  const AppBootstrap({
    required this.router,
    required this.store,
  });

  final FluroRouter router;
  final Store<AppState> store;
}

AppBootstrap createAppBootstrap() {
  final router = createAppRouter();
  final store = createAppStore();
  configureEasyLoading();

  return AppBootstrap(
    router: router,
    store: store,
  );
}

FluroRouter createAppRouter() {
  final router = FluroRouter();
  Routes.configureRoutes(router);
  Application.router = router;
  return router;
}

Store<AppState> createAppStore() {
  return Store<AppState>(
    (state, action) {
      if (action is! AppAction) {
        return state;
      }
      return appReducer(state, action);
    },
    initialState: AppState.initial(),
  );
}

void configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..toastPosition = EasyLoadingToastPosition.bottom
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withValues(alpha: 0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}

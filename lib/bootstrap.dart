import 'package:fluro/fluro.dart';
import 'package:oolaf_flutted/pages/oolaf_dynamic_audio/controllers/oolaf_audio_playback_controller.dart';
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
  oolafAudioPlaybackController.bindStore(store);

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

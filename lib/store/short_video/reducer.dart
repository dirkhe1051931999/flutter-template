import 'package:oolaf_flutted/store/action.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/short_video/action.dart';

AppState shortVideoReducer(AppState state, AppAction action) {
  final current = state.shortVideo;

  if (action is ShortVideoSetLoadingAction) {
    return state.copyWith(
      shortVideo: current.copyWith(isLoading: action.isLoading),
    );
  }

  if (action is ShortVideoSetItemsAction) {
    return state.copyWith(
      shortVideo: current.copyWith(items: action.items),
    );
  }

  if (action is ShortVideoSetActiveIndexAction) {
    return state.copyWith(
      shortVideo: current.copyWith(activeIndex: action.activeIndex),
    );
  }

  return state;
}

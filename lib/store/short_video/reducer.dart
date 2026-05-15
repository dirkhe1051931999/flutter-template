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

  if (action is ShortVideoSetRecordWatchHistoryAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        recordWatchHistory: action.recordWatchHistory,
      ),
    );
  }

  if (action is ShortVideoSetAutoPlayNextVideoAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        autoPlayNextVideo: action.autoPlayNextVideo,
      ),
    );
  }

  if (action is ShortVideoSetPlaybackRateAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        playbackRate: action.rate,
      ),
    );
  }

  if (action is ShortVideoSetPreloadStrategyAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        preloadPagesCount: action.preloadPagesCount,
        keepWindow: action.keepWindow,
      ),
    );
  }

  if (action is ShortVideoSetVideoFitModeAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        videoFitMode: action.mode,
      ),
    );
  }

  if (action is ShortVideoRestorePreferencesAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        recordWatchHistory: action.recordWatchHistory,
        autoPlayNextVideo: action.autoPlayNextVideo,
        playbackRate: action.playbackRate,
        preloadPagesCount: action.preloadPagesCount,
        keepWindow: action.keepWindow,
        videoFitMode: action.videoFitMode,
      ),
    );
  }

  return state;
}

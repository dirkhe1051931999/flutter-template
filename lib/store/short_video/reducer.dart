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

  if (action is ShortVideoSetAutoPlayOnEnterAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        autoPlayOnEnter: action.autoPlayOnEnter,
      ),
    );
  }

  if (action is ShortVideoSetRememberPlaybackProgressAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        rememberPlaybackProgress: action.rememberPlaybackProgress,
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

  if (action is ShortVideoSetDanmakuEnabledAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        danmakuEnabled: action.enabled,
      ),
    );
  }

  if (action is ShortVideoSetDanmakuOpacityAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        danmakuOpacity: action.value,
      ),
    );
  }

  if (action is ShortVideoSetDanmakuFontScaleAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        danmakuFontScale: action.value,
      ),
    );
  }

  if (action is ShortVideoSetDanmakuFontWeightAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        danmakuFontWeight: action.value,
      ),
    );
  }

  if (action is ShortVideoSetDanmakuSpeedAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        danmakuSpeed: action.value,
      ),
    );
  }

  if (action is ShortVideoSetDanmakuAreaAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        danmakuArea: action.value,
      ),
    );
  }

  if (action is ShortVideoRestorePreferencesAction) {
    return state.copyWith(
      shortVideo: current.copyWith(
        recordWatchHistory: action.recordWatchHistory,
        autoPlayOnEnter: action.autoPlayOnEnter,
        rememberPlaybackProgress: action.rememberPlaybackProgress,
        autoPlayNextVideo: action.autoPlayNextVideo,
        playbackRate: action.playbackRate,
        preloadPagesCount: action.preloadPagesCount,
        keepWindow: action.keepWindow,
        videoFitMode: action.videoFitMode,
        danmakuEnabled: action.danmakuEnabled,
        danmakuOpacity: action.danmakuOpacity,
        danmakuFontScale: action.danmakuFontScale,
        danmakuFontWeight: action.danmakuFontWeight,
        danmakuSpeed: action.danmakuSpeed,
        danmakuArea: action.danmakuArea,
      ),
    );
  }

  return state;
}

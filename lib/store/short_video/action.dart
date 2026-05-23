import 'package:oolaf_flutted/store/action.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';

class ShortVideoSetLoadingAction extends AppAction {
  const ShortVideoSetLoadingAction(this.isLoading);

  final bool isLoading;
}

class ShortVideoSetItemsAction extends AppAction {
  const ShortVideoSetItemsAction(this.items);

  final List<ShortVideoItem> items;
}

class ShortVideoSetActiveIndexAction extends AppAction {
  const ShortVideoSetActiveIndexAction(this.activeIndex);

  final int activeIndex;
}

class ShortVideoSetRecordWatchHistoryAction extends AppAction {
  const ShortVideoSetRecordWatchHistoryAction(this.recordWatchHistory);

  final bool recordWatchHistory;
}

class ShortVideoSetAutoPlayOnEnterAction extends AppAction {
  const ShortVideoSetAutoPlayOnEnterAction(this.autoPlayOnEnter);

  final bool autoPlayOnEnter;
}

class ShortVideoSetRememberPlaybackProgressAction extends AppAction {
  const ShortVideoSetRememberPlaybackProgressAction(
    this.rememberPlaybackProgress,
  );

  final bool rememberPlaybackProgress;
}

class ShortVideoSetAutoPlayNextVideoAction extends AppAction {
  const ShortVideoSetAutoPlayNextVideoAction(this.autoPlayNextVideo);

  final bool autoPlayNextVideo;
}

class ShortVideoSetPlaybackRateAction extends AppAction {
  const ShortVideoSetPlaybackRateAction(this.rate);

  final double rate;
}

class ShortVideoSetPreloadStrategyAction extends AppAction {
  const ShortVideoSetPreloadStrategyAction({
    required this.preloadPagesCount,
    required this.keepWindow,
  });

  final int preloadPagesCount;
  final int keepWindow;
}

class ShortVideoSetVideoFitModeAction extends AppAction {
  const ShortVideoSetVideoFitModeAction(this.mode);
  final String mode;
}

class ShortVideoSetDanmakuEnabledAction extends AppAction {
  const ShortVideoSetDanmakuEnabledAction(this.enabled);
  final bool enabled;
}

class ShortVideoSetDanmakuOpacityAction extends AppAction {
  const ShortVideoSetDanmakuOpacityAction(this.value);
  final double value;
}

class ShortVideoSetDanmakuFontScaleAction extends AppAction {
  const ShortVideoSetDanmakuFontScaleAction(this.value);
  final double value;
}

class ShortVideoSetDanmakuFontWeightAction extends AppAction {
  const ShortVideoSetDanmakuFontWeightAction(this.value);
  final int value;
}

class ShortVideoSetDanmakuSpeedAction extends AppAction {
  const ShortVideoSetDanmakuSpeedAction(this.value);
  final double value;
}

class ShortVideoSetDanmakuAreaAction extends AppAction {
  const ShortVideoSetDanmakuAreaAction(this.value);
  final double value;
}

class ShortVideoRestorePreferencesAction extends AppAction {
  const ShortVideoRestorePreferencesAction({
    required this.recordWatchHistory,
    required this.autoPlayOnEnter,
    required this.rememberPlaybackProgress,
    required this.autoPlayNextVideo,
    required this.playbackRate,
    required this.preloadPagesCount,
    required this.keepWindow,
    required this.videoFitMode,
    required this.danmakuEnabled,
    required this.danmakuOpacity,
    required this.danmakuFontScale,
    required this.danmakuFontWeight,
    required this.danmakuSpeed,
    required this.danmakuArea,
  });

  final bool recordWatchHistory;
  final bool autoPlayOnEnter;
  final bool rememberPlaybackProgress;
  final bool autoPlayNextVideo;
  final double playbackRate;
  final int preloadPagesCount;
  final int keepWindow;
  final String videoFitMode;
  final bool danmakuEnabled;
  final double danmakuOpacity;
  final double danmakuFontScale;
  final int danmakuFontWeight;
  final double danmakuSpeed;
  final double danmakuArea;
}

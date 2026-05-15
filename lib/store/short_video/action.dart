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

class ShortVideoRestorePreferencesAction extends AppAction {
  const ShortVideoRestorePreferencesAction({
    required this.recordWatchHistory,
    required this.autoPlayNextVideo,
    required this.playbackRate,
    required this.preloadPagesCount,
    required this.keepWindow,
    required this.videoFitMode,
  });

  final bool recordWatchHistory;
  final bool autoPlayNextVideo;
  final double playbackRate;
  final int preloadPagesCount;
  final int keepWindow;
  final String videoFitMode;
}

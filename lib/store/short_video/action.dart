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

class ShortVideoRestorePreferencesAction extends AppAction {
  const ShortVideoRestorePreferencesAction({
    required this.recordWatchHistory,
    required this.autoPlayNextVideo,
  });

  final bool recordWatchHistory;
  final bool autoPlayNextVideo;
}

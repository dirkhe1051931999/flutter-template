import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';
import 'package:oolaf_flutted/components/short_video/comment_sheet.dart';
import 'package:oolaf_flutted/components/short_video/interaction_overlay.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/router/route_observer.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/short_video/action.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/utils/short_video_blocked_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_watch_history_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_collection_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_playback_progress_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_preferences_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_offline_cache_persistence.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';
import 'package:oolaf_flutted/utils/video_manager.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:redux/redux.dart';

class VideoTabRecomendPage extends StatefulWidget {
  const VideoTabRecomendPage({
    super.key,
    this.channelRequest,
    this.initialFeedVisible = true,
  });

  final PhoenixTvChannelRequest? channelRequest;
  final bool initialFeedVisible;

  @override
  State<VideoTabRecomendPage> createState() => VideoTabRecomendPageState();
}

class VideoTabRecomendPageState extends State<VideoTabRecomendPage>
    with WidgetsBindingObserver, RouteAware, AutomaticKeepAliveClientMixin {
  static const int _loadMoreThreshold = 5;
  static final Map<String, _VideoTabCacheState> _tabStateCache =
      <String, _VideoTabCacheState>{};

  final _pageController = PreloadPageController();
  final _videoManager = VideoManager.instance;

  bool _isAppActive = true;
  late bool _isFeedVisibleInTab;
  bool _resumeAfterInterruption = false;
  bool _didAutoPlayFirst = false;
  bool _isPaging = false;
  bool _hasMore = true;
  int _nextPullNum = 1;
  int _dailyOpenNum = 1;
  int _requestGeneration = 0;
  bool _hasRequestedInitialLoad = false;
  Future<void>? _initialLoadFuture;
  bool _didCheckInitialVisibilityLoad = false;
  Store<AppState>? _store;
  bool _isLoading = false;
  List<ShortVideoItem> _items = const <ShortVideoItem>[];
  int _activeIndex = 0;
  Set<String> _favoriteVideoIds = const <String>{};
  Set<String> _blockedVideoIds = const <String>{};
  int _lastProgressPersistAtMillis = 0;

  OolafVideoController? _activeStatusObservedController;
  VoidCallback? _activeStatusListener;
  bool _isAutoSkippingUnsupported = false;

  OolafVideoController? _activeProgressObservedController;
  VoidCallback? _activeProgressListener;
  String? _lastAutoNextTriggeredVideoId;

  bool get _isChannelFeed => widget.channelRequest != null;

  String get _videoManagerOwnerKey {
    final request = widget.channelRequest;
    if (request == null) {
      return 'short_video_recomend_tab';
    }
    return 'short_video_channel_${request.channel}_${request.listId}';
  }

  String _controllerIdOf(ShortVideoItem item) {
    return '$_videoManagerOwnerKey:${item.id}';
  }

  List<({String id, String url})> _buildVideoSources(List<ShortVideoItem> items) {
    return items
        .map((e) => (id: _controllerIdOf(e), url: e.videoUrl))
        .toList(growable: false);
  }

  int get _initialPullNum {
    final request = widget.channelRequest;
    if (request == null) {
      return 1;
    }
    return request.pullNum;
  }

  Future<List<ShortVideoItem>> _fetchPage({required int pullNum}) async {
    final request = widget.channelRequest;
    if (request == null) {
      return getShortVideoPage(
        pullNum: pullNum,
        dailyOpenNum: _dailyOpenNum,
      );
    }

    return getPhoenixTvChannelPage(
      request: PhoenixTvChannelRequest(
        channel: request.channel,
        listId: request.listId,
        pullTotal: request.pullTotal,
        pullNum: pullNum,
      ),
    );
  }

  Future<void> _setPlaybackRate(double rate) async {
    final store = _store;
    if (store == null) {
      return;
    }
    store.dispatch(ShortVideoSetPlaybackRateAction(rate));

    final activeController = _getActiveController();
    if (activeController != null) {
      await activeController.setPlaybackRate(rate);
    }

    final latest = store.state.shortVideo;
    await ShortVideoPreferencesPersistence.save(
      recordWatchHistory: latest.recordWatchHistory,
      autoPlayNextVideo: latest.autoPlayNextVideo,
      playbackRate: latest.playbackRate,
      preloadPagesCount: latest.preloadPagesCount,
      keepWindow: latest.keepWindow,
      videoFitMode: latest.videoFitMode,
    );
  }

  Future<void> _saveOfflineCache(ShortVideoItem item) async {
    final entry = ShortVideoOfflineCacheEntry(
      videoId: item.id,
      title: item.title,
      updateTime: item.updateTime ?? '',
      coverUrl: item.coverUrl,
      videoUrl: item.videoUrl,
      source: item.source,
      savedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await ShortVideoOfflineCachePersistence.save(entry);
    if (!mounted) {
      return;
    }
    showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('已添加到离线缓存'),
          content: const Text('视频已添加到离线缓存列表。'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _persistActivePlaybackProgress() async {
    if (_items.isEmpty || _activeIndex < 0 || _activeIndex >= _items.length) {
      return;
    }
    final controller = _getActiveController();
    if (controller == null) {
      return;
    }
    await _persistPlaybackProgress(
      videoId: _items[_activeIndex].id,
      controller: controller,
    );
  }

  OolafVideoController? _getActiveController() {
    if (_items.isEmpty || _activeIndex < 0 || _activeIndex >= _items.length) {
      return null;
    }
    return _videoManager.getById(_controllerIdOf(_items[_activeIndex]));
  }

  Future<void> _recordWatchHistoryIfEnabled(ShortVideoItem item) async {
    final store = _store;
    if (store == null) {
      return;
    }
    if (!store.state.shortVideo.recordWatchHistory) {
      return;
    }

    await ShortVideoWatchHistoryPersistence.record(
      ShortVideoWatchHistoryEntry(
        videoId: item.id,
        title: item.title,
        updateTime: item.updateTime ?? '',
        coverUrl: item.coverUrl,
        videoUrl: item.videoUrl,
        source: item.source,
        watchedAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  ShortVideoCollectionEntry _collectionEntryOf(ShortVideoItem item) {
    return ShortVideoCollectionEntry(
      videoId: item.id,
      title: item.title,
      updateTime: item.updateTime ?? '',
      coverUrl: item.coverUrl,
      videoUrl: item.videoUrl,
      source: item.source,
      savedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _loadFavoriteState() async {
    final entries = await ShortVideoCollectionPersistence.favorites.loadAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _favoriteVideoIds = entries.map((entry) => entry.videoId).toSet();
    });
  }

  Future<void> _toggleFavorite(ShortVideoItem item) async {
    const persistence = ShortVideoCollectionPersistence.favorites;
    if (_favoriteVideoIds.contains(item.id)) {
      await persistence.remove(item.id);
    } else {
      await persistence.save(_collectionEntryOf(item));
    }
    await _loadFavoriteState();
  }

  Future<void> _saveWatchLater(ShortVideoItem item) async {
    await ShortVideoCollectionPersistence.watchLater.save(_collectionEntryOf(item));
  }

  Future<void> _copyShareText(ShortVideoItem item) async {
    await Clipboard.setData(
      ClipboardData(text: '${item.title}\n${item.videoUrl}'),
    );
  }

  Future<void> _loadBlockedState() async {
    final blockedIds = await ShortVideoBlockedPersistence.loadAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _blockedVideoIds = blockedIds;
    });
  }

  List<ShortVideoItem> _filterBlockedVideos(List<ShortVideoItem> items) {
    if (_blockedVideoIds.isEmpty) {
      return items;
    }
    return items
        .where((item) => !_blockedVideoIds.contains(item.id))
        .toList(growable: false);
  }

  Future<void> _markNotInterested(ShortVideoItem item) async {
    await ShortVideoBlockedPersistence.add(item.id);
    if (!mounted) {
      return;
    }

    final nextItems = _items
        .where((element) => element.id != item.id)
        .toList(growable: false);
    final nextBlocked = <String>{..._blockedVideoIds, item.id};

    if (nextItems.isEmpty) {
      setState(() {
        _blockedVideoIds = nextBlocked;
        _items = const <ShortVideoItem>[];
        _activeIndex = 0;
      });
      await _videoManager.pauseAll();
      return;
    }

    final nextIndex = _activeIndex.clamp(0, nextItems.length - 1);
    setState(() {
      _blockedVideoIds = nextBlocked;
      _items = nextItems;
      _activeIndex = nextIndex;
    });
    _videoManager.setSources(_buildVideoSources(nextItems));
    if (_pageController.hasClients) {
      _pageController.jumpToPage(nextIndex);
    }
    await _activateIndex(nextIndex);
  }

  Future<void> _restorePlaybackProgressIfNeeded({
    required ShortVideoItem item,
    required OolafVideoController controller,
  }) async {
    final saved = await ShortVideoPlaybackProgressPersistence.load(item.id);
    if (saved == null) {
      return;
    }
    if (saved.positionMillis < 3000 || saved.durationMillis <= 0) {
      return;
    }
    final remain = saved.durationMillis - saved.positionMillis;
    if (remain <= 3000) {
      return;
    }
    await controller.seekTo(Duration(milliseconds: saved.positionMillis));
  }

  Future<void> _persistPlaybackProgress({
    required String videoId,
    required OolafVideoController controller,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastProgressPersistAtMillis < 2000) {
      return;
    }

    final duration = controller.duration.value;
    final position = controller.position.value;
    if (duration <= Duration.zero || position <= Duration.zero) {
      return;
    }

    _lastProgressPersistAtMillis = now;
    await ShortVideoPlaybackProgressPersistence.save(
      ShortVideoPlaybackProgressEntry(
        videoId: videoId,
        positionMillis: position.inMilliseconds,
        durationMillis: duration.inMilliseconds,
        updatedAtMillis: now,
      ),
    );
  }

  Future<void> _showVideoActionSheet(ShortVideoItem item) async {
    await showAppSheet<void>(
      context: context,
      barrierLabel: '视频操作',
      maxHeightFactor: 0.46,
      builder: (sheetContext) {
        final isFavorite = _favoriteVideoIds.contains(item.id);

        Widget actionButton({
          required String label,
          required Future<void> Function() onPressed,
          bool destructive = false,
        }) {
          return SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              alignment: Alignment.centerLeft,
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await onPressed();
              },
              child: Text(
                label,
                style: TextStyle(
                  color: destructive
                      ? CupertinoColors.systemRed
                      : CupertinoColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CupertinoColors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(
              height: 1,
              width: double.infinity,
              child: ColoredBox(color: Color(0xFFE5E5EA)),
            ),
            actionButton(
              label: isFavorite ? '取消喜欢' : '喜欢',
              onPressed: () => _toggleFavorite(item),
            ),
            actionButton(
              label: '稍后再看',
              onPressed: () => _saveWatchLater(item),
            ),
            actionButton(
              label: '复制链接',
              onPressed: () => _copyShareText(item),
            ),
            actionButton(
              label: '离线缓存',
              onPressed: () => _saveOfflineCache(item),
            ),
            actionButton(
              label: '0.75x 播放',
              onPressed: () => _setPlaybackRate(0.75),
            ),
            actionButton(
              label: '1.00x 播放',
              onPressed: () => _setPlaybackRate(1.0),
            ),
            actionButton(
              label: '1.25x 播放',
              onPressed: () => _setPlaybackRate(1.25),
            ),
            actionButton(
              label: '1.50x 播放',
              onPressed: () => _setPlaybackRate(1.5),
            ),
            actionButton(
              label: '2.00x 播放',
              onPressed: () => _setPlaybackRate(2.0),
            ),
            actionButton(
              label: '不感兴趣',
              destructive: true,
              onPressed: () => _markNotInterested(item),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pauseForInterruption() async {
    final activeController = _getActiveController();
    if (activeController?.isPlaying.value == true) {
      _resumeAfterInterruption = true;
    }
    await _persistActivePlaybackProgress();
    await _videoManager.pauseAll();
  }

  Future<void> _resumeIfNeeded() async {
    if (!_resumeAfterInterruption || !_isFeedVisibleInTab || !_isAppActive) {
      return;
    }
    _resumeAfterInterruption = false;
    await _syncAndPlayActive();
  }

  Future<void> ensureInitialLoaded() {
    if (_hasRequestedInitialLoad) {
      return _initialLoadFuture ?? Future<void>.value();
    }
    _hasRequestedInitialLoad = true;

    final future = _loadInitialPage();
    _initialLoadFuture = future.whenComplete(() {
      if (identical(_initialLoadFuture, future)) {
        _initialLoadFuture = null;
      }
    });
    return _initialLoadFuture!;
  }

  bool _restoreCachedTabStateIfAny() {
    final cache = _tabStateCache[_videoManagerOwnerKey];
    if (cache == null || cache.items.isEmpty) {
      return false;
    }

    final maxIndex = cache.items.length - 1;
    final activeIndex = cache.activeIndex.clamp(0, maxIndex);

    _nextPullNum = cache.nextPullNum;
    _hasMore = cache.hasMore;
    _didAutoPlayFirst = true;
    _hasRequestedInitialLoad = true;
    _items = cache.items;
    _activeIndex = activeIndex;
    _videoManager.setSources(_buildVideoSources(cache.items));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      _pageController.jumpToPage(activeIndex);
    });
    if (mounted) {
      setState(() {});
    }
    return true;
  }

  void _cacheCurrentTabState() {
    if (_items.isEmpty) {
      return;
    }

    _tabStateCache[_videoManagerOwnerKey] = _VideoTabCacheState(
      items: List<ShortVideoItem>.unmodifiable(_items),
      activeIndex: _activeIndex,
      nextPullNum: _nextPullNum,
      hasMore: _hasMore,
    );
  }

  void _cacheExplicitTabState({
    required List<ShortVideoItem> items,
    required int activeIndex,
    required int nextPullNum,
    required bool hasMore,
  }) {
    if (items.isEmpty) {
      return;
    }
    _tabStateCache[_videoManagerOwnerKey] = _VideoTabCacheState(
      items: List<ShortVideoItem>.unmodifiable(items),
      activeIndex: activeIndex,
      nextPullNum: nextPullNum,
      hasMore: hasMore,
    );
  }

  void onFeedVisibilityChanged(bool visible) {
    if (_isFeedVisibleInTab == visible) {
      if (visible) {
        _restoreCachedTabStateIfAny();
        ensureInitialLoaded();
      }
      return;
    }
    _isFeedVisibleInTab = visible;
    if (visible) {
      _restoreCachedTabStateIfAny();
      ensureInitialLoaded();
      _resumeIfNeeded();
      return;
    }
    _requestGeneration += 1;
    _cacheCurrentTabState();
    _pauseForInterruption();
  }

  void _unbindActiveVideoStatusListener() {
    final controller = _activeStatusObservedController;
    final listener = _activeStatusListener;
    if (controller != null && listener != null) {
      controller.videoOutputStatus.removeListener(listener);
    }
    _activeStatusObservedController = null;
    _activeStatusListener = null;
  }

  void _unbindActiveVideoProgressListener() {
    final controller = _activeProgressObservedController;
    final listener = _activeProgressListener;
    if (controller != null && listener != null) {
      controller.position.removeListener(listener);
      controller.duration.removeListener(listener);
    }
    _activeProgressObservedController = null;
    _activeProgressListener = null;
  }

  void _bindActiveVideoStatusListenerFor(int index) {
    if (_items.isEmpty || index < 0 || index >= _items.length) {
      _unbindActiveVideoStatusListener();
      return;
    }

    final id = _controllerIdOf(_items[index]);
    final controller = _videoManager.getById(id);
    if (controller == null) {
      _unbindActiveVideoStatusListener();
      return;
    }
    if (identical(_activeStatusObservedController, controller)) {
      return;
    }

    _unbindActiveVideoStatusListener();
    void listener() {
      _onActiveVideoOutputStatusChanged(controller.videoOutputStatus.value);
    }

    _activeStatusObservedController = controller;
    _activeStatusListener = listener;
    controller.videoOutputStatus.addListener(listener);
    _onActiveVideoOutputStatusChanged(controller.videoOutputStatus.value);

    _bindActiveVideoProgressListenerFor(index);
  }

  void _bindActiveVideoProgressListenerFor(int index) {
    if (_items.isEmpty || index < 0 || index >= _items.length) {
      _unbindActiveVideoProgressListener();
      return;
    }

    final id = _controllerIdOf(_items[index]);
    final controller = _videoManager.getById(id);
    if (controller == null) {
      _unbindActiveVideoProgressListener();
      return;
    }
    if (identical(_activeProgressObservedController, controller)) {
      return;
    }

    _unbindActiveVideoProgressListener();
    void listener() {
      _onActiveVideoProgressChanged(videoId: id, controller: controller);
    }

    _activeProgressObservedController = controller;
    _activeProgressListener = listener;
    controller.position.addListener(listener);
    controller.duration.addListener(listener);
    _onActiveVideoProgressChanged(videoId: id, controller: controller);
  }

  Future<void> _onActiveVideoProgressChanged({
    required String videoId,
    required OolafVideoController controller,
  }) async {
    if (!mounted) {
      return;
    }

    await _persistPlaybackProgress(videoId: videoId, controller: controller);

    final store = _store;
    if (store == null) {
      return;
    }
    if (!store.state.shortVideo.autoPlayNextVideo) {
      return;
    }

    final duration = controller.duration.value;
    final position = controller.position.value;
    if (duration <= Duration.zero) {
      return;
    }

    final threshold = duration - const Duration(milliseconds: 320);
    final reachedEnd = position >= threshold;
    if (!reachedEnd) {
      return;
    }
    if (_lastAutoNextTriggeredVideoId == videoId) {
      return;
    }

    _lastAutoNextTriggeredVideoId = videoId;
    await _showNextVideo();
  }

  Future<void> _onActiveVideoOutputStatusChanged(
    OolafVideoOutputStatus status,
  ) async {
    if (!mounted) {
      return;
    }
    if (status != OolafVideoOutputStatus.codecUnsupported) {
      return;
    }
    if (_isAutoSkippingUnsupported) {
      return;
    }

    _isAutoSkippingUnsupported = true;
    try {
      if (_activeIndex < _items.length - 1) {
        await _showNextVideo();
        return;
      }
      if (_activeIndex > 0) {
        await _showPreviousVideo();
      }
    } finally {
      _isAutoSkippingUnsupported = false;
    }
  }

  Future<void> _activateIndex(int index) async {
    if (_items.isEmpty || index < 0 || index >= _items.length) {
      return;
    }
    await _persistActivePlaybackProgress();
    final activeItem = _items[index];

    _activeIndex = index;
    await _recordWatchHistoryIfEnabled(activeItem);
    _lastAutoNextTriggeredVideoId = null;
    _videoManager.setSources(
      _buildVideoSources(_items),
    );
    await _videoManager.setActiveIndex(index);
    final controller = _videoManager.getById(_controllerIdOf(activeItem));
    if (controller != null) {
      await _restorePlaybackProgressIfNeeded(
        item: activeItem,
        controller: controller,
      );
    }
    if (mounted) {
      setState(() {});
    }
    _bindActiveVideoStatusListenerFor(index);
    await _videoManager.playActive();
  }

  Future<void> _showNextVideo() async {
    final target = _activeIndex + 1;

    if (target >= _items.length) {
      return;
    }

    await _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  List<ShortVideoItem> _appendUniqueVideos(
    List<ShortVideoItem> current,
    List<ShortVideoItem> incoming,
  ) {
    if (incoming.isEmpty) {
      return current;
    }

    final merged = <ShortVideoItem>[...current];
    final idSet = current.map((e) => e.id).toSet();
    for (final item in incoming) {
      if (idSet.add(item.id)) {
        merged.add(item);
      }
    }
    return merged;
  }

  Future<void> _loadInitialPage() async {
    if (_isPaging) {
      return;
    }

    final requestGeneration = ++_requestGeneration;
    _isPaging = true;
    _hasMore = true;
    _nextPullNum = _initialPullNum;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final items = await _fetchPage(pullNum: _nextPullNum);
      if (!mounted) {
        return;
      }
      if (requestGeneration != _requestGeneration) {
        return;
      }

      final filteredItems = _filterBlockedVideos(items);
      final hasMore = items.isNotEmpty;
      final nextPullNum = hasMore ? _nextPullNum + 1 : _nextPullNum;
      if (!_isFeedVisibleInTab) {
        _cacheExplicitTabState(
          items: filteredItems,
          activeIndex: 0,
          nextPullNum: nextPullNum,
          hasMore: hasMore,
        );
        _hasMore = hasMore;
        _nextPullNum = nextPullNum;
        _didAutoPlayFirst = false;
        return;
      }

      _nextPullNum = nextPullNum;
      _hasMore = hasMore;

      _items = filteredItems;
      _activeIndex = 0;
      _videoManager.setSources(_buildVideoSources(filteredItems));
      _didAutoPlayFirst = false;
    } finally {
      if (mounted && requestGeneration == _requestGeneration) {
        setState(() {
          _isLoading = false;
        });
        _isPaging = false;
      }
    }
  }

  Future<void> _loadMoreIfNeeded(int currentIndex) async {
    if (_isPaging || !_hasMore) {
      return;
    }

    final requestGeneration = ++_requestGeneration;
    final remaining = _items.length - currentIndex - 1;
    if (remaining > _loadMoreThreshold) {
      return;
    }

    _isPaging = true;
    final pullNum = _nextPullNum;

    try {
      final incoming = await _fetchPage(pullNum: pullNum);
      if (!mounted) {
        return;
      }
      if (requestGeneration != _requestGeneration) {
        return;
      }

      if (incoming.isEmpty) {
        _hasMore = false;
        return;
      }

      final latestItems = _isFeedVisibleInTab
          ? _items
          : (_tabStateCache[_videoManagerOwnerKey]?.items ?? const <ShortVideoItem>[]);
      final merged = _appendUniqueVideos(latestItems, _filterBlockedVideos(incoming));

      if (!_isFeedVisibleInTab) {
        _nextPullNum = pullNum + 1;
        _cacheExplicitTabState(
          items: merged,
          activeIndex: (_tabStateCache[_videoManagerOwnerKey]?.activeIndex ?? 0)
              .clamp(0, merged.length - 1),
          nextPullNum: _nextPullNum,
          hasMore: true,
        );
        return;
      }

      _nextPullNum = pullNum + 1;

      _items = merged;
      _videoManager.setSources(_buildVideoSources(merged));
      if (mounted) {
        setState(() {});
      }
    } finally {
      if (requestGeneration == _requestGeneration) {
        _isPaging = false;
      }
    }
  }

  Future<void> _showPreviousVideo() async {
    final target = _activeIndex - 1;

    if (target < 0) {
      return;
    }

    await _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void initState() {
    super.initState();
    _isFeedVisibleInTab = widget.initialFeedVisible;
    WidgetsBinding.instance.addObserver(this);
    _videoManager.acquire(_videoManagerOwnerKey);
    if (!_isChannelFeed) {
      _dailyOpenNum = nextShortVideoDailyOpenNum();
    }
    _loadFavoriteState();
    _loadBlockedState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = StoreProvider.of<AppState>(context, listen: false);
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
    if (!_didCheckInitialVisibilityLoad) {
      _didCheckInitialVisibilityLoad = true;
      if (_isFeedVisibleInTab) {
        ensureInitialLoaded();
      }
    }
  }

  @override
  void dispose() {
    _cacheCurrentTabState();
    _unbindActiveVideoStatusListener();
    _unbindActiveVideoProgressListener();
    appRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _videoManager.release(_videoManagerOwnerKey);
    super.dispose();
  }

  @override
  void didPushNext() {
    _pauseForInterruption();
  }

  @override
  void didPopNext() {
    _resumeIfNeeded();
  }

  Future<void> _syncAndPlayActive() async {
    if (_items.isEmpty || _activeIndex < 0 || _activeIndex >= _items.length) {
      return;
    }

    _videoManager.setSources(
      _buildVideoSources(_items),
    );
    await _videoManager.setActiveIndex(_activeIndex);
    if (mounted) {
      setState(() {});
    }
    _bindActiveVideoStatusListenerFor(_activeIndex);
    await _videoManager.playActive();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasActive = _isAppActive;
    _isAppActive = state == AppLifecycleState.resumed;

    if (_isAppActive && !wasActive) {
      _resumeIfNeeded();
    } else if (!_isAppActive && wasActive) {
      _pauseForInterruption();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final items = _items;
    final store = _store;
    final shortVideoState = store?.state.shortVideo;
    final preloadPagesCount = shortVideoState?.preloadPagesCount ?? 2;
    final keepWindow = shortVideoState?.keepWindow ?? 1;
    VideoManager.instance.keepWindow = keepWindow;

    if (_isFeedVisibleInTab && !_didAutoPlayFirst && items.isNotEmpty) {
      _didAutoPlayFirst = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _videoManager.setSources(
          _buildVideoSources(items),
        );
        if (_activeIndex >= 0 && _activeIndex < items.length) {
          await _recordWatchHistoryIfEnabled(items[_activeIndex]);
        }
        await _videoManager.setActiveIndex(_activeIndex);
        if (mounted) {
          setState(() {});
        }
        _bindActiveVideoStatusListenerFor(_activeIndex);
        await _videoManager.playActive();
      });
    }

    return ColoredBox(
      color: CupertinoColors.black,
      child: items.isEmpty
          ? Center(
              child: _isLoading
                  ? const CupertinoActivityIndicator(radius: 14)
                  : const Text(
                      '暂无可播放视频',
                      style: TextStyle(color: CupertinoColors.white),
                    ),
            )
          : PreloadPageView.builder(
              controller: _pageController,
              preloadPagesCount: preloadPagesCount,
              scrollDirection: Axis.vertical,
              reverse: false,
              onPageChanged: (index) async {
                await _activateIndex(index);
                await _loadMoreIfNeeded(index);
              },
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final controller = _videoManager.getById(_controllerIdOf(item));

                return RepaintBoundary(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RepaintBoundary(
                        child: ShortVideoPlayerWrapper(
                          controller: controller,
                          fit: shortVideoState?.videoFitMode == 'cover' 
                              ? BoxFit.cover 
                              : BoxFit.contain,
                          onSingleTap: () async {
                            final c = _videoManager.getById(_controllerIdOf(item));
                            if (c == null) return;

                            final isPlaying = c.isPlaying.value;
                            if (isPlaying) {
                              await c.pause();
                            } else {
                              await _videoManager.pauseAll();
                              await c.play();
                            }
                          },
                          onDoubleTap: () async {
                            await _toggleFavorite(item);
                          },
                          onLongPress: () async {
                            await _showVideoActionSheet(item);
                          },
                          onSwipeUp: () async {
                            await _showNextVideo();
                          },
                          onSwipeDown: () async {
                            await _showPreviousVideo();
                          },
                        ),
                      ),
                      RepaintBoundary(
                        child: ShortVideoInteractionOverlay(
                          source: item.source ?? '凤凰网视频',
                          title: item.title,
                          updateTime: item.updateTime ?? '',
                          isFavorite: _favoriteVideoIds.contains(item.id),
                          onTapFavorite: () {
                            _toggleFavorite(item);
                          },
                          onTapComment: () {
                            showShortVideoCommentSheet(context);
                          },
                          onTapShare: () {
                            _copyShareText(item);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _VideoTabCacheState {
  const _VideoTabCacheState({
    required this.items,
    required this.activeIndex,
    required this.nextPullNum,
    required this.hasMore,
  });

  final List<ShortVideoItem> items;
  final int activeIndex;
  final int nextPullNum;
  final bool hasMore;
}

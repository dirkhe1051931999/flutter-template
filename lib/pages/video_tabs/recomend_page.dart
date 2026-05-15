import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/components/short_video/comment_sheet.dart';
import 'package:oolaf_flutted/components/short_video/interaction_overlay.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/router/route_observer.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/short_video/action.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/utils/short_video_watch_history_persistence.dart';
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

  OolafVideoController? _getActiveController() {
    final store = _store;
    if (store == null) {
      return null;
    }
    final items = store.state.shortVideo.items;
    final activeIndex = store.state.shortVideo.activeIndex;
    if (items.isEmpty || activeIndex < 0 || activeIndex >= items.length) {
      return null;
    }
    return _videoManager.getById(items[activeIndex].id);
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
        coverUrl: item.coverUrl,
        videoUrl: item.videoUrl,
        source: item.source,
        watchedAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> _pauseForInterruption() async {
    final activeController = _getActiveController();
    if (activeController?.isPlaying.value == true) {
      _resumeAfterInterruption = true;
    }
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

    final store = _store;
    if (store == null) {
      return false;
    }
    final maxIndex = cache.items.length - 1;
    final activeIndex = cache.activeIndex.clamp(0, maxIndex);

    _nextPullNum = cache.nextPullNum;
    _hasMore = cache.hasMore;
    _didAutoPlayFirst = true;
    _hasRequestedInitialLoad = true;

    store.dispatch(ShortVideoSetItemsAction(cache.items));
    store.dispatch(ShortVideoSetActiveIndexAction(activeIndex));
    _videoManager.setSources(
      cache.items.map((e) => (id: e.id, url: e.videoUrl)).toList(growable: false),
    );
    if (mounted) {
      setState(() {});
    }
    return true;
  }

  void _cacheCurrentTabState() {
    final store = _store;
    if (store == null) {
      return;
    }
    final items = store.state.shortVideo.items;
    if (items.isEmpty) {
      return;
    }

    _tabStateCache[_videoManagerOwnerKey] = _VideoTabCacheState(
      items: List<ShortVideoItem>.unmodifiable(items),
      activeIndex: store.state.shortVideo.activeIndex,
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
    final store = _store;
    if (store == null) {
      _unbindActiveVideoStatusListener();
      return;
    }
    final items = store.state.shortVideo.items;
    if (items.isEmpty || index < 0 || index >= items.length) {
      _unbindActiveVideoStatusListener();
      return;
    }

    final id = items[index].id;
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
    final store = _store;
    if (store == null) {
      _unbindActiveVideoProgressListener();
      return;
    }
    final items = store.state.shortVideo.items;
    if (items.isEmpty || index < 0 || index >= items.length) {
      _unbindActiveVideoProgressListener();
      return;
    }

    final id = items[index].id;
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
      final store = _store;
      if (store == null) {
        return;
      }
      final current = store.state.shortVideo.activeIndex;
      final items = store.state.shortVideo.items;

      if (current < items.length - 1) {
        await _showNextVideo();
        return;
      }
      if (current > 0) {
        await _showPreviousVideo();
      }
    } finally {
      _isAutoSkippingUnsupported = false;
    }
  }

  Future<void> _activateIndex(int index) async {
    final store = _store;
    if (store == null) {
      return;
    }
    final items = store.state.shortVideo.items;

    if (items.isEmpty || index < 0 || index >= items.length) {
      return;
    }
    final activeItem = items[index];

    store.dispatch(ShortVideoSetActiveIndexAction(index));
    await _recordWatchHistoryIfEnabled(activeItem);
    _lastAutoNextTriggeredVideoId = null;
    _videoManager.setSources(
      items.map((e) => (id: e.id, url: e.videoUrl)).toList(growable: false),
    );
    await _videoManager.setActiveIndex(index);
    if (mounted) {
      setState(() {});
    }
    _bindActiveVideoStatusListenerFor(index);
    await _videoManager.playActive();
  }

  Future<void> _showNextVideo() async {
    final store = _store;
    if (store == null) {
      return;
    }
    final current = store.state.shortVideo.activeIndex;
    final target = current + 1;
    final items = store.state.shortVideo.items;

    if (target >= items.length) {
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
    final store = _store;
    if (store == null) {
      return;
    }
    _isPaging = true;
    _hasMore = true;
    _nextPullNum = _initialPullNum;
    store.dispatch(const ShortVideoSetLoadingAction(true));

    try {
      final items = await _fetchPage(pullNum: _nextPullNum);
      if (!mounted) {
        return;
      }
      if (requestGeneration != _requestGeneration) {
        return;
      }

      final hasMore = items.isNotEmpty;
      final nextPullNum = hasMore ? _nextPullNum + 1 : _nextPullNum;
      if (!_isFeedVisibleInTab) {
        _cacheExplicitTabState(
          items: items,
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

      store.dispatch(ShortVideoSetItemsAction(items));
      store.dispatch(const ShortVideoSetActiveIndexAction(0));
      _videoManager.setSources(
        items.map((e) => (id: e.id, url: e.videoUrl)).toList(growable: false),
      );
      _didAutoPlayFirst = false;
    } finally {
      if (mounted && requestGeneration == _requestGeneration) {
        store.dispatch(const ShortVideoSetLoadingAction(false));
        _isPaging = false;
      }
    }
  }

  Future<void> _loadMoreIfNeeded(int currentIndex) async {
    if (_isPaging || !_hasMore) {
      return;
    }

    final requestGeneration = ++_requestGeneration;
    final store = _store;
    if (store == null) {
      return;
    }
    final currentItems = store.state.shortVideo.items;
    final remaining = currentItems.length - currentIndex - 1;
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
          ? store.state.shortVideo.items
          : (_tabStateCache[_videoManagerOwnerKey]?.items ?? const <ShortVideoItem>[]);
      final merged = _appendUniqueVideos(latestItems, incoming);

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

      store.dispatch(ShortVideoSetItemsAction(merged));
      _videoManager.setSources(
        merged.map((e) => (id: e.id, url: e.videoUrl)).toList(growable: false),
      );
    } finally {
      if (requestGeneration == _requestGeneration) {
        _isPaging = false;
      }
    }
  }

  Future<void> _showPreviousVideo() async {
    final store = _store;
    if (store == null) {
      return;
    }
    final current = store.state.shortVideo.activeIndex;
    final target = current - 1;

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
    final store = _store;
    if (store == null) {
      return;
    }
    final index = store.state.shortVideo.activeIndex;
    final items = store.state.shortVideo.items;
    if (items.isEmpty || index < 0 || index >= items.length) {
      return;
    }

    _videoManager.setSources(
      items.map((e) => (id: e.id, url: e.videoUrl)).toList(),
    );
    await _videoManager.setActiveIndex(index);
    if (mounted) {
      setState(() {});
    }
    _bindActiveVideoStatusListenerFor(index);
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
    return StoreConnector<AppState, ShortVideoState>(
      distinct: true,
      converter: (store) => store.state.shortVideo,
      builder: (context, state) {
        final items = state.items;

        if (_isFeedVisibleInTab && !_didAutoPlayFirst && items.isNotEmpty) {
          _didAutoPlayFirst = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            _videoManager.setSources(
              items
                  .map((e) => (id: e.id, url: e.videoUrl))
                  .toList(growable: false),
            );
            final initialIndex = state.activeIndex;
            if (initialIndex >= 0 && initialIndex < items.length) {
              await _recordWatchHistoryIfEnabled(items[initialIndex]);
            }
            await _videoManager.setActiveIndex(state.activeIndex);
            if (mounted) {
              setState(() {});
            }
            _bindActiveVideoStatusListenerFor(state.activeIndex);
            await _videoManager.playActive();
          });
        }

        return ColoredBox(
          color: CupertinoColors.black,
          child: items.isEmpty
              ? Center(
                  child: state.isLoading
                      ? const CupertinoActivityIndicator(radius: 14)
                      : const Text(
                          '暂无可播放视频',
                          style: TextStyle(color: CupertinoColors.white),
                        ),
                )
              : PreloadPageView.builder(
                  controller: _pageController,
                  preloadPagesCount: 2,
                  scrollDirection: Axis.vertical,
                  reverse: false,
                  onPageChanged: (index) async {
                    await _activateIndex(index);
                    await _loadMoreIfNeeded(index);
                  },
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final controller = _videoManager.getById(item.id);

                    return RepaintBoundary(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          RepaintBoundary(
                            child: ShortVideoPlayerWrapper(
                              controller: controller,
                              onSingleTap: () async {
                                final c = _videoManager.getById(item.id);
                                if (c == null) return;

                                final isPlaying = c.isPlaying.value;
                                if (isPlaying) {
                                  await c.pause();
                                } else {
                                  await c.play();
                                }
                              },
                              onDoubleTap: () {},
                              onLongPress: () {},
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
                              onTapComment: () {
                                showShortVideoCommentSheet(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
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

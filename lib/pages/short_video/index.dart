import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/components/short_video/comment_sheet.dart';
import 'package:oolaf_flutted/components/short_video/interaction_overlay.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/short_video/action.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/router/route_observer.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';
import 'package:oolaf_flutted/utils/video_manager.dart';
import 'package:preload_page_view/preload_page_view.dart';

class ShortVideoPage extends StatelessWidget {
  const ShortVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ShortVideoFeed();
  }
}

class _ShortVideoFeed extends StatefulWidget {
  const _ShortVideoFeed();

  @override
  State<_ShortVideoFeed> createState() => _ShortVideoFeedState();
}

class _ShortVideoFeedState extends State<_ShortVideoFeed>
    with WidgetsBindingObserver, RouteAware {
  static const int _loadMoreThreshold = 5;

  final _pageController = PreloadPageController();
  final _videoManager = VideoManager.instance;

  bool _seeded = false;
  bool _isAppActive = true;
  bool _didAutoPlayFirst = false;
  bool _isPaging = false;
  bool _hasMore = true;
  int _nextPullNum = 1;
  int _dailyOpenNum = 1;

  OolafVideoController? _activeStatusObservedController;
  VoidCallback? _activeStatusListener;
  bool _isAutoSkippingUnsupported = false;

  void _unbindActiveVideoStatusListener() {
    final controller = _activeStatusObservedController;
    final listener = _activeStatusListener;
    if (controller != null && listener != null) {
      controller.videoOutputStatus.removeListener(listener);
    }
    _activeStatusObservedController = null;
    _activeStatusListener = null;
  }

  void _bindActiveVideoStatusListenerFor(int index) {
    final store = StoreProvider.of<AppState>(context);
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
      final store = StoreProvider.of<AppState>(context);
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
    final store = StoreProvider.of<AppState>(context);
    final items = store.state.shortVideo.items;

    if (items.isEmpty || index < 0 || index >= items.length) {
      return;
    }

    store.dispatch(ShortVideoSetActiveIndexAction(index));
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
    final store = StoreProvider.of<AppState>(context);
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

    final store = StoreProvider.of<AppState>(context);
    _isPaging = true;
    _hasMore = true;
    _nextPullNum = 1;
    store.dispatch(const ShortVideoSetLoadingAction(true));

    try {
      final items = await getShortVideoPage(
        pullNum: _nextPullNum,
        dailyOpenNum: _dailyOpenNum,
      );
      if (!mounted) {
        return;
      }

      if (items.isNotEmpty) {
        _nextPullNum += 1;
      } else {
        _hasMore = false;
      }

      store.dispatch(ShortVideoSetItemsAction(items));
      store.dispatch(const ShortVideoSetActiveIndexAction(0));
      _videoManager.setSources(
        items.map((e) => (id: e.id, url: e.videoUrl)).toList(growable: false),
      );
      _didAutoPlayFirst = false;
    } finally {
      if (mounted) {
        store.dispatch(const ShortVideoSetLoadingAction(false));
      }
      _isPaging = false;
    }
  }

  Future<void> _loadMoreIfNeeded(int currentIndex) async {
    if (_isPaging || !_hasMore) {
      return;
    }

    final store = StoreProvider.of<AppState>(context);
    final currentItems = store.state.shortVideo.items;
    final remaining = currentItems.length - currentIndex - 1;
    if (remaining > _loadMoreThreshold) {
      return;
    }

    _isPaging = true;
    final pullNum = _nextPullNum;

    try {
      final incoming = await getShortVideoPage(
        pullNum: pullNum,
        dailyOpenNum: _dailyOpenNum,
      );
      if (!mounted) {
        return;
      }

      if (incoming.isEmpty) {
        _hasMore = false;
        return;
      }

      _nextPullNum = pullNum + 1;
      final latestItems = store.state.shortVideo.items;
      final merged = _appendUniqueVideos(latestItems, incoming);

      store.dispatch(ShortVideoSetItemsAction(merged));
      _videoManager.setSources(
        merged.map((e) => (id: e.id, url: e.videoUrl)).toList(growable: false),
      );
    } finally {
      _isPaging = false;
    }
  }

  Future<void> _showPreviousVideo() async {
    final store = StoreProvider.of<AppState>(context);
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
    WidgetsBinding.instance.addObserver(this);
    _videoManager.acquire('short_video');
    _dailyOpenNum = nextShortVideoDailyOpenNum();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _unbindActiveVideoStatusListener();
    appRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _videoManager.release('short_video');
    super.dispose();
  }

  @override
  void didPushNext() {
    _videoManager.pauseAll();
  }

  @override
  void didPopNext() {
    _syncAndPlayActive();
  }

  Future<void> _syncAndPlayActive() async {
    final store = StoreProvider.of<AppState>(context);
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
      // no-op for now
    } else if (!_isAppActive && wasActive) {
      _videoManager.pauseAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ShortVideoState>(
      distinct: true,
      converter: (store) => store.state.shortVideo,
      onInit: (store) {
        if (_seeded) return;
        _seeded = true;
        _loadInitialPage();
      },
      builder: (context, state) {
        final items = state.items;

        if (!_didAutoPlayFirst && items.isNotEmpty) {
          _didAutoPlayFirst = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            _videoManager.setSources(
              items
                  .map((e) => (id: e.id, url: e.videoUrl))
                  .toList(growable: false),
            );
            await _videoManager.setActiveIndex(state.activeIndex);
            if (mounted) {
              setState(() {});
            }
            _bindActiveVideoStatusListenerFor(state.activeIndex);
            await _videoManager.playActive();
          });
        }

        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.black,
          navigationBar: const CupertinoNavigationBar(
            backgroundColor: Color(0x66000000),
            border: null,
            middle: Text(
              '短视频',
              style: TextStyle(color: CupertinoColors.white),
            ),
          ),
          child: SafeArea(
            top: false,
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
                                onDoubleTap: () {
                                  // Like (WIP)
                                },
                                onLongPress: () {
                                  // Menu (WIP)
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
          ),
        );
      },
    );
  }
}

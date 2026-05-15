import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/short_video/interaction_overlay.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/router/route_observer.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';
import 'package:oolaf_flutted/utils/short_video_watch_history_persistence.dart';
import 'package:oolaf_flutted/utils/video_manager.dart';
import 'package:preload_page_view/preload_page_view.dart';

class ShortVideoWatchHistoryPlayPage extends StatefulWidget {
  const ShortVideoWatchHistoryPlayPage({
    super.key,
    required this.entries,
    required this.initialIndex,
  });

  final List<ShortVideoWatchHistoryEntry> entries;
  final int initialIndex;

  @override
  State<ShortVideoWatchHistoryPlayPage> createState() =>
      _ShortVideoWatchHistoryPlayPageState();
}

class _ShortVideoWatchHistoryPlayPageState
    extends State<ShortVideoWatchHistoryPlayPage>
    with WidgetsBindingObserver, RouteAware {
  final PreloadPageController _pageController = PreloadPageController();
  final VideoManager _videoManager = VideoManager.instance;

  late final List<ShortVideoWatchHistoryEntry> _entries;
  late int _activeIndex;

  bool _isAppActive = true;
  bool _resumeAfterInterruption = false;

  OolafVideoController? _activeStatusObservedController;
  VoidCallback? _activeStatusListener;
  bool _isAutoSkippingUnsupported = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videoManager.acquire('short_video_watch_history_route');

    _entries = List<ShortVideoWatchHistoryEntry>.unmodifiable(widget.entries);
    _activeIndex = _entries.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, _entries.length - 1);

    _videoManager.setSources(
      _entries
          .map((entry) => (id: entry.videoId, url: entry.videoUrl))
          .toList(growable: false),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _entries.isEmpty) {
        return;
      }
      _pageController.jumpToPage(_activeIndex);
      await _syncAndPlayActive();
    });
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
    _videoManager.release('short_video_watch_history_route');
    super.dispose();
  }

  OolafVideoController? _getActiveController() {
    if (_entries.isEmpty || _activeIndex < 0 || _activeIndex >= _entries.length) {
      return null;
    }
    return _videoManager.getById(_entries[_activeIndex].videoId);
  }

  Future<void> _pauseForInterruption() async {
    final activeController = _getActiveController();
    if (activeController?.isPlaying.value == true) {
      _resumeAfterInterruption = true;
    }
    await _videoManager.pauseAll();
  }

  Future<void> _resumeIfNeeded() async {
    if (!_resumeAfterInterruption || !_isAppActive) {
      return;
    }
    _resumeAfterInterruption = false;
    await _videoManager.playActive();
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

  void _bindActiveVideoStatusListenerFor(int index) {
    if (_entries.isEmpty || index < 0 || index >= _entries.length) {
      _unbindActiveVideoStatusListener();
      return;
    }

    final id = _entries[index].videoId;
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
    if (!mounted || status != OolafVideoOutputStatus.codecUnsupported) {
      return;
    }
    if (_isAutoSkippingUnsupported) {
      return;
    }

    _isAutoSkippingUnsupported = true;
    try {
      if (_activeIndex < _entries.length - 1) {
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

  Future<void> _syncAndPlayActive() async {
    if (_entries.isEmpty || _activeIndex < 0 || _activeIndex >= _entries.length) {
      return;
    }

    await _videoManager.setActiveIndex(_activeIndex);
    if (mounted) {
      setState(() {});
    }
    _bindActiveVideoStatusListenerFor(_activeIndex);
    await _videoManager.playActive();
  }

  Future<void> _activateIndex(int index) async {
    if (_entries.isEmpty || index < 0 || index >= _entries.length) {
      return;
    }

    _activeIndex = index;
    await _syncAndPlayActive();
  }

  Future<void> _showNextVideo() async {
    final target = _activeIndex + 1;
    if (target >= _entries.length) {
      return;
    }

    await _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
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
  void didPushNext() {
    _pauseForInterruption();
  }

  @override
  void didPopNext() {
    _resumeIfNeeded();
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
    if (_entries.isEmpty) {
      return const CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        child: Center(
          child: Text(
            '暂无可播放历史视频',
            style: TextStyle(color: CupertinoColors.white),
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: PreloadPageView.builder(
        controller: _pageController,
        preloadPagesCount: 2,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) async {
          await _activateIndex(index);
        },
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          final controller = _videoManager.getById(entry.videoId);

          return RepaintBoundary(
            child: Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: ShortVideoPlayerWrapper(
                    controller: controller,
                    onSingleTap: () async {
                      final c = _videoManager.getById(entry.videoId);
                      if (c == null) {
                        return;
                      }

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
                    source: entry.source ?? '观看历史',
                    title: entry.title,
                    onTapComment: () {},
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

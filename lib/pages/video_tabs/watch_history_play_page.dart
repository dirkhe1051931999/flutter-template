import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';
import 'package:oolaf_flutted/components/short_video/interaction_overlay.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/router/route_observer.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/utils/short_video_watch_history_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_collection_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_playback_progress_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_offline_cache_persistence.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';
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
  static const String _videoManagerScope = 'short_video_watch_history_route';
  static const String _controllerIdPrefix = 'short_video_watch_history:';

  final PreloadPageController _pageController = PreloadPageController();
  final VideoManager _videoManager = VideoManager.instance;

  late final List<ShortVideoWatchHistoryEntry> _entries;
  late int _activeIndex;

  bool _isAppActive = true;
  bool _resumeAfterInterruption = false;
  Set<String> _favoriteVideoIds = const <String>{};
  int _lastProgressPersistAtMillis = 0;

  OolafVideoController? _activeStatusObservedController;
  VoidCallback? _activeStatusListener;
  bool _isAutoSkippingUnsupported = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videoManager.acquire(_videoManagerScope);
    _loadFavoriteState();

    _entries = List<ShortVideoWatchHistoryEntry>.unmodifiable(widget.entries);
    _activeIndex = _entries.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, _entries.length - 1);

    _videoManager.setSources(
      _entries
          .map((entry) => (id: _controllerIdOf(entry), url: entry.videoUrl))
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
    _stopHistoryPlayback();
    _videoManager.release(_videoManagerScope);
    super.dispose();
  }

  String _controllerIdOf(ShortVideoWatchHistoryEntry entry) {
    return '$_controllerIdPrefix${entry.videoId}';
  }

  Future<void> _disposeHistoryControllers() async {
    await _videoManager.disposeWhere(
      (id) => id.startsWith(_controllerIdPrefix),
    );
  }

  Future<void> _setPlaybackRate(double rate) async {
    final controller = _getActiveController();
    if (controller == null) {
      return;
    }
    await controller.setPlaybackRate(rate);
  }

  Future<void> _stopHistoryPlayback() async {
    _resumeAfterInterruption = false;
    await _disposeHistoryControllers();
  }

  ShortVideoCollectionEntry _collectionEntryOf(ShortVideoWatchHistoryEntry entry) {
    return ShortVideoCollectionEntry(
      videoId: entry.videoId,
      title: entry.title,
      updateTime: entry.updateTime,
      coverUrl: entry.coverUrl,
      videoUrl: entry.videoUrl,
      source: entry.source,
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

  Future<void> _toggleFavorite(ShortVideoWatchHistoryEntry entry) async {
    const persistence = ShortVideoCollectionPersistence.favorites;
    if (_favoriteVideoIds.contains(entry.videoId)) {
      await persistence.remove(entry.videoId);
    } else {
      await persistence.save(_collectionEntryOf(entry));
    }
    await _loadFavoriteState();
  }

  Future<void> _saveWatchLater(ShortVideoWatchHistoryEntry entry) async {
    await ShortVideoCollectionPersistence.watchLater.save(_collectionEntryOf(entry));
  }

  Future<void> _copyShareText(ShortVideoWatchHistoryEntry entry) async {
    await Clipboard.setData(
      ClipboardData(text: '${entry.title}\n${entry.videoUrl}'),
    );
  }

  Future<void> _saveOfflineCache(ShortVideoWatchHistoryEntry entry) async {
    final cacheEntry = ShortVideoOfflineCacheEntry(
      videoId: entry.videoId,
      title: entry.title,
      updateTime: entry.updateTime,
      coverUrl: entry.coverUrl,
      videoUrl: entry.videoUrl,
      source: entry.source,
      savedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await ShortVideoOfflineCachePersistence.save(cacheEntry);
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

  Future<void> _restorePlaybackProgressIfNeeded({
    required ShortVideoWatchHistoryEntry entry,
    required OolafVideoController controller,
  }) async {
    final saved = await ShortVideoPlaybackProgressPersistence.load(entry.videoId);
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

  Future<void> _persistActivePlaybackProgress() async {
    if (_entries.isEmpty || _activeIndex < 0 || _activeIndex >= _entries.length) {
      return;
    }
    final controller = _getActiveController();
    if (controller == null) {
      return;
    }

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
        videoId: _entries[_activeIndex].videoId,
        positionMillis: position.inMilliseconds,
        durationMillis: duration.inMilliseconds,
        updatedAtMillis: now,
      ),
    );
  }

  Future<void> _showVideoActionSheet(ShortVideoWatchHistoryEntry entry) async {
    await showAppSheet<void>(
      context: context,
      barrierLabel: '视频操作',
      maxHeightFactor: 0.46,
      builder: (sheetContext) {
        final isFavorite = _favoriteVideoIds.contains(entry.videoId);

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
              entry.title,
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
              onPressed: () => _toggleFavorite(entry),
            ),
            actionButton(
              label: '稍后再看',
              onPressed: () => _saveWatchLater(entry),
            ),
            actionButton(
              label: '复制链接',
              onPressed: () => _copyShareText(entry),
            ),
            actionButton(
              label: '离线缓存',
              onPressed: () => _saveOfflineCache(entry),
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
              onPressed: () => _showNextVideo(),
            ),
          ],
        );
      },
    );
  }

  OolafVideoController? _getActiveController() {
    if (_entries.isEmpty || _activeIndex < 0 || _activeIndex >= _entries.length) {
      return null;
    }
    return _videoManager.getById(_controllerIdOf(_entries[_activeIndex]));
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

    final id = _controllerIdOf(_entries[index]);
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
    final controller = _getActiveController();
    if (controller != null) {
      await _restorePlaybackProgressIfNeeded(
        entry: _entries[_activeIndex],
        controller: controller,
      );
    }
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

    await _persistActivePlaybackProgress();
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
  void didPop() {
    _stopHistoryPlayback();
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
    return StoreConnector<AppState, ShortVideoState>(
      distinct: true,
      converter: (store) => store.state.shortVideo,
      builder: (context, shortVideoState) {
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
              final controller = _videoManager.getById(_controllerIdOf(entry));

              return RepaintBoundary(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RepaintBoundary(
                      child: ShortVideoPlayerWrapper(
                        controller: controller,
                        fit: shortVideoState.videoFitMode == 'cover' 
                            ? BoxFit.cover 
                            : BoxFit.contain,
                        onSingleTap: () async {
                          final c = _videoManager.getById(_controllerIdOf(entry));
                          if (c == null) {
                            return;
                          }

                          final isPlaying = c.isPlaying.value;
                          if (isPlaying) {
                            await c.pause();
                          } else {
                            await _videoManager.pauseAll();
                            await c.play();
                          }
                        },
                        onDoubleTap: () {
                          _toggleFavorite(entry);
                        },
                        onLongPress: () {
                          _showVideoActionSheet(entry);
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
                        source: entry.source ?? '观看历史',
                        title: entry.title,
                        updateTime: entry.updateTime,
                        isFavorite: _favoriteVideoIds.contains(entry.videoId),
                        onTapFavorite: () {
                          _toggleFavorite(entry);
                        },
                        onTapComment: () {},
                        onTapShare: () {
                          _copyShareText(entry);
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
}

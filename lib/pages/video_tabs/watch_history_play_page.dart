import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';
import 'package:oolaf_flutted/components/short_video/interaction_overlay.dart';
import 'package:oolaf_flutted/components/short_video/real_comment_sheet.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/router/route_observer.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/utils/short_video_blocked_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_watch_history_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_collection_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_playback_coordinator.dart';
import 'package:oolaf_flutted/utils/short_video_progress_tracker.dart';
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
  final VideoManager _videoManager = VideoManager();
  final ShortVideoPlaybackCoordinator _playbackCoordinator =
      ShortVideoPlaybackCoordinator.instance;

  late final List<ShortVideoWatchHistoryEntry> _entries;
  late int _activeIndex;

  bool _isAppActive = true;
  bool _resumeAfterInterruption = false;
  Set<String> _favoriteVideoIds = const <String>{};
  final ShortVideoProgressTracker _progressTracker =
      ShortVideoProgressTracker();
  double _currentPlaybackRate = 1.0;
  double? _avatarLongPressRestoreRate;
  bool _isProgressInteracting = false;

  OolafVideoController? _activeStatusObservedController;
  VoidCallback? _activeStatusListener;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playbackCoordinator.register(
      scope: _videoManagerScope,
      manager: _videoManager,
    );
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
    _currentPlaybackRate = StoreProvider.of<AppState>(context, listen: false)
        .state
        .shortVideo
        .playbackRate;
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
    unawaited(_stopHistoryPlayback());
    _playbackCoordinator.unregister(_videoManagerScope);
    unawaited(_videoManager.disposeManager());
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
    if (!mounted) {
      return;
    }
    setState(() {
      _currentPlaybackRate = rate;
    });
  }

  Future<void> _handleAvatarLongPressStart() async {
    _avatarLongPressRestoreRate = _currentPlaybackRate;
    if (_currentPlaybackRate >= 1.99) {
      return;
    }
    await _setPlaybackRate(2.0);
  }

  Future<void> _handleAvatarLongPressEnd() async {
    final restoreRate = _avatarLongPressRestoreRate;
    _avatarLongPressRestoreRate = null;
    if (restoreRate == null) {
      return;
    }
    if ((restoreRate - _currentPlaybackRate).abs() < 0.001) {
      return;
    }
    await _setPlaybackRate(restoreRate);
  }

  Future<void> _stopHistoryPlayback() async {
    _resumeAfterInterruption = false;
    await _playbackCoordinator.pause(_videoManagerScope);
    await _disposeHistoryControllers();
  }

  ShortVideoCollectionEntry _collectionEntryOf(
      ShortVideoWatchHistoryEntry entry) {
    return ShortVideoCollectionEntry(
      videoId: entry.videoId,
      title: entry.title,
      updateTime: entry.updateTime,
      coverUrl: entry.coverUrl,
      videoUrl: entry.videoUrl,
      source: entry.source,
      type: entry.type,
      commentsUrl: entry.commentsUrl,
      commentsCount: entry.commentsCount,
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
    await ShortVideoCollectionPersistence.watchLater
        .save(_collectionEntryOf(entry));
  }

  Future<void> _copyShareText(ShortVideoWatchHistoryEntry entry) async {
    await Clipboard.setData(
      ClipboardData(text: '${entry.title}\n${entry.videoUrl}'),
    );
  }

  Future<void> _markNotInterested(
    ShortVideoWatchHistoryEntry entry, {
    required Future<void> Function() persist,
  }) async {
    await persist();
    await _showNextVideo();
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
    final store = StoreProvider.of<AppState>(context, listen: false);
    await _progressTracker.restore(
      enabled: store.state.shortVideo.rememberPlaybackProgress,
      videoId: entry.videoId,
      controller: controller,
    );
  }

  Future<void> _persistActivePlaybackProgress() async {
    if (_entries.isEmpty ||
        _activeIndex < 0 ||
        _activeIndex >= _entries.length) {
      return;
    }
    final controller = _getActiveController();
    if (controller == null) {
      return;
    }

    final store = StoreProvider.of<AppState>(context, listen: false);
    await _progressTracker.save(
      enabled: store.state.shortVideo.rememberPlaybackProgress,
      videoId: _entries[_activeIndex].videoId,
      controller: controller,
      force: true,
    );
  }

  Future<void> _showVideoActionSheet(
    ShortVideoWatchHistoryEntry entry, {
    required double currentPlaybackRate,
  }) async {
    await showAppSheet<void>(
      context: context,
      barrierLabel: '视频操作',
      maxHeightFactor: 1,
      backgroundColor: const Color(0xD9161616),
      enableBlur: true,
      edgeToEdge: true,
      builder: (sheetContext) {
        final isFavorite = _favoriteVideoIds.contains(entry.videoId);
        const speedOptions = <double>[0.75, 1.0, 1.25, 1.5, 2.0];

        Widget sectionTitle(String label) {
          return Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          );
        }

        Widget actionTile({
          required Widget icon,
          required String label,
          required Future<void> Function() onPressed,
          bool isDanger = false,
        }) {
          return CupertinoButton(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            onPressed: () async {
              Navigator.of(sheetContext).pop();
              await onPressed();
            },
            child: Column(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: isDanger
                        ? const Color(0x29FF453A)
                        : const Color(0x29FFFFFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: icon,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDanger
                        ? CupertinoColors.systemRed
                        : CupertinoColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        Widget actionGrid(List<Widget> tiles) {
          return LayoutBuilder(
            builder: (context, constraints) {
              const crossSpacing = 12.0;
              const runSpacing = 14.0;
              final itemWidth = (constraints.maxWidth - crossSpacing * 3) / 4;

              return Wrap(
                spacing: crossSpacing,
                runSpacing: runSpacing,
                children: [
                  for (final tile in tiles)
                    SizedBox(width: itemWidth, child: tile),
                ],
              );
            },
          );
        }

        Widget speedChip(double rate) {
          final selected = (currentPlaybackRate - rate).abs() < 0.001;
          final label = '${rate.toStringAsFixed(2)}x';
          return CupertinoButton(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onPressed: () async {
              await _setPlaybackRate(rate);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    selected ? CupertinoColors.white : const Color(0x29000000),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color:
                      selected ? CupertinoColors.black : CupertinoColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(
                height: 1,
                width: double.infinity,
                child: ColoredBox(color: Color(0x33FFFFFF)),
              ),
              const SizedBox(height: 24),
              sectionTitle('快捷操作'),
              const SizedBox(height: 12),
              actionGrid([
                actionTile(
                  icon: AppAssetIcon(
                    assetName: 'heart',
                    size: 24,
                    color: CupertinoColors.white,
                    fallbackIcon: isFavorite
                        ? CupertinoIcons.heart_slash_fill
                        : CupertinoIcons.heart_fill,
                  ),
                  label: isFavorite ? '取消喜欢' : '喜欢',
                  onPressed: () => _toggleFavorite(entry),
                ),
                actionTile(
                  icon: const AppAssetIcon(
                    assetName: 'time',
                    size: 24,
                    color: CupertinoColors.white,
                    fallbackIcon: CupertinoIcons.time,
                  ),
                  label: '稍后再看',
                  onPressed: () => _saveWatchLater(entry),
                ),
                actionTile(
                  icon: const AppAssetIcon(
                    assetName: 'link',
                    size: 24,
                    color: CupertinoColors.white,
                    fallbackIcon: CupertinoIcons.link,
                  ),
                  label: '复制链接',
                  onPressed: () => _copyShareText(entry),
                ),
                actionTile(
                  icon: const AppAssetIcon(
                    assetName: 'cloud-download',
                    size: 24,
                    color: CupertinoColors.white,
                    fallbackIcon: CupertinoIcons.cloud_download,
                  ),
                  label: '离线缓存',
                  onPressed: () => _saveOfflineCache(entry),
                ),
              ]),
              const SizedBox(height: 24),
              sectionTitle('播放设置'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x29FFFFFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final rate in speedOptions) speedChip(rate),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              sectionTitle('内容管理'),
              const SizedBox(height: 12),
              actionGrid([
                actionTile(
                  icon: const AppAssetIcon(
                    assetName: 'thumbs-down',
                    size: 24,
                    color: CupertinoColors.systemRed,
                    fallbackIcon: CupertinoIcons.hand_thumbsdown_fill,
                  ),
                  label: '不感兴趣',
                  isDanger: true,
                  onPressed: () => _markNotInterested(
                    entry,
                    persist: () => ShortVideoBlockedPersistence.addVideo(
                      entry.videoId,
                    ),
                  ),
                ),
                actionTile(
                  icon: const AppAssetIcon(
                    assetName: 'person-remove',
                    size: 24,
                    color: CupertinoColors.systemRed,
                    fallbackIcon: CupertinoIcons.person_crop_circle_badge_xmark,
                  ),
                  label: '不看该来源',
                  isDanger: true,
                  onPressed: () => _markNotInterested(
                    entry,
                    persist: () => ShortVideoBlockedPersistence.addSource(
                      entry.source,
                    ),
                  ),
                ),
                actionTile(
                  icon: const AppAssetIcon(
                    assetName: 'text-remove',
                    size: 24,
                    color: CupertinoColors.systemRed,
                    fallbackIcon: CupertinoIcons.text_badge_xmark,
                  ),
                  label: '屏蔽标题词',
                  isDanger: true,
                  onPressed: () => _markNotInterested(
                    entry,
                    persist: () => ShortVideoBlockedPersistence.addTitleKeyword(
                      entry.title,
                    ),
                  ),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  OolafVideoController? _getActiveController() {
    if (_entries.isEmpty ||
        _activeIndex < 0 ||
        _activeIndex >= _entries.length) {
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
    await _playbackCoordinator.pause(_videoManagerScope);
  }

  Future<void> _resumeIfNeeded() async {
    if (!_resumeAfterInterruption || !_isAppActive) {
      return;
    }
    _resumeAfterInterruption = false;
    await _syncAndPlayActive();
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
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _retryActiveVideo() async {
    if (_entries.isEmpty ||
        _activeIndex < 0 ||
        _activeIndex >= _entries.length) {
      return;
    }
    await _videoManager.disposeById(_controllerIdOf(_entries[_activeIndex]));
    await _syncAndPlayActive();
  }

  Future<void> _markActiveVideoUnavailable() async {
    if (_entries.isEmpty ||
        _activeIndex < 0 ||
        _activeIndex >= _entries.length) {
      return;
    }
    final entry = _entries[_activeIndex];
    await _markNotInterested(
      entry,
      persist: () => ShortVideoBlockedPersistence.addVideo(entry.videoId),
    );
  }

  Future<void> _syncAndPlayActive() async {
    if (_entries.isEmpty ||
        _activeIndex < 0 ||
        _activeIndex >= _entries.length) {
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
    await _playbackCoordinator.activate(_videoManagerScope);
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
                        onProgressInteractionChanged: (visible) {
                          if (_isProgressInteracting == visible || !mounted) {
                            return;
                          }
                          setState(() {
                            _isProgressInteracting = visible;
                          });
                        },
                        onRetry: _retryActiveVideo,
                        onSkip: _showNextVideo,
                        onCopyLink: () async {
                          await _copyShareText(entry);
                        },
                        onMarkUnavailable: _markActiveVideoUnavailable,
                        fit: shortVideoState.videoFitMode == 'cover'
                            ? BoxFit.cover
                            : BoxFit.contain,
                        onSingleTap: () async {
                          final c =
                              _videoManager.getById(_controllerIdOf(entry));
                          if (c == null) {
                            return;
                          }

                          final isPlaying = c.isPlaying.value;
                          if (isPlaying) {
                            await c.pause();
                          } else {
                            await _videoManager.pauseAll();
                            await _playbackCoordinator.activate(
                              _videoManagerScope,
                            );
                            await c.play();
                          }
                        },
                        onDoubleTap: () {
                          _toggleFavorite(entry);
                        },
                        onLongPress: () {
                          _showVideoActionSheet(
                            entry,
                            currentPlaybackRate: _currentPlaybackRate,
                          );
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
                        hideMetaText: _isProgressInteracting,
                        isFavorite: _favoriteVideoIds.contains(entry.videoId),
                        onTapFavorite: () {
                          _toggleFavorite(entry);
                        },
                        onTapComment: () {
                          showRealShortVideoCommentSheet(
                            context,
                            item: ShortVideoItem(
                              id: entry.videoId,
                              source: entry.source,
                              title: entry.title,
                              updateTime: entry.updateTime,
                              videoUrl: entry.videoUrl,
                              coverUrl: entry.coverUrl,
                              type: entry.type,
                              commentsUrl: entry.commentsUrl,
                              commentsCount: entry.commentsCount,
                            ),
                          );
                        },
                        onTapShare: () {
                          _copyShareText(entry);
                        },
                        commentCountLabel: formatShortVideoCommentCount(
                          int.tryParse(entry.commentsCount) ?? 0,
                        ),
                        onLongPressAvatarStart: () {
                          _handleAvatarLongPressStart();
                        },
                        onLongPressAvatarEnd: () {
                          _handleAvatarLongPressEnd();
                        },
                        isAvatarSpeedActive: _currentPlaybackRate >= 1.99,
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

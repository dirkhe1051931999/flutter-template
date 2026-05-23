import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';
import 'package:oolaf_flutted/components/short_video/comment_sheet.dart';
import 'package:oolaf_flutted/components/short_video/danmaku_overlay.dart';
import 'package:oolaf_flutted/components/short_video/interaction_overlay.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/model/short_video/danmaku_item.dart';
import 'package:oolaf_flutted/router/route_observer.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/short_video/action.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/utils/short_video_blocked_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_watch_history_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_collection_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_playback_coordinator.dart';
import 'package:oolaf_flutted/utils/short_video_progress_tracker.dart';
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
  static const double _pullRefreshTriggerOffset = 88;
  static const double _pullRefreshIndicatorMaxOffset = 86;
  static const double _homeBottomTabBarHeight = 52;
  static const double _progressBarBottomGap = 12;
  static final Map<String, _VideoTabCacheState> _tabStateCache =
      <String, _VideoTabCacheState>{};

  final _pageController = PreloadPageController();
  final _videoManager = VideoManager.instance;
  final _playbackCoordinator = ShortVideoPlaybackCoordinator.instance;

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
  ShortVideoBlockedSnapshot _blockedSnapshot = const ShortVideoBlockedSnapshot(
    videoIds: <String>{},
    sources: <String>{},
    titleKeywords: <String>{},
  );
  final ShortVideoProgressTracker _progressTracker =
      ShortVideoProgressTracker();
  double _pullRefreshIndicatorOffset = 0;
  final Map<String, List<DanmakuItem>> _danmakuCache =
      <String, List<DanmakuItem>>{};
  final Set<String> _danmakuLoadingVideoIds = <String>{};
  bool _isProgressInteracting = false;

  OolafVideoController? _activeStatusObservedController;
  VoidCallback? _activeStatusListener;
  OolafVideoController? _activeProgressObservedController;
  VoidCallback? _activeProgressListener;
  String? _lastAutoNextTriggeredVideoId;

  bool get _isChannelFeed => widget.channelRequest != null;

  ShortVideoItem? get currentActiveItem {
    if (_items.isEmpty || _activeIndex < 0 || _activeIndex >= _items.length) {
      return null;
    }
    return _items[_activeIndex];
  }

  Future<void> pauseForSearchEntry() async {
    final activeController = _getActiveController();
    if (activeController?.isPlaying.value == true) {
      _resumeAfterInterruption = true;
    }
    await _persistActivePlaybackProgress();
    await _playbackCoordinator.pause(_videoManagerOwnerKey);
  }

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

  List<({String id, String url})> _buildVideoSources(
      List<ShortVideoItem> items) {
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
      autoPlayOnEnter: latest.autoPlayOnEnter,
      rememberPlaybackProgress: latest.rememberPlaybackProgress,
      autoPlayNextVideo: latest.autoPlayNextVideo,
      playbackRate: latest.playbackRate,
      preloadPagesCount: latest.preloadPagesCount,
      keepWindow: latest.keepWindow,
      videoFitMode: latest.videoFitMode,
      danmakuEnabled: latest.danmakuEnabled,
      danmakuOpacity: latest.danmakuOpacity,
      danmakuFontScale: latest.danmakuFontScale,
      danmakuFontWeight: latest.danmakuFontWeight,
      danmakuSpeed: latest.danmakuSpeed,
      danmakuArea: latest.danmakuArea,
    );
  }

  double? _avatarLongPressRestoreRate;

  Future<void> _handleAvatarLongPressStart() async {
    final currentRate = _store?.state.shortVideo.playbackRate ?? 1.0;
    _avatarLongPressRestoreRate = currentRate;
    if (currentRate >= 1.99) {
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
    if ((restoreRate - (_store?.state.shortVideo.playbackRate ?? 1.0)).abs() <
        0.001) {
      return;
    }
    await _setPlaybackRate(restoreRate);
  }

  void _handleDanmakuTap(DanmakuItem item) {
    if (!mounted) {
      return;
    }
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('弹幕'),
          content: Text(item.text),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('关闭'),
            ),
          ],
        );
      },
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
      force: true,
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
    await ShortVideoCollectionPersistence.watchLater
        .save(_collectionEntryOf(item));
  }

  Future<void> _copyShareText(ShortVideoItem item) async {
    await Clipboard.setData(
      ClipboardData(text: '${item.title}\n${item.videoUrl}'),
    );
  }

  Future<void> _prefetchDanmakuForIndex(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }
    final item = _items[index];
    final videoId = item.id;
    if (videoId.isEmpty) {
      return;
    }
    if (_danmakuCache.containsKey(videoId) ||
        _danmakuLoadingVideoIds.contains(videoId)) {
      return;
    }

    _danmakuLoadingVideoIds.add(videoId);
    try {
      final items = await getDanmaku(videoId);
      if (!mounted) {
        return;
      }
      _danmakuCache[videoId] = items;
      setState(() {});
    } finally {
      _danmakuLoadingVideoIds.remove(videoId);
    }
  }

  Future<void> _prefetchDanmakuAroundActive() async {
    final current = _activeIndex;
    await _prefetchDanmakuForIndex(current);
    await _prefetchDanmakuForIndex(current + 1);
  }

  void _clearDanmakuCacheForCurrentFeed() {
    _danmakuCache.clear();
    _danmakuLoadingVideoIds.clear();
  }

  Future<void> _loadBlockedState() async {
    final blockedSnapshot = await ShortVideoBlockedPersistence.loadSnapshot();
    if (!mounted) {
      return;
    }
    setState(() {
      _blockedSnapshot = blockedSnapshot;
    });
  }

  List<ShortVideoItem> _filterBlockedVideos(List<ShortVideoItem> items) {
    if (_blockedSnapshot.isEmpty) {
      return items;
    }
    return items
        .where(
          (item) => !_blockedSnapshot.isBlocked(
            videoId: item.id,
            title: item.title,
            source: item.source,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _markNotInterested(
    ShortVideoItem item, {
    required Future<void> Function() persist,
  }) async {
    await persist();
    if (!mounted) {
      return;
    }
    final nextBlocked = await ShortVideoBlockedPersistence.loadSnapshot();

    final nextItems = _items
        .where(
          (element) => !nextBlocked.isBlocked(
            videoId: element.id,
            title: element.title,
            source: element.source,
          ),
        )
        .toList(growable: false);

    if (nextItems.isEmpty) {
      setState(() {
        _blockedSnapshot = nextBlocked;
        _items = const <ShortVideoItem>[];
        _activeIndex = 0;
      });
      await _playbackCoordinator.pause(_videoManagerOwnerKey);
      return;
    }

    final nextIndex = _activeIndex.clamp(0, nextItems.length - 1);
    setState(() {
      _blockedSnapshot = nextBlocked;
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
    await _progressTracker.restore(
      enabled: _store?.state.shortVideo.rememberPlaybackProgress ?? true,
      videoId: item.id,
      controller: controller,
    );
  }

  Future<void> _persistPlaybackProgress({
    required String videoId,
    required OolafVideoController controller,
    bool force = false,
  }) async {
    await _progressTracker.save(
      enabled: _store?.state.shortVideo.rememberPlaybackProgress ?? true,
      videoId: videoId,
      controller: controller,
      force: force,
    );
  }

  Future<void> _showVideoActionSheet(ShortVideoItem item) async {
    await showAppSheet<void>(
      context: context,
      barrierLabel: '视频操作',
      maxHeightFactor: 1,
      backgroundColor: const Color(0xD9161616),
      enableBlur: true,
      edgeToEdge: true,
      builder: (sheetContext) {
        final isFavorite = _favoriteVideoIds.contains(item.id);
        final currentPlaybackRate =
            _store?.state.shortVideo.playbackRate ?? 1.0;
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
          required IconData icon,
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
                  child: Icon(
                    icon,
                    size: 24,
                    color: isDanger
                        ? CupertinoColors.systemRed
                        : CupertinoColors.white,
                  ),
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
                item.title,
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
                  icon: isFavorite
                      ? CupertinoIcons.heart_slash_fill
                      : CupertinoIcons.heart_fill,
                  label: isFavorite ? '取消喜欢' : '喜欢',
                  onPressed: () => _toggleFavorite(item),
                ),
                actionTile(
                  icon: CupertinoIcons.time,
                  label: '稍后再看',
                  onPressed: () => _saveWatchLater(item),
                ),
                actionTile(
                  icon: CupertinoIcons.link,
                  label: '复制链接',
                  onPressed: () => _copyShareText(item),
                ),
                actionTile(
                  icon: CupertinoIcons.cloud_download,
                  label: '离线缓存',
                  onPressed: () => _saveOfflineCache(item),
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
                  icon: CupertinoIcons.hand_thumbsdown_fill,
                  label: '不感兴趣',
                  isDanger: true,
                  onPressed: () => _markNotInterested(
                    item,
                    persist: () => ShortVideoBlockedPersistence.addVideo(
                      item.id,
                    ),
                  ),
                ),
                actionTile(
                  icon: CupertinoIcons.person_crop_circle_badge_xmark,
                  label: '不看该来源',
                  isDanger: true,
                  onPressed: () => _markNotInterested(
                    item,
                    persist: () => ShortVideoBlockedPersistence.addSource(
                      item.source,
                    ),
                  ),
                ),
                actionTile(
                  icon: CupertinoIcons.text_badge_xmark,
                  label: '屏蔽标题词',
                  isDanger: true,
                  onPressed: () => _markNotInterested(
                    item,
                    persist: () => ShortVideoBlockedPersistence.addTitleKeyword(
                      item.title,
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

  Future<void> _pauseForInterruption() async {
    final activeController = _getActiveController();
    if (activeController?.isPlaying.value == true) {
      _resumeAfterInterruption = true;
    }
    await _persistActivePlaybackProgress();
    await _playbackCoordinator.pause(_videoManagerOwnerKey);
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
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _retryActiveVideo() async {
    final item = currentActiveItem;
    if (item == null) {
      return;
    }
    await _videoManager.disposeById(_controllerIdOf(item));
    await _syncAndPlayActive();
  }

  Future<void> _markActiveVideoUnavailable() async {
    final item = currentActiveItem;
    if (item == null) {
      return;
    }
    await _markNotInterested(
      item,
      persist: () => ShortVideoBlockedPersistence.addVideo(item.id),
    );
  }

  void _onTopPullOffsetChanged(double offset) {
    if (_isPaging || _activeIndex != 0) {
      if (_pullRefreshIndicatorOffset != 0 && mounted) {
        setState(() {
          _pullRefreshIndicatorOffset = 0;
        });
      }
      return;
    }

    final positiveOffset = offset > 0 ? offset : 0.0;
    final nextOffset = positiveOffset > _pullRefreshIndicatorMaxOffset
        ? _pullRefreshIndicatorMaxOffset
        : positiveOffset;

    if ((nextOffset - _pullRefreshIndicatorOffset).abs() < 0.5) {
      return;
    }

    if (mounted) {
      setState(() {
        _pullRefreshIndicatorOffset = nextOffset;
      });
    }
  }

  Future<void> _refreshFromTop() async {
    if (_isPaging) {
      return;
    }

    final requestGeneration = ++_requestGeneration;
    _clearDanmakuCacheForCurrentFeed();
    _isPaging = true;
    _hasMore = true;
    _nextPullNum = 1;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final items = await _fetchPage(pullNum: 1);
      if (!mounted) {
        return;
      }
      if (requestGeneration != _requestGeneration) {
        return;
      }

      final filteredItems = _filterBlockedVideos(items);
      final hasMore = items.isNotEmpty;
      final nextPullNum = hasMore ? 2 : 1;

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
      _prefetchDanmakuAroundActive();

      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    } finally {
      if (mounted && requestGeneration == _requestGeneration) {
        setState(() {
          _isLoading = false;
        });
        _isPaging = false;
      }
    }
  }

  Future<void> _activateIndex(int index) async {
    if (_items.isEmpty || index < 0 || index >= _items.length) {
      return;
    }
    await _persistActivePlaybackProgress();
    final activeItem = _items[index];

    _activeIndex = index;
    _prefetchDanmakuAroundActive();
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
    await _playbackCoordinator.activate(_videoManagerOwnerKey);
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
    _clearDanmakuCacheForCurrentFeed();
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
      _prefetchDanmakuAroundActive();
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
          : (_tabStateCache[_videoManagerOwnerKey]?.items ??
              const <ShortVideoItem>[]);
      final merged =
          _appendUniqueVideos(latestItems, _filterBlockedVideos(incoming));

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
      _prefetchDanmakuForIndex(_activeIndex + 1);
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
    _playbackCoordinator.register(
      scope: _videoManagerOwnerKey,
      manager: _videoManager,
    );
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
    _playbackCoordinator.unregister(_videoManagerOwnerKey);
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
    await _playbackCoordinator.activate(_videoManagerOwnerKey);
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
    final canRefreshByPull = !_isLoading && _activeIndex == 0;
    final shouldRefreshByRelease = canRefreshByPull &&
        _pullRefreshIndicatorOffset >= _pullRefreshTriggerOffset;
    final indicatorOpacity = _isLoading
        ? 1.0
        : (_pullRefreshIndicatorOffset / _pullRefreshTriggerOffset)
            .clamp(0.0, 1.0)
            .toDouble();
    VideoManager.instance.keepWindow = keepWindow;
    final shouldAutoPlayOnEnter = _isChannelFeed
        ? true
        : (shortVideoState?.autoPlayOnEnter ?? true);

    if (_isFeedVisibleInTab &&
        shouldAutoPlayOnEnter &&
        !_didAutoPlayFirst &&
        items.isNotEmpty) {
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
        await _playbackCoordinator.activate(_videoManagerOwnerKey);
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
                final progressBarBottomOffset = _homeBottomTabBarHeight +
                    _progressBarBottomGap +
                    MediaQuery.of(context).viewPadding.bottom;

                return RepaintBoundary(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RepaintBoundary(
                        child: ShortVideoPlayerWrapper(
                          controller: controller,
                          progressBarBottomOffset: progressBarBottomOffset,
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
                            await _copyShareText(item);
                          },
                          onMarkUnavailable: _markActiveVideoUnavailable,
                          fit: shortVideoState?.videoFitMode == 'cover'
                              ? BoxFit.cover
                              : BoxFit.contain,
                          onSingleTap: () async {
                            final c =
                                _videoManager.getById(_controllerIdOf(item));
                            if (c == null) return;

                            final isPlaying = c.isPlaying.value;
                            if (isPlaying) {
                              await c.pause();
                            } else {
                              await _videoManager.pauseAll();
                              await _playbackCoordinator.activate(
                                _videoManagerOwnerKey,
                              );
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
                            if (index == 0) {
                              if (_pullRefreshIndicatorOffset > 0 && mounted) {
                                setState(() {
                                  _pullRefreshIndicatorOffset = 0;
                                });
                              }
                              await _refreshFromTop();
                              return;
                            }
                            await _showPreviousVideo();
                          },
                          onVerticalDragOffsetChanged:
                              index == 0 ? _onTopPullOffsetChanged : null,
                        ),
                      ),
                      RepaintBoundary(
                        child: ShortVideoDanmakuOverlay(
                          videoId: item.id,
                          title: item.title,
                          source: item.source ?? '',
                          controller: controller,
                          items: _danmakuCache[item.id],
                          enabled: index == _activeIndex &&
                              (shortVideoState?.danmakuEnabled ?? true),
                          opacity: shortVideoState?.danmakuOpacity ?? 0.82,
                          fontScale: shortVideoState?.danmakuFontScale ?? 1.0,
                          fontWeight: shortVideoState?.danmakuFontWeight ?? 600,
                          speed: shortVideoState?.danmakuSpeed ?? 1.0,
                          areaRatio: shortVideoState?.danmakuArea ?? 0.7,
                          onTapDanmaku: _handleDanmakuTap,
                        ),
                      ),
                      RepaintBoundary(
                        child: ShortVideoInteractionOverlay(
                          avatarUrl: item.avatarUrl,
                          source: item.source ?? '凤凰网视频',
                          title: item.title,
                          updateTime: item.updateTime ?? '',
                          hideMetaText: _isProgressInteracting,
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
                          onLongPressAvatarStart: () {
                            _handleAvatarLongPressStart();
                          },
                          onLongPressAvatarEnd: () {
                            _handleAvatarLongPressEnd();
                          },
                          isAvatarSpeedActive:
                              (shortVideoState?.playbackRate ?? 1.0) >= 1.99,
                        ),
                      ),
                      if (index == 0)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 12,
                          left: 0,
                          right: 0,
                          child: AbsorbPointer(
                            absorbing: true,
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOutCubic,
                              offset: Offset(
                                0,
                                (_isLoading || _pullRefreshIndicatorOffset > 0)
                                    ? 0
                                    : -1.2,
                              ),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 120),
                                opacity: indicatorOpacity,
                                child: Center(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 120),
                                    curve: Curves.easeOut,
                                    transform: Matrix4.translationValues(
                                      0,
                                      _isLoading
                                          ? 0
                                          : _pullRefreshIndicatorOffset * 0.38,
                                      0,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xB2181818),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: const Color(0x33FFFFFF),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_isLoading)
                                          const SizedBox(
                                            height: 14,
                                            width: 14,
                                            child: CupertinoActivityIndicator(
                                              radius: 7,
                                              color: CupertinoColors.white,
                                            ),
                                          )
                                        else
                                          Icon(
                                            shouldRefreshByRelease
                                                ? CupertinoIcons.arrow_up
                                                : CupertinoIcons.arrow_down,
                                            color: CupertinoColors.white,
                                            size: 14,
                                          ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _isLoading
                                              ? '刷新中...'
                                              : (shouldRefreshByRelease
                                                  ? '松手刷新'
                                                  : '下拉刷新'),
                                          style: const TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
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



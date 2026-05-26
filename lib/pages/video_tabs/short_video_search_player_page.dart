import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';
import 'package:oolaf_flutted/components/short_video/interaction_overlay.dart';
import 'package:oolaf_flutted/components/short_video/real_comment_sheet.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/router/route_observer.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';
import 'package:oolaf_flutted/utils/short_video_blocked_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_collection_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_offline_cache_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_playback_coordinator.dart';
import 'package:oolaf_flutted/utils/short_video_progress_tracker.dart';
import 'package:oolaf_flutted/utils/short_video_watch_history_persistence.dart';
import 'package:oolaf_flutted/utils/video_manager.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:redux/redux.dart';

class ShortVideoSearchPlayerPage extends StatefulWidget {
  const ShortVideoSearchPlayerPage({
    super.key,
    required this.keyword,
    required this.initialItems,
    required this.initialIndex,
    required this.initialPage,
    required this.totalPage,
    required this.hasMore,
  });

  final String keyword;
  final List<ShortVideoItem> initialItems;
  final int initialIndex;
  final int initialPage;
  final int totalPage;
  final bool hasMore;

  @override
  State<ShortVideoSearchPlayerPage> createState() =>
      _ShortVideoSearchPlayerPageState();
}

class _ShortVideoSearchPlayerPageState extends State<ShortVideoSearchPlayerPage>
    with WidgetsBindingObserver, RouteAware {
  static const int _loadMoreThreshold = 4;
  static const String _controllerIdPrefix = 'short_video_search:';
  static const double _searchPlayerProgressBarBottomOffset = 16;

  final PreloadPageController _pageController = PreloadPageController();
  final VideoManager _videoManager = VideoManager();
  final ShortVideoPlaybackCoordinator _playbackCoordinator =
      ShortVideoPlaybackCoordinator.instance;

  Store<AppState>? _store;
  late List<ShortVideoItem> _items;
  late bool _hasMore;
  late int _currentPage;
  late int _totalPage;
  late int _activeIndex;
  bool _isLoading = false;
  bool _isPaging = false;
  bool _isAppActive = true;
  bool _resumeAfterInterruption = false;
  bool _didAutoPlayFirst = false;
  int _requestGeneration = 0;
  final ShortVideoProgressTracker _progressTracker =
      ShortVideoProgressTracker();
  double _currentPlaybackRate = 1.0;
  double? _avatarLongPressRestoreRate;
  bool _isProgressInteracting = false;
  Set<String> _favoriteVideoIds = const <String>{};
  ShortVideoBlockedSnapshot _blockedSnapshot = const ShortVideoBlockedSnapshot(
    videoIds: <String>{},
    sources: <String>{},
    titleKeywords: <String>{},
  );

  OolafVideoController? _activeStatusObservedController;
  VoidCallback? _activeStatusListener;
  OolafVideoController? _activeProgressObservedController;
  VoidCallback? _activeProgressListener;
  String? _lastAutoNextTriggeredVideoId;

  ShortVideoItem? get _currentActiveItem {
    if (_items.isEmpty || _activeIndex < 0 || _activeIndex >= _items.length) {
      return null;
    }
    return _items[_activeIndex];
  }

  String _controllerIdOf(ShortVideoItem item) {
    return '$_controllerIdPrefix${item.id}';
  }

  String get _playbackScope =>
      'short_video_search_player_${widget.keyword.hashCode}';

  List<({String id, String url})> _buildVideoSources(
      List<ShortVideoItem> items) {
    return items
        .map((item) => (id: _controllerIdOf(item), url: item.videoUrl))
        .toList(growable: false);
  }

  bool get _isSearchFeedVisible => mounted;

  @override
  void initState() {
    super.initState();
    _items = List<ShortVideoItem>.from(widget.initialItems, growable: false);
    _activeIndex = widget.initialIndex.clamp(
      0,
      widget.initialItems.isEmpty ? 0 : widget.initialItems.length - 1,
    );
    _currentPage = widget.initialPage;
    _totalPage = widget.totalPage;
    _hasMore = widget.hasMore;
    WidgetsBinding.instance.addObserver(this);
    _playbackCoordinator.register(
      scope: _playbackScope,
      manager: _videoManager,
    );
    _loadFavoriteState();
    _loadBlockedState();
    if (_items.isEmpty) {
      _loadSearchPage(1, reset: true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = StoreProvider.of<AppState>(context, listen: false);
    _currentPlaybackRate = _store?.state.shortVideo.playbackRate ?? 1.0;
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _unbindActiveVideoStatusListener();
    _unbindActiveVideoProgressListener();
    appRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _playbackCoordinator.unregister(_playbackScope);
    unawaited(_videoManager.disposeManager());
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

  Future<void> _loadFavoriteState() async {
    final entries = await ShortVideoCollectionPersistence.favorites.loadAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _favoriteVideoIds = entries.map((entry) => entry.videoId).toSet();
    });
  }

  Future<void> _loadBlockedState() async {
    final blockedSnapshot = await ShortVideoBlockedPersistence.loadSnapshot();
    if (!mounted) {
      return;
    }
    final filteredItems = _items.isEmpty
        ? _items
        : _items
            .where(
              (item) => !blockedSnapshot.isBlocked(
                videoId: item.id,
                title: item.title,
                source: item.source,
              ),
            )
            .toList(growable: false);
    setState(() {
      _blockedSnapshot = blockedSnapshot;
      _items = filteredItems;
      if (_items.isNotEmpty) {
        _activeIndex = _activeIndex.clamp(0, _items.length - 1);
      } else {
        _activeIndex = 0;
      }
    });
    _videoManager.setSources(_buildVideoSources(filteredItems));
    if (filteredItems.isEmpty) {
      await _playbackCoordinator.pause(_playbackScope);
    }
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
      await _playbackCoordinator.pause(_playbackScope);
      return;
    }

    setState(() {
      _blockedSnapshot = nextBlocked;
      _items = nextItems;
      _activeIndex = _activeIndex.clamp(0, nextItems.length - 1);
    });
    _videoManager.setSources(_buildVideoSources(nextItems));
    await _videoManager.setActiveIndex(_activeIndex);
    await _playbackCoordinator.activate(_playbackScope);
    await _videoManager.playActive();
  }

  ShortVideoCollectionEntry _collectionEntryOf(ShortVideoItem item) {
    return ShortVideoCollectionEntry(
      videoId: item.id,
      title: item.title,
      updateTime: item.updateTime ?? '',
      coverUrl: item.coverUrl,
      videoUrl: item.videoUrl,
      source: item.source,
      type: item.type,
      commentsUrl: item.commentsUrl,
      commentsCount: item.commentsCount,
      savedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _recordWatchHistoryIfEnabled(ShortVideoItem item) async {
    final store = _store;
    if (store == null || !store.state.shortVideo.recordWatchHistory) {
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
        type: item.type,
        commentsUrl: item.commentsUrl,
        commentsCount: item.commentsCount,
        watchedAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
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
          title: const Text('已加入离线缓存'),
          content: const Text('视频已加入离线缓存列表。'),
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
    final item = _currentActiveItem;
    if (item == null) {
      return;
    }
    final controller = _getActiveController();
    if (controller == null) {
      return;
    }
    await _progressTracker.save(
      enabled: _store?.state.shortVideo.rememberPlaybackProgress ?? true,
      videoId: item.id,
      controller: controller,
      force: true,
    );
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
          final selected = (_currentPlaybackRate - rate).abs() < 0.001;
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
                '${rate.toStringAsFixed(2)}x',
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
                  icon: AppAssetIcon(
                    assetName: 'heart',
                    size: 24,
                    color: CupertinoColors.white,
                    fallbackIcon: isFavorite
                        ? CupertinoIcons.heart_slash_fill
                        : CupertinoIcons.heart_fill,
                  ),
                  label: isFavorite ? '取消喜欢' : '喜欢',
                  onPressed: () => _toggleFavorite(item),
                ),
                actionTile(
                  icon: const AppAssetIcon(
                    assetName: 'time',
                    size: 24,
                    color: CupertinoColors.white,
                    fallbackIcon: CupertinoIcons.time,
                  ),
                  label: '稍后再看',
                  onPressed: () => _saveWatchLater(item),
                ),
                actionTile(
                  icon: const AppAssetIcon(
                    assetName: 'link',
                    size: 24,
                    color: CupertinoColors.white,
                    fallbackIcon: CupertinoIcons.link,
                  ),
                  label: '复制链接',
                  onPressed: () => _copyShareText(item),
                ),
                actionTile(
                  icon: const AppAssetIcon(
                    assetName: 'cloud-download',
                    size: 24,
                    color: CupertinoColors.white,
                    fallbackIcon: CupertinoIcons.cloud_download,
                  ),
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
                  icon: const AppAssetIcon(
                    assetName: 'thumbs-down',
                    size: 24,
                    color: CupertinoColors.systemRed,
                    fallbackIcon: CupertinoIcons.hand_thumbsdown_fill,
                  ),
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
                  icon: const AppAssetIcon(
                    assetName: 'person-remove',
                    size: 24,
                    color: CupertinoColors.systemRed,
                    fallbackIcon: CupertinoIcons.person_crop_circle_badge_xmark,
                  ),
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
                  icon: const AppAssetIcon(
                    assetName: 'text-remove',
                    size: 24,
                    color: CupertinoColors.systemRed,
                    fallbackIcon: CupertinoIcons.text_badge_xmark,
                  ),
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

  Future<void> _loadSearchPage(int page, {bool reset = false}) async {
    if (_isPaging) {
      return;
    }

    final trimmedKeyword = widget.keyword.trim();
    if (trimmedKeyword.isEmpty) {
      return;
    }

    final requestGeneration = ++_requestGeneration;
    _isPaging = true;
    if (mounted) {
      setState(() {
        _isLoading = reset;
      });
    }

    try {
      final result = await getShortVideoSearchPage(
        keyword: trimmedKeyword,
        page: page,
      );
      if (!mounted || requestGeneration != _requestGeneration) {
        return;
      }

      final filteredItems = _filterBlockedVideos(result.items);
      final hasMore = result.hasMore && result.items.isNotEmpty;

      setState(() {
        _items = filteredItems;
        _currentPage = result.currentPage;
        _totalPage = result.totalPage;
        _hasMore = hasMore;
        _activeIndex = 0;
        _didAutoPlayFirst = false;
      });

      _videoManager.setSources(_buildVideoSources(_items));
      if (_items.isNotEmpty && _pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    } finally {
      if (mounted && requestGeneration == _requestGeneration) {
        setState(() {
          _isLoading = false;
        });
      }
      _isPaging = false;
    }
  }

  Future<void> _loadMoreIfNeeded(int currentIndex) async {
    if (_isPaging || !_hasMore) {
      return;
    }

    final remaining = _items.length - currentIndex - 1;
    if (remaining > _loadMoreThreshold) {
      return;
    }

    final nextPage = _currentPage + 1;
    if (nextPage > _totalPage) {
      _hasMore = false;
      return;
    }

    final requestGeneration = ++_requestGeneration;
    _isPaging = true;
    try {
      final result = await getShortVideoSearchPage(
        keyword: widget.keyword.trim(),
        page: nextPage,
      );
      if (!mounted || requestGeneration != _requestGeneration) {
        return;
      }
      if (result.items.isEmpty) {
        _hasMore = false;
        return;
      }

      final merged =
          _appendUniqueVideos(_items, _filterBlockedVideos(result.items));
      setState(() {
        _items = merged;
        _currentPage = result.currentPage;
        _totalPage = result.totalPage;
        _hasMore = result.hasMore;
      });
      _videoManager.setSources(_buildVideoSources(_items));
    } finally {
      if (requestGeneration == _requestGeneration) {
        _isPaging = false;
      }
    }
  }

  List<ShortVideoItem> _appendUniqueVideos(
    List<ShortVideoItem> current,
    List<ShortVideoItem> incoming,
  ) {
    if (incoming.isEmpty) {
      return current;
    }

    final merged = <ShortVideoItem>[...current];
    final idSet = current.map((item) => item.id).toSet();
    for (final item in incoming) {
      if (idSet.add(item.id)) {
        merged.add(item);
      }
    }
    return merged;
  }

  OolafVideoController? _getActiveController() {
    final item = _currentActiveItem;
    if (item == null) {
      return null;
    }
    return _videoManager.getById(_controllerIdOf(item));
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
    if (controller == null ||
        identical(_activeStatusObservedController, controller)) {
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
    if (controller == null ||
        identical(_activeProgressObservedController, controller)) {
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

    await _persistActivePlaybackProgress();
    final store = _store;
    if (store == null || !store.state.shortVideo.autoPlayNextVideo) {
      return;
    }

    final duration = controller.duration.value;
    final position = controller.position.value;
    if (duration <= Duration.zero) {
      return;
    }

    final threshold = duration - const Duration(milliseconds: 320);
    if (position < threshold) {
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
    final item = _currentActiveItem;
    if (item == null) {
      return;
    }
    await _videoManager.disposeById(_controllerIdOf(item));
    await _syncAndPlayActive();
  }

  Future<void> _markActiveVideoUnavailable() async {
    final item = _currentActiveItem;
    if (item == null) {
      return;
    }
    await _markNotInterested(
      item,
      persist: () => ShortVideoBlockedPersistence.addVideo(item.id),
    );
  }

  Future<void> _activateIndex(int index) async {
    if (_items.isEmpty || index < 0 || index >= _items.length) {
      return;
    }
    await _persistActivePlaybackProgress();
    final activeItem = _items[index];

    _activeIndex = index;
    _lastAutoNextTriggeredVideoId = null;
    await _recordWatchHistoryIfEnabled(activeItem);
    _videoManager.setSources(_buildVideoSources(_items));
    await _videoManager.setActiveIndex(index);
    final controller = _videoManager.getById(_controllerIdOf(activeItem));
    if (controller != null) {
      await _restorePlaybackProgressIfNeeded(
        item: activeItem,
        controller: controller,
      );
      await controller.setPlaybackRate(_currentPlaybackRate);
    }
    if (mounted) {
      setState(() {});
    }
    _bindActiveVideoStatusListenerFor(index);
    await _playbackCoordinator.activate(_playbackScope);
    await _videoManager.playActive();
  }

  Future<void> _showNextVideo() async {
    final target = _activeIndex + 1;
    if (target < _items.length) {
      await _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _loadMoreIfNeeded(_activeIndex);
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

  Future<void> _pauseForInterruption() async {
    final activeController = _getActiveController();
    if (activeController?.isPlaying.value == true) {
      _resumeAfterInterruption = true;
    }
    await _persistActivePlaybackProgress();
    await _playbackCoordinator.pause(_playbackScope);
  }

  Future<void> _resumeIfNeeded() async {
    if (!_resumeAfterInterruption || !_isSearchFeedVisible || !_isAppActive) {
      return;
    }
    _resumeAfterInterruption = false;
    await _syncAndPlayActive();
  }

  Future<void> _syncAndPlayActive() async {
    if (_items.isEmpty || _activeIndex < 0 || _activeIndex >= _items.length) {
      return;
    }
    _videoManager.setSources(_buildVideoSources(_items));
    await _videoManager.setActiveIndex(_activeIndex);
    final controller = _getActiveController();
    if (controller != null) {
      await controller.setPlaybackRate(_currentPlaybackRate);
    }
    if (mounted) {
      setState(() {});
    }
    _bindActiveVideoStatusListenerFor(_activeIndex);
    await _playbackCoordinator.activate(_playbackScope);
    await _videoManager.playActive();
  }

  @override
  Widget build(BuildContext context) {
    final shortVideoState = _store?.state.shortVideo;
    final preloadPagesCount = shortVideoState?.preloadPagesCount ?? 2;
    final fit = shortVideoState?.videoFitMode == 'cover'
        ? BoxFit.cover
        : BoxFit.contain;
    _videoManager.keepWindow = shortVideoState?.keepWindow ?? 1;

    if (!_didAutoPlayFirst && _items.isNotEmpty) {
      _didAutoPlayFirst = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_activeIndex);
        }
        await _activateIndex(_activeIndex);
      });
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _items.isEmpty
              ? Center(
                  child: _isLoading
                      ? const CupertinoActivityIndicator(radius: 14)
                      : const Text(
                          '暂无结果',
                          style: TextStyle(color: CupertinoColors.white),
                        ),
                )
              : PreloadPageView.builder(
                  controller: _pageController,
                  preloadPagesCount: preloadPagesCount,
                  scrollDirection: Axis.vertical,
                  itemCount: _items.length,
                  onPageChanged: (index) async {
                    await _activateIndex(index);
                    await _loadMoreIfNeeded(index);
                  },
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final controller =
                        _videoManager.getById(_controllerIdOf(item));
                    return RepaintBoundary(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ShortVideoPlayerWrapper(
                            controller: controller,
                            progressBarBottomOffset:
                                _searchPlayerProgressBarBottomOffset +
                                    MediaQuery.of(context).viewPadding.bottom,
                            onProgressInteractionChanged: (visible) {
                              if (_isProgressInteracting == visible ||
                                  !mounted) {
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
                            fit: fit,
                            onSingleTap: () async {
                              final current =
                                  _videoManager.getById(_controllerIdOf(item));
                              if (current == null) {
                                return;
                              }
                              if (current.isPlaying.value) {
                                await current.pause();
                              } else {
                                await _videoManager.pauseAll();
                                await _playbackCoordinator.activate(
                                  _playbackScope,
                                );
                                await current.play();
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
                          ShortVideoInteractionOverlay(
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
                              showRealShortVideoCommentSheet(
                                context,
                                item: item,
                              );
                            },
                            onTapShare: () {
                              _copyShareText(item);
                            },
                            commentCountLabel: formatShortVideoCommentCount(
                              int.tryParse(item.commentsCount) ?? 0,
                            ),
                            onLongPressAvatarStart: () {
                              _handleAvatarLongPressStart();
                            },
                            onLongPressAvatarEnd: () {
                              _handleAvatarLongPressEnd();
                            },
                            isAvatarSpeedActive: _currentPlaybackRate >= 1.99,
                          ),
                        ],
                      ),
                    );
                  },
                ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const AppAssetIcon(
                    assetName: 'arrow-back',
                    color: CupertinoColors.white,
                    size: 24,
                    fallbackIcon: CupertinoIcons.back,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x33000000),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.keyword,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (_items.isNotEmpty)
                  Text(
                    '${_activeIndex + 1}/${_items.length}',
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

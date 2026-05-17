import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/components/short_video/short_video_bottom_tab_bar.dart';
import 'package:oolaf_flutted/components/video_top_tabs/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/recomend_page.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_channel_manage_page.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_collection_page.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_search_page.dart';
import 'package:oolaf_flutted/pages/video_tabs/watch_history_page.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_offline_cache_page.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/oolaf_music/action.dart';
import 'package:oolaf_flutted/store/short_video/action.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';
import 'package:oolaf_flutted/utils/short_video_blocked_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_collection_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_playback_progress_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_watch_history_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_channel_order_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_preferences_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_search_history_persistence.dart';
import 'package:oolaf_flutted/utils/video_manager.dart';

class ShortVideoPage extends StatefulWidget {
  const ShortVideoPage({super.key});

  @override
  State<ShortVideoPage> createState() => _ShortVideoPageState();
}

class _ShortVideoPageState extends State<ShortVideoPage> {
  static const Duration _homeTabDoubleTapGap = Duration(milliseconds: 320);
  static const Duration _topTabLoadDebounceForTap = Duration(milliseconds: 140);
  static const Duration _topTabLoadDebounceForSwipe = Duration(milliseconds: 260);
  static const List<ShortVideoTabItem> _tabItems = <ShortVideoTabItem>[
    ShortVideoTabItem(label: '首页'),
    ShortVideoTabItem(label: '我'),
  ];

  int _activeTabIndex = 0;
  int _activeHomeTopTabIndex = 0;
  DateTime? _lastHomeTabTapAt;
  bool _isHomeTopTabSwitching = false;
  int _topTabLoadTicket = 0;
  List<String> _channelOrderIds = VideoTabsRegistry.defaultChannelOrderIds;
  final List<GlobalKey<VideoTabRecomendPageState>> _feedPageKeys =
      List<GlobalKey<VideoTabRecomendPageState>>.generate(
        VideoTabsRegistry.feedTabCount,
        (_) => GlobalKey<VideoTabRecomendPageState>(),
      );

  List<VideoTopTabItem> get _homeTabs {
    return VideoTabsRegistry.buildTabs(
      feedPageKeys: _feedPageKeys,
      orderedChannelIds: _channelOrderIds,
    );
  }

  GlobalKey<VideoTabRecomendPageState>? _keyOfTopTab(int index) {
    if (index < 0 || index >= _feedPageKeys.length) {
      return null;
    }
    return _feedPageKeys[index];
  }

  void _syncTopTabVisibility({required int activeIndex}) {
    for (var i = 0; i < _feedPageKeys.length; i += 1) {
      final visible = _activeTabIndex == 0 && i == activeIndex;
      _feedPageKeys[i].currentState?.onFeedVisibilityChanged(visible);
    }
  }

  Future<void> _restoreChannelOrder() async {
    final savedIds = await ShortVideoChannelOrderPersistence.load();
    if (!mounted || savedIds == null || savedIds.isEmpty) {
      return;
    }

    final resolvedIds = VideoTabsRegistry.resolveChannelOrder(savedIds)
        .map((meta) => meta.id)
        .toList(growable: false);
    if (resolvedIds.isEmpty) {
      return;
    }

    setState(() {
      _channelOrderIds = resolvedIds;
      if (_activeHomeTopTabIndex >= _homeTabs.length) {
        _activeHomeTopTabIndex = _homeTabs.length - 1;
      }
    });
  }

  Future<void> _openChannelManagePage() async {
    final currentTabs = _homeTabs;
    final currentActiveId =
        currentTabs[_activeHomeTopTabIndex.clamp(0, currentTabs.length - 1)].id;

    final result = await Navigator.of(context).push<List<String>>(
      CupertinoPageRoute<List<String>>(
        builder: (context) {
          return ShortVideoChannelManagePage(
            initialOrderIds: _channelOrderIds,
          );
        },
      ),
    );

    if (!mounted || result == null || result.isEmpty) {
      return;
    }

    final resolvedIds = VideoTabsRegistry.resolveChannelOrder(result)
        .map((meta) => meta.id)
        .toList(growable: false);
    await ShortVideoChannelOrderPersistence.save(resolvedIds);
    if (!mounted) {
      return;
    }

    setState(() {
      _channelOrderIds = resolvedIds;
      final newTabs = _homeTabs;
      final nextIndex = newTabs.indexWhere((item) => item.id == currentActiveId);
      _activeHomeTopTabIndex = nextIndex < 0 ? 0 : nextIndex;
    });

    _syncTopTabVisibility(activeIndex: _activeHomeTopTabIndex);
    _scheduleEnsureTopTabLoaded(
      _activeHomeTopTabIndex,
      source: VideoTopTabChangeSource.tap,
    );
  }

  Future<void> _openSearchPage() async {
    final activeState = _keyOfTopTab(_activeHomeTopTabIndex)?.currentState;
    await activeState?.pauseForSearchEntry();
    if (!mounted) {
      return;
    }
    final activeItem = activeState?.currentActiveItem;
    final seedTitle = activeItem?.title ?? '热门短视频';
    final seedSource = activeItem?.source;

    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => ShortVideoSearchPage(
          seedTitle: seedTitle,
          seedSource: seedSource,
        ),
      ),
    );
  }

  Future<void> _scheduleEnsureTopTabLoaded(
    int index, {
    required VideoTopTabChangeSource source,
  }) async {
    final debounce = source == VideoTopTabChangeSource.swipe
        ? _topTabLoadDebounceForSwipe
        : _topTabLoadDebounceForTap;
    final ticket = ++_topTabLoadTicket;
    await Future<void>.delayed(debounce);
    if (!mounted || ticket != _topTabLoadTicket) {
      return;
    }
    if (_activeTabIndex != 0 || _activeHomeTopTabIndex != index) {
      return;
    }
    if (_isHomeTopTabSwitching) {
      return;
    }

    _isHomeTopTabSwitching = true;
    try {
      await _keyOfTopTab(index)?.currentState?.ensureInitialLoaded();
    } finally {
      _isHomeTopTabSwitching = false;
    }
  }

  void _onHomeTopTabChanged(int index, VideoTopTabChangeSource source) {
    if (_activeHomeTopTabIndex == index) {
      return;
    }
    _activeHomeTopTabIndex = index;
    _syncTopTabVisibility(activeIndex: index);
    _scheduleEnsureTopTabLoaded(index, source: source);
  }

  @override
  void initState() {
    super.initState();
    _restoreShortVideoPreferences();
    _restoreChannelOrder();
    _pauseMusicForShortVideoEntry();
  }

  Future<void> _pauseMusicForShortVideoEntry() async {
    if (!oolafAudioPlayer.isPlaying) {
      return;
    }

    await oolafAudioPlayer.pause();
    if (!mounted) {
      return;
    }

    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(const OolafSetPlayingAction(false));
    store.dispatch(const OolafSetPlaybackStateAction(OolafPlaybackState.paused));
  }

  Future<void> _exitToHomeHack() async {
    final popped = await Navigator.of(context).maybePop();
    if (!popped && mounted) {
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
    }
  }

  void _onTapBottomTab(int index) {
    if (_activeTabIndex == index) {
      if (index == 0) {
        final now = DateTime.now();
        final isDoubleTap =
            _lastHomeTabTapAt != null &&
            now.difference(_lastHomeTabTapAt!) <= _homeTabDoubleTapGap;
        _lastHomeTabTapAt = now;
        if (isDoubleTap) {
          _exitToHomeHack();
        }
      }
      return;
    }

    setState(() {
      _activeTabIndex = index;
    });

    if (index == 0) {
      _syncTopTabVisibility(activeIndex: _activeHomeTopTabIndex);
      _scheduleEnsureTopTabLoaded(
        _activeHomeTopTabIndex,
        source: VideoTopTabChangeSource.tap,
      );
    } else {
      _syncTopTabVisibility(activeIndex: -1);
    }
  }

  Future<void> _restoreShortVideoPreferences() async {
    final snapshot = await ShortVideoPreferencesPersistence.load();
    if (!mounted || snapshot == null) {
      return;
    }
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(
      ShortVideoRestorePreferencesAction(
        recordWatchHistory: snapshot.recordWatchHistory,
        autoPlayNextVideo: snapshot.autoPlayNextVideo,
        playbackRate: snapshot.playbackRate,
        preloadPagesCount: snapshot.preloadPagesCount,
        keepWindow: snapshot.keepWindow,
        videoFitMode: snapshot.videoFitMode,
        danmakuEnabled: snapshot.danmakuEnabled,
        danmakuOpacity: snapshot.danmakuOpacity,
        danmakuFontScale: snapshot.danmakuFontScale,
        danmakuFontWeight: snapshot.danmakuFontWeight,
        danmakuSpeed: snapshot.danmakuSpeed,
        danmakuArea: snapshot.danmakuArea,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: ShortVideoBottomTabBar.create(
        items: _tabItems,
        currentIndex: _activeTabIndex,
        darkStyle: _activeTabIndex == 0,
        onTap: _onTapBottomTab,
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            if (index == 0) {
              return CupertinoPageScaffold(
                backgroundColor: CupertinoColors.black,
                child: SafeArea(
                  bottom: false,
                  child: VideoTopTabs(
                    items: _homeTabs,
                    initialIndex: _activeHomeTopTabIndex,
                    onIndexChanged: _onHomeTopTabChanged,
                    onTapSearch: _openSearchPage,
                    onTapManage: _openChannelManagePage,
                  ),
                ),
              );
            }
            return const _ShortVideoProfilePage();
          },
        );
      },
    );
  }
}

class _ShortVideoProfilePage extends StatefulWidget {
  const _ShortVideoProfilePage();

  @override
  State<_ShortVideoProfilePage> createState() => _ShortVideoProfilePageState();
}

class _ShortVideoProfilePageState extends State<_ShortVideoProfilePage> {
  static const double _profileHeaderBaseHeight = 144;
  static const double _profileHeaderMaxStretchHeight = 112;
  static const Set<PointerDeviceKind> _dragDevices = <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };

  static const _avatarUrl = 'https://picsum.photos/600/600';
  static const _profileCoverUrl = 'https://picsum.photos/1200/500';

  double _headerStretchHeight = 0;

  bool _handleScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final pixels = notification.metrics.pixels;
    final nextStretch = pixels < 0
        ? (-pixels).clamp(0, _profileHeaderMaxStretchHeight).toDouble()
        : 0.0;
    if ((nextStretch - _headerStretchHeight).abs() < 0.5) {
      return false;
    }
    setState(() {
      _headerStretchHeight = nextStretch;
    });
    return false;
  }

  Future<void> _clearShortVideoCache() async {
    await ShortVideoWatchHistoryPersistence.clearAll();
    await ShortVideoCollectionPersistence.favorites.clearAll();
    await ShortVideoCollectionPersistence.watchLater.clearAll();
    await ShortVideoBlockedPersistence.clearAll();
    await ShortVideoPlaybackProgressPersistence.clearAll();
    await ShortVideoSearchHistoryPersistence.clearAll();
    await VideoManager.instance.disposeAll();

    if (!mounted) {
      return;
    }

    await showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('清理完成'),
          content: const Text('本地缓存、收藏、稍后再看、历史记录与搜索历史已清空。'),
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('我'),
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: SafeArea(
          child: ScrollConfiguration(
            behavior: const CupertinoScrollBehavior().copyWith(
              dragDevices: _dragDevices,
            ),
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              children: [
                Container(
                  height: _profileHeaderBaseHeight + _headerStretchHeight,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(_profileCoverUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x40000000),
                          Color(0x8A000000),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Container(
                            width: 68,
                            height: 68,
                            color: const Color(0x33FFFFFF),
                            child: Image.network(
                              _avatarUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '演示用户',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'ID: oolaf_demo_1024',
                                style: TextStyle(
                                  color: Color(0xB3FFFFFF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                CupertinoListSection(
                  margin: EdgeInsets.zero,
                  backgroundColor: const Color(0xFFF4F5F7),
                  separatorColor: const Color(0xFFF5F5F5),
                  children: [
                    CupertinoListTile(
                      title: const Text('设置'),
                      leading: const Icon(CupertinoIcons.gear_alt_fill),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (_) => const _ShortVideoSettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                CupertinoListSection(
                  margin: const EdgeInsets.only(top: 6),
                  backgroundColor: const Color(0xFFF4F5F7),
                  separatorColor: const Color(0xFFF5F5F5),
                  header: const Text('常用功能'),
                  children: [
                    CupertinoListTile(
                      title: const Text('观看历史'),
                      leading: const Icon(CupertinoIcons.time),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (_) => const ShortVideoWatchHistoryPage(),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      title: const Text('我的喜欢'),
                      leading: const Icon(CupertinoIcons.heart_fill),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (_) => const ShortVideoCollectionPage(
                              title: '我的喜欢',
                              emptyText: '暂无喜欢的视频',
                              persistence: ShortVideoCollectionPersistence.favorites,
                            ),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      title: const Text('离线缓存'),
                      leading: const Icon(CupertinoIcons.arrow_down_circle_fill),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (_) => const ShortVideoOfflineCachePage(),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      title: const Text('稍后再看'),
                      leading: const Icon(CupertinoIcons.bookmark_fill),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (_) => const ShortVideoCollectionPage(
                              title: '稍后再看',
                              emptyText: '暂无稍后观看的视频',
                              persistence: ShortVideoCollectionPersistence.watchLater,
                            ),
                          ),
                        );
                      },
                    ),
                    const CupertinoListTile(
                      title: Text('我的二维码'),
                      leading: Icon(CupertinoIcons.qrcode),
                      trailing: CupertinoListTileChevron(),
                    ),
                    CupertinoListTile(
                      title: const Text('清理缓存'),
                      leading: const Icon(CupertinoIcons.delete_solid),
                      trailing: const CupertinoListTileChevron(),
                      onTap: _clearShortVideoCache,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShortVideoSettingsPage extends StatefulWidget {
  const _ShortVideoSettingsPage();

  @override
  State<_ShortVideoSettingsPage> createState() => _ShortVideoSettingsPageState();
}

class _ShortVideoSettingsPageState extends State<_ShortVideoSettingsPage> {
  static const List<double> _speedOptions = <double>[0.75, 1.0, 1.25, 1.5, 2.0];

  Future<void> _saveLatestPreferences() async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    final latest = store.state.shortVideo;
    await ShortVideoPreferencesPersistence.save(
      recordWatchHistory: latest.recordWatchHistory,
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

  Future<void> _setRecordWatchHistory(bool value) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(ShortVideoSetRecordWatchHistoryAction(value));
    await _saveLatestPreferences();
  }

  Future<void> _setAutoPlayNextVideo(bool value) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(ShortVideoSetAutoPlayNextVideoAction(value));
    await _saveLatestPreferences();
  }

  Future<void> _setPlaybackRate(double value) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(ShortVideoSetPlaybackRateAction(value));
    await _saveLatestPreferences();
  }

  Future<void> _setPreloadStrategy(int preloadPagesCount, int keepWindow) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(
      ShortVideoSetPreloadStrategyAction(
        preloadPagesCount: preloadPagesCount,
        keepWindow: keepWindow,
      ),
    );
    await _saveLatestPreferences();
  }

  Future<void> _setVideoFitMode(String mode) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(ShortVideoSetVideoFitModeAction(mode));
    await _saveLatestPreferences();
  }

  Future<void> _setDanmakuEnabled(bool value) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(ShortVideoSetDanmakuEnabledAction(value));
    await _saveLatestPreferences();
  }

  Future<void> _setDanmakuOpacity(double value) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(ShortVideoSetDanmakuOpacityAction(value.clamp(0.2, 1.0)));
    await _saveLatestPreferences();
  }

  Future<void> _setDanmakuFontScale(double value) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(ShortVideoSetDanmakuFontScaleAction(value.clamp(0.85, 1.4)));
    await _saveLatestPreferences();
  }

  Future<void> _setDanmakuFontWeight(int value) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(ShortVideoSetDanmakuFontWeightAction(value));
    await _saveLatestPreferences();
  }

  Future<void> _setDanmakuSpeed(double value) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(ShortVideoSetDanmakuSpeedAction(value.clamp(0.75, 1.5)));
    await _saveLatestPreferences();
  }

  Future<void> _setDanmakuArea(double value) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(ShortVideoSetDanmakuAreaAction(value.clamp(0.35, 1.0)));
    await _saveLatestPreferences();
  }

  String _preloadLabel(ShortVideoState state) {
    final preload = state.preloadPagesCount;
    final keep = state.keepWindow;
    if (preload <= 0 && keep <= 0) {
      return '省流';
    }
    if (preload == 1 && keep == 1) {
      return '平衡';
    }
    if (preload >= 2 && keep >= 2) {
      return '流畅';
    }
    return '自定义';
  }

  String _fitModeLabel(ShortVideoState state) {
    return state.videoFitMode == 'cover' ? '填充' : '完整';
  }

  Widget _buildDanmakuSliderCard({
    required String title,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9E9ED)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1C1C1E),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    valueText,
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CupertinoSlider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                activeColor: CupertinoColors.activeBlue,
                thumbColor: CupertinoColors.white,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ShortVideoState>(
      distinct: true,
      converter: (store) => store.state.shortVideo,
      builder: (context, shortVideoState) {
        return CupertinoPageScaffold(
          backgroundColor: const Color(0xFFF4F5F7),
          navigationBar: const CupertinoNavigationBar(
            previousPageTitle: '我',
            middle: Text('设置'),
          ),
          child: SafeArea(
            child: ListView(
              children: [
                CupertinoListSection(
                  margin: EdgeInsets.zero,
                  backgroundColor: const Color(0xFFF4F5F7),
                  separatorColor: const Color(0xFFF5F5F5),
                  children: [
                    CupertinoListTile(
                      title: const Text('记录浏览记录'),
                      trailing: CupertinoSwitch(
                        value: shortVideoState.recordWatchHistory,
                        onChanged: _setRecordWatchHistory,
                      ),
                    ),
                    CupertinoListTile(
                      title: const Text('播完自动播放下一个视频'),
                      trailing: CupertinoSwitch(
                        value: shortVideoState.autoPlayNextVideo,
                        onChanged: _setAutoPlayNextVideo,
                      ),
                    ),
                    CupertinoListTile(
                      title: const Text('默认播放速度'),
                      additionalInfo:
                          Text('${shortVideoState.playbackRate.toStringAsFixed(2)}x'),
                      trailing: SizedBox(
                        width: 130,
                        child: CupertinoSlidingSegmentedControl<double>(
                          groupValue: shortVideoState.playbackRate,
                          children: {
                            for (final speed in _speedOptions)
                              speed: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Text('${speed.toStringAsFixed(2)}x'),
                              ),
                          },
                          onValueChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            _setPlaybackRate(value);
                          },
                        ),
                      ),
                    ),
                    CupertinoListTile(
                      title: const Text('预加载策略'),
                      additionalInfo: Text(_preloadLabel(shortVideoState)),
                      trailing: SizedBox(
                        width: 156,
                        child: CupertinoSlidingSegmentedControl<int>(
                          groupValue: switch ((
                            shortVideoState.preloadPagesCount,
                            shortVideoState.keepWindow,
                          )) {
                            (<= 0, <= 0) => 0,
                            (1, 1) => 1,
                            (>= 2, >= 2) => 2,
                            _ => 1,
                          },
                          children: const {
                            0: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text('省流'),
                            ),
                            1: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text('平衡'),
                            ),
                            2: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text('流畅'),
                            ),
                          },
                          onValueChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            if (value == 0) {
                              _setPreloadStrategy(0, 0);
                              return;
                            }
                            if (value == 1) {
                              _setPreloadStrategy(1, 1);
                              return;
                            }
                            _setPreloadStrategy(2, 2);
                          },
                        ),
                      ),
                    ),
                    CupertinoListTile(
                      title: const Text('视频适配模式'),
                      additionalInfo: Text(_fitModeLabel(shortVideoState)),
                      trailing: SizedBox(
                        width: 156,
                        child: CupertinoSlidingSegmentedControl<String>(
                          groupValue: shortVideoState.videoFitMode,
                          children: const {
                            'cover': Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text('填充'),
                            ),
                            'contain': Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text('完整'),
                            ),
                          },
                          onValueChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            _setVideoFitMode(value);
                          },
                        ),
                      ),
                    ),
                    ],
                ),
                CupertinoListSection(
                  margin: const EdgeInsets.only(top: 12),
                  backgroundColor: const Color(0xFFF4F5F7),
                  separatorColor: const Color(0xFFF5F5F5),
                  header: const Text('\u5f39\u5e55\u603b\u63a7'),
                  children: [
                    CupertinoListTile(
                      title: const Text('\u5f39\u5e55\u5f00\u5173'),
                      additionalInfo: Text(
                        shortVideoState.danmakuEnabled ? '已开启' : '已关闭',
                      ),
                      trailing: CupertinoSwitch(
                        value: shortVideoState.danmakuEnabled,
                        onChanged: _setDanmakuEnabled,
                      ),
                    ),
                  ],
                ),
                if (shortVideoState.danmakuEnabled) ...[
                  CupertinoListSection(
                    margin: const EdgeInsets.only(top: 12),
                    backgroundColor: const Color(0xFFF4F5F7),
                    separatorColor: const Color(0xFFF5F5F5),
                    header: const Text('外观设置'),
                    children: [
                      CupertinoListTile(
                        title: const Text('弹幕粗细'),
                        additionalInfo: Text(
                          shortVideoState.danmakuFontWeight >= 700 ? '加粗' : '常规',
                        ),
                        trailing: SizedBox(
                          width: 156,
                          child: CupertinoSlidingSegmentedControl<int>(
                            groupValue:
                                shortVideoState.danmakuFontWeight >= 700 ? 700 : 600,
                            children: const {
                              600: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text('常规'),
                              ),
                              700: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text('加粗'),
                              ),
                            },
                            onValueChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              _setDanmakuFontWeight(value);
                            },
                          ),
                        ),
                      ),
                      _buildDanmakuSliderCard(
                        title: '弹幕透明度',
                        valueText: '${(shortVideoState.danmakuOpacity * 100).round()}%',
                        value: shortVideoState.danmakuOpacity,
                        min: 0.2,
                        max: 1.0,
                        divisions: 16,
                        onChanged: _setDanmakuOpacity,
                      ),
                      _buildDanmakuSliderCard(
                        title: '弹幕字号',
                        valueText: '${shortVideoState.danmakuFontScale.toStringAsFixed(2)}x',
                        value: shortVideoState.danmakuFontScale,
                        min: 0.85,
                        max: 1.4,
                        divisions: 11,
                        onChanged: _setDanmakuFontScale,
                      ),
                    ],
                  ),
                  CupertinoListSection(
                    margin: const EdgeInsets.only(top: 12),
                    backgroundColor: const Color(0xFFF4F5F7),
                    separatorColor: const Color(0xFFF5F5F5),
                    header: const Text('显示范围与节奏'),
                    children: [
                      _buildDanmakuSliderCard(
                        title: '弹幕速度',
                        valueText: '${shortVideoState.danmakuSpeed.toStringAsFixed(2)}x',
                        value: shortVideoState.danmakuSpeed,
                        min: 0.75,
                        max: 1.5,
                        divisions: 15,
                        onChanged: _setDanmakuSpeed,
                      ),
                      _buildDanmakuSliderCard(
                        title: '弹幕显示区域',
                        valueText: '${(shortVideoState.danmakuArea * 100).round()}%',
                        value: shortVideoState.danmakuArea,
                        min: 0.35,
                        max: 1.0,
                        divisions: 13,
                        onChanged: _setDanmakuArea,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

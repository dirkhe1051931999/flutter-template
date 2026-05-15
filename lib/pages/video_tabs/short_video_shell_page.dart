import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/components/short_video/short_video_bottom_tab_bar.dart';
import 'package:oolaf_flutted/components/video_top_tabs/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/recomend_page.dart';
import 'package:oolaf_flutted/pages/video_tabs/watch_history_page.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/oolaf_music/action.dart';
import 'package:oolaf_flutted/store/short_video/action.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';
import 'package:oolaf_flutted/utils/short_video_preferences_persistence.dart';

class ShortVideoPage extends StatefulWidget {
  const ShortVideoPage({super.key});

  @override
  State<ShortVideoPage> createState() => _ShortVideoPageState();
}

class _ShortVideoPageState extends State<ShortVideoPage> {
  static const Duration _homeTabDoubleTapGap = Duration(milliseconds: 320);
  static const List<ShortVideoTabItem> _tabItems = <ShortVideoTabItem>[
    ShortVideoTabItem(label: '首页'),
    ShortVideoTabItem(label: '我'),
  ];

  int _activeTabIndex = 0;
  int _activeHomeTopTabIndex = 0;
  DateTime? _lastHomeTabTapAt;
  final GlobalKey<VideoTabRecomendPageState> _recomendPageKey =
      GlobalKey<VideoTabRecomendPageState>();

  late final List<VideoTopTabItem> _homeTabs = VideoTabsRegistry.buildTabs(
    recomendPageKey: _recomendPageKey,
  );

  void _onHomeTopTabChanged(int index) {
    if (_activeHomeTopTabIndex == index) {
      return;
    }
    _activeHomeTopTabIndex = index;
    final shouldRecommendVisible = _activeTabIndex == 0 && index == 0;
    _recomendPageKey.currentState?.onFeedVisibilityChanged(shouldRecommendVisible);
  }

  @override
  void initState() {
    super.initState();
    _restoreShortVideoPreferences();
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

    final shouldRecommendVisible = index == 0 && _activeHomeTopTabIndex == 0;
    _recomendPageKey.currentState?.onFeedVisibilityChanged(
      shouldRecommendVisible,
    );
    setState(() {
      _activeTabIndex = index;
    });
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
                  header: const Text('常用功能（待开放）'),
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
                    const CupertinoListTile(
                      title: Text('离线缓存'),
                      leading: Icon(CupertinoIcons.arrow_down_circle),
                      trailing: CupertinoListTileChevron(),
                    ),
                    const CupertinoListTile(
                      title: Text('稍后再看'),
                      leading: Icon(CupertinoIcons.clock),
                      trailing: CupertinoListTileChevron(),
                    ),
                    const CupertinoListTile(
                      title: Text('我的二维码'),
                      leading: Icon(CupertinoIcons.qrcode),
                      trailing: CupertinoListTileChevron(),
                    ),
                    const CupertinoListTile(
                      title: Text('清理缓存'),
                      leading: Icon(CupertinoIcons.delete_solid),
                      trailing: CupertinoListTileChevron(),
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
  Future<void> _setRecordWatchHistory(bool value) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(ShortVideoSetRecordWatchHistoryAction(value));

    final latest = store.state.shortVideo;
    await ShortVideoPreferencesPersistence.save(
      recordWatchHistory: latest.recordWatchHistory,
      autoPlayNextVideo: latest.autoPlayNextVideo,
    );
  }

  Future<void> _setAutoPlayNextVideo(bool value) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(ShortVideoSetAutoPlayNextVideoAction(value));

    final latest = store.state.shortVideo;
    await ShortVideoPreferencesPersistence.save(
      recordWatchHistory: latest.recordWatchHistory,
      autoPlayNextVideo: latest.autoPlayNextVideo,
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
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

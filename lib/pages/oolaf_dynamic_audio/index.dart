import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oolaf_flutted/api/oolaf/music.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';
import 'package:oolaf_flutted/components/oolaf_music/music_list.dart';
import 'package:oolaf_flutted/components/oolaf_player/floating_ball.dart';
import 'package:oolaf_flutted/model/oolaf_music/index.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/oolaf_music/action.dart';
import 'package:oolaf_flutted/store/oolaf_music/state.dart';
import 'package:oolaf_flutted/utils/helper.dart';
import 'package:oolaf_flutted/utils/oolaf_music_cache.dart';
import 'package:oolaf_flutted/utils/oolaf_music_favorites.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';
import 'package:oolaf_flutted/utils/oolaf_playback_persistence.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class OolafDynamicAudioPage extends StatefulWidget {
  const OolafDynamicAudioPage({super.key});

  @override
  State<OolafDynamicAudioPage> createState() => _OolafDynamicAudioPageState();
}

class _OolafDynamicAudioPageState extends State<OolafDynamicAudioPage> {
  final GlobalKey<OolafMusicListState> _musicListKey =
      GlobalKey<OolafMusicListState>();
  StreamSubscription<void>? _completedSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<OolafPlaybackState>? _playbackSub;
  StreamSubscription<AppState>? _storeSub;
  Timer? _persistDebounce;
  String? _lastPersistKey;
  Set<String> _favoriteUrls = <String>{};
  int _playByStateToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIndexFromCacheOrRemote();
      _loadFavorites();
      _restorePlayback();
      _subscribePlaybackPersistence();
    });

    _completedSub = oolafAudioPlayer.completedStream.listen((_) {
      _playNextByState();
    });
    _playingSub = oolafAudioPlayer.playingStream.listen((isPlaying) {
      if (!mounted) {
        return;
      }
      StoreProvider.of<AppState>(context).dispatch(
        OolafSetPlayingAction(isPlaying),
      );
    });
    _playbackSub = oolafAudioPlayer.playbackStateStream.listen((state) {
      if (!mounted) {
        return;
      }
      StoreProvider.of<AppState>(context).dispatch(
        OolafSetPlaybackStateAction(state),
      );
    });
  }

  @override
  void dispose() {
    _completedSub?.cancel();
    _playingSub?.cancel();
    _playbackSub?.cancel();
    _storeSub?.cancel();
    _persistDebounce?.cancel();
    super.dispose();
  }

  Future<void> _restorePlayback() async {
    final snapshot = await OolafPlaybackPersistence.load();
    if (!mounted || snapshot == null || snapshot.nowPlaying == null) {
      return;
    }
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(
      OolafRestorePlaybackAction(
        queue: snapshot.queue,
        queueIndex: snapshot.queueIndex,
        queueGroupKey: snapshot.queueGroupKey,
        loopMode: snapshot.loopMode,
        nowPlaying: snapshot.nowPlaying,
      ),
    );
    try {
      await oolafAudioPlayer.setUrl(snapshot.nowPlaying!.cdnUrl);
    } catch (error, stackTrace) {
      customLogger.log('restore playback setUrl failed: $error');
      customLogger.log(stackTrace);
    }
  }

  void _subscribePlaybackPersistence() {
    if (!mounted) {
      return;
    }
    final store = StoreProvider.of<AppState>(context);
    _storeSub = store.onChange.listen(_handlePlaybackPersistence);
    _handlePlaybackPersistence(store.state);
  }

  void _handlePlaybackPersistence(AppState appState) {
    final music = appState.oolafMusic;
    final key =
        '${music.queueGroupKey}|${music.queueIndex}|${music.loopMode.name}|${music.nowPlaying?.cdnUrl ?? ''}|${music.queue.length}';
    if (key == _lastPersistKey) {
      return;
    }
    _lastPersistKey = key;
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 250), () {
      if (music.nowPlaying == null && music.queue.isEmpty) {
        OolafPlaybackPersistence.clear();
        return;
      }
      OolafPlaybackPersistence.save(
        queue: music.queue,
        queueIndex: music.queueIndex,
        queueGroupKey: music.queueGroupKey,
        loopMode: music.loopMode,
        nowPlaying: music.nowPlaying,
      );
    });
  }

  Future<void> _loadFavorites() async {
    final favoriteUrls = await OolafMusicFavorites.readUrls();
    if (!mounted) {
      return;
    }
    setState(() {
      _favoriteUrls = favoriteUrls;
    });
  }

  Future<void> _toggleFavorite(String url) async {
    final favoriteUrls = await OolafMusicFavorites.toggleUrl(url);
    if (!mounted) {
      return;
    }
    setState(() {
      _favoriteUrls = favoriteUrls;
    });
  }

  List<OolafMusicTrackItem> _tracksFromState() {
    final index = StoreProvider.of<AppState>(context).state.oolafMusic.index;
    if (index == null) {
      return const <OolafMusicTrackItem>[];
    }
    return flattenOolafMusicTracks(index.entries);
  }

  Future<void> _locateTrack(OolafMusicTrackItem track) async {
    Navigator.of(context).maybePop();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await _musicListKey.currentState?.locateAndPlay(track);
  }

  void _openSearchSheet() {
    _openTrackPickerSheet(
      title: '搜索音乐',
      emptyText: '输入关键字搜索音乐',
      buildTracks: (keyword) {
        final query = keyword.trim().toLowerCase();
        if (query.isEmpty) {
          return const <OolafMusicTrackItem>[];
        }
        return _tracksFromState()
            .where((track) => track.title.toLowerCase().contains(query))
            .toList();
      },
      showSearchInput: true,
      enableFavoriteToggle: false,
    );
  }

  void _openFavoriteSheet() {
    _openTrackPickerSheet(
      title: '我的收藏',
      emptyText: '暂无收藏音乐',
      buildTracks: (_) {
        return _tracksFromState()
            .where((track) => _favoriteUrls.contains(track.cdnUrl))
            .toList();
      },
      showSearchInput: false,
      enableFavoriteToggle: true,
    );
  }

  void _openTrackPickerSheet({
    required String title,
    required String emptyText,
    required List<OolafMusicTrackItem> Function(String keyword) buildTracks,
    required bool showSearchInput,
    required bool enableFavoriteToggle,
  }) {
    const themeColor = Color(0xFFD43C33);
    var keyword = '';
    showAppSheet<void>(
      context: context,
      barrierLabel: title,
      position: AppSheetPosition.top,
      maxHeightFactor: 0.72,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final tracks = buildTracks(keyword);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .navTitleTextStyle
                            .copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(36, 36),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const AppAssetIcon(
                        assetName: 'close-circle',
                        size: 26,
                        color: Color(0xFF8E8E93),
                        fallbackIcon: CupertinoIcons.xmark_circle_fill,
                      ),
                    ),
                  ],
                ),
                if (showSearchInput)
                  CupertinoSearchTextField(
                    autofocus: true,
                    placeholder: '搜索歌曲名',
                    onChanged: (value) {
                      setSheetState(() {
                        keyword = value;
                      });
                    },
                  ),
                const SizedBox(height: 12),
                Flexible(
                  child: tracks.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              emptyText,
                              style: const TextStyle(
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: tracks.length,
                          separatorBuilder: (_, __) {
                            return Container(
                              height: 1,
                              color: const Color(0x1F3C3C43),
                            );
                          },
                          itemBuilder: (context, index) {
                            final track = tracks[index];
                            final isFavorite =
                                _favoriteUrls.contains(track.cdnUrl);
                            return CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              alignment: Alignment.centerLeft,
                              onPressed: () {
                                _locateTrack(track);
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: AppAssetIcon(
                                      assetName: 'musical-note',
                                      color: themeColor,
                                      size: 18,
                                      fallbackIcon: CupertinoIcons.music_note,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _HighlightedText(
                                          text: track.title,
                                          keyword: keyword,
                                          highlightColor: themeColor,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          track.parentKey == '__root__'
                                              ? '根目录'
                                              : track.parentKey,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: CupertinoColors.systemGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (enableFavoriteToggle)
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(36, 36),
                                      onPressed: () async {
                                        await _toggleFavorite(track.cdnUrl);
                                        setSheetState(() {});
                                      },
                                      child: AppAssetIcon(
                                        assetName: isFavorite ? 'star' : 'star-outline',
                                        color: themeColor,
                                        size: 20,
                                        fallbackIcon: isFavorite
                                            ? CupertinoIcons.star_fill
                                            : CupertinoIcons.star,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _playPrevByState() async {
    final token = ++_playByStateToken;
    final store = StoreProvider.of<AppState>(context);
    try {
      final music = store.state.oolafMusic;
      final queue = music.queue;
      final currentIndex = music.queueIndex;

      if (queue.isEmpty || currentIndex < 0 || currentIndex >= queue.length) {
        store.dispatch(const OolafSetPlayingAction(false));
        return;
      }

      if (music.loopMode == OolafLoopMode.one) {
        final track = queue[currentIndex];
        await oolafAudioPlayer.playUrl(track.cdnUrl);
        if (token != _playByStateToken) {
          return;
        }
        store.dispatch(OolafPlayByQueueIndexAction(currentIndex));
        return;
      }

      final prevIndex = currentIndex - 1;
      if (prevIndex < 0) {
        if (music.loopMode == OolafLoopMode.all) {
          final lastIndex = queue.length - 1;
          final track = queue[lastIndex];
          await oolafAudioPlayer.playUrl(track.cdnUrl);
          if (token != _playByStateToken) {
            return;
          }
          store.dispatch(OolafPlayByQueueIndexAction(lastIndex));
          return;
        }

        store.dispatch(const OolafSetPlayingAction(false));
        return;
      }

      final track = queue[prevIndex];
      await oolafAudioPlayer.playUrl(track.cdnUrl);
      if (token != _playByStateToken) {
        return;
      }
      store.dispatch(OolafPlayByQueueIndexAction(prevIndex));
    } catch (error, stackTrace) {
      if (token != _playByStateToken) {
        return;
      }
      customLogger.log('play prev oolaf music failed: $error');
      customLogger.log(stackTrace);
      store.dispatch(const OolafSetPlayingAction(false));
      EasyLoading.showToast('播放上一首失败');
    }
  }

  Future<void> _playNextByState() async {
    final token = ++_playByStateToken;
    final store = StoreProvider.of<AppState>(context);
    try {
      final music = store.state.oolafMusic;
      final queue = music.queue;
      final currentIndex = music.queueIndex;

      if (queue.isEmpty || currentIndex < 0 || currentIndex >= queue.length) {
        store.dispatch(const OolafSetPlayingAction(false));
        return;
      }

      if (music.loopMode == OolafLoopMode.one) {
        final track = queue[currentIndex];
        await oolafAudioPlayer.playUrl(track.cdnUrl);
        if (token != _playByStateToken) {
          return;
        }
        store.dispatch(
          OolafPlayByQueueIndexAction(currentIndex),
        );
        return;
      }

      final nextIndex = currentIndex + 1;
      if (nextIndex >= queue.length) {
        if (music.loopMode == OolafLoopMode.all) {
          final track = queue[0];
          await oolafAudioPlayer.playUrl(track.cdnUrl);
          if (token != _playByStateToken) {
            return;
          }
          store.dispatch(const OolafPlayByQueueIndexAction(0));
          return;
        }

        await oolafAudioPlayer.stop();
        if (token != _playByStateToken) {
          return;
        }
        store.dispatch(const OolafResetPlaybackAction());
        store.dispatch(
          const OolafSetPlaybackStateAction(OolafPlaybackState.idle),
        );
        return;
      }

      final track = queue[nextIndex];
      await oolafAudioPlayer.playUrl(track.cdnUrl);
      if (token != _playByStateToken) {
        return;
      }
      store.dispatch(OolafPlayByQueueIndexAction(nextIndex));
    } catch (error, stackTrace) {
      if (token != _playByStateToken) {
        return;
      }
      customLogger.log('auto play next oolaf music failed: $error');
      customLogger.log(stackTrace);
      store.dispatch(const OolafSetPlayingAction(false));
      EasyLoading.showToast('播放下一首失败');
    }
  }

  Future<void> _loadIndexFromCacheOrRemote() async {
    final store = StoreProvider.of<AppState>(context);
    final cached = await OolafMusicCache.readRaw();
    if (cached != null) {
      store
          .dispatch(OolafSetMusicIndexAction(OolafMusicIndex.fromJson(cached)));
      return;
    }
    await _refreshIndex();
  }

  Future<void> _refreshIndex() async {
    final store = StoreProvider.of<AppState>(context);
    await oolafAudioPlayer.stop();
    store.dispatch(const OolafResetPlaybackAction());
    store.dispatch(const OolafSetLoadingAction(true));
    try {
      final raw = await getOolafMusicIndexRaw();
      if (raw == null) {
        throw StateError('empty response');
      }
      await OolafMusicCache.writeRaw(raw);
      store.dispatch(OolafSetMusicIndexAction(OolafMusicIndex.fromJson(raw)));
    } catch (error, stackTrace) {
      customLogger.log('load oolaf music index failed: $error');
      customLogger.log(stackTrace);
      EasyLoading.showToast('加载失败');
    } finally {
      store.dispatch(const OolafSetLoadingAction(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFD43C33);
    const headerImageUrl = 'https://picsum.photos/seed/oolaf-music/128/128';
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          primaryColor: themeColor,
        ),
        child: CupertinoPageScaffold(
          backgroundColor: const Color(0xFFF4F5F7),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: CupertinoColors.white,
            border: null,
            leading: Navigator.of(context).canPop()
                ? CupertinoNavigationBarBackButton(
                    color: themeColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                : null,
            middle: const Text(
              'oolaf 动感音频',
              style: TextStyle(color: Color(0xFF1C1C1E)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(36, 36),
                  onPressed: _openFavoriteSheet,
                  child: const AppAssetIcon(
                    assetName: 'star-outline',
                    color: themeColor,
                    size: 20,
                    fallbackIcon: CupertinoIcons.star,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(36, 36),
                  onPressed: _openSearchSheet,
                  child: const AppAssetIcon(
                    assetName: 'search',
                    color: themeColor,
                    size: 20,
                    fallbackIcon: CupertinoIcons.search,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(36, 36),
                  onPressed: _refreshIndex,
                  child: const AppAssetIcon(
                    assetName: 'refresh',
                    color: themeColor,
                    size: 20,
                    fallbackIcon: CupertinoIcons.refresh,
                  ),
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                StoreConnector<AppState, bool>(
                  distinct: true,
                  converter: (store) => store.state.oolafMusic.isLoading,
                  builder: (context, isLoading) {
                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(22),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFE7E7),
                                Color(0xFFFFF6F6),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '你的音乐库',
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .navTitleTextStyle
                                          .copyWith(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1C1C1E),
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      '搜索 / 收藏 / 播放列表都在这里',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(16),
                                ),
                                child: CustomNetworkImage(
                                  headerImageUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox(
                                      width: 64,
                                      height: 64,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(22),
                              ),
                              child: DecoratedBox(
                                decoration: const BoxDecoration(
                                  color: CupertinoColors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x12000000),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: isLoading
                                    ? const Center(
                                        child: CupertinoActivityIndicator(
                                          radius: 12,
                                        ),
                                      )
                                    : OolafMusicList(
                                        key: _musicListKey,
                                        favoriteUrls: _favoriteUrls,
                                        onToggleFavorite: _toggleFavorite,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                OolafFloatingBall(
                  onPrev: _playPrevByState,
                  onNext: _playNextByState,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.keyword,
    required this.highlightColor,
  });

  final String text;
  final String keyword;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    final query = keyword.trim();
    if (query.isEmpty) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final start = lowerText.indexOf(lowerQuery);
    if (start < 0) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final end = start + query.length;
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(
              color: highlightColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }
}

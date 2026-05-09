import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_template_start/api/oolaf/music.dart';
import 'package:flutter_template_start/components/app_sheet/index.dart';
import 'package:flutter_template_start/components/oolaf_music/music_list.dart';
import 'package:flutter_template_start/components/oolaf_player/mini_player.dart';
import 'package:flutter_template_start/components/oolaf_player/player_sheet.dart';
import 'package:flutter_template_start/model/oolaf_music/index.dart';
import 'package:flutter_template_start/store/index.dart';
import 'package:flutter_template_start/store/oolaf_music/action.dart';
import 'package:flutter_template_start/store/oolaf_music/state.dart';
import 'package:flutter_template_start/utils/helper.dart';
import 'package:flutter_template_start/utils/oolaf_music_cache.dart';
import 'package:flutter_template_start/utils/oolaf_music_favorites.dart';
import 'package:flutter_template_start/utils/oolaf_audio_player.dart';
import 'package:flutter_redux/flutter_redux.dart';

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
  Set<String> _favoriteUrls = <String>{};
  bool _isAutoAdvancing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIndexFromCacheOrRemote();
      _loadFavorites();
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
  }

  @override
  void dispose() {
    _completedSub?.cancel();
    _playingSub?.cancel();
    super.dispose();
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                if (showSearchInput)
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: '搜索歌曲名',
                      prefixIcon: Icon(Icons.search),
                    ),
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
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: tracks.length,
                          separatorBuilder: (_, __) {
                            return const Divider(height: 1);
                          },
                          itemBuilder: (context, index) {
                            final track = tracks[index];
                            final isFavorite =
                                _favoriteUrls.contains(track.cdnUrl);
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: _HighlightedText(
                                text: track.title,
                                keyword: keyword,
                                highlightColor: themeColor,
                              ),
                              subtitle: Text(
                                track.parentKey == '__root__'
                                    ? '根目录'
                                    : track.parentKey,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: const Icon(
                                Icons.music_note,
                                color: themeColor,
                              ),
                              trailing: IconButton(
                                onPressed: enableFavoriteToggle
                                    ? () async {
                                        await _toggleFavorite(track.cdnUrl);
                                        setSheetState(() {});
                                      }
                                    : null,
                                icon: Icon(
                                  isFavorite ? Icons.star : Icons.star_border,
                                  color: themeColor,
                                ),
                              ),
                              onTap: () {
                                _locateTrack(track);
                              },
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

  Future<void> _playNextByState() async {
    if (_isAutoAdvancing) {
      return;
    }

    _isAutoAdvancing = true;
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
          store.dispatch(const OolafPlayByQueueIndexAction(0));
          return;
        }

        store.dispatch(const OolafSetPlayingAction(false));
        return;
      }

      final track = queue[nextIndex];
      await oolafAudioPlayer.playUrl(track.cdnUrl);
      store.dispatch(OolafPlayByQueueIndexAction(nextIndex));
    } catch (error, stackTrace) {
      customLogger.log('auto play next oolaf music failed: $error');
      customLogger.log(stackTrace);
      store.dispatch(const OolafSetPlayingAction(false));
      EasyLoading.showToast('播放下一首失败');
    } finally {
      _isAutoAdvancing = false;
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

  void _openPlayerSheet() {
    showAppSheet<void>(
      context: context,
      position: AppSheetPosition.bottom,
      builder: (context) {
        return const OolafPlayerSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFD43C33);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F4),
      appBar: AppBar(
        title: const Text('oolaf 动感音频'),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _openFavoriteSheet,
            icon: const Icon(Icons.star),
          ),
          IconButton(
            onPressed: _openSearchSheet,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: _refreshIndex,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            StoreConnector<AppState, bool>(
              distinct: true,
              converter: (store) => store.state.oolafMusic.isLoading,
              builder: (context, isLoading) {
                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: themeColor,
                                ),
                              )
                            : OolafMusicList(
                                key: _musicListKey,
                                favoriteUrls: _favoriteUrls,
                                onToggleFavorite: _toggleFavorite,
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: OolafMiniPlayer(onOpenPlayer: _openPlayerSheet),
            ),
          ],
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

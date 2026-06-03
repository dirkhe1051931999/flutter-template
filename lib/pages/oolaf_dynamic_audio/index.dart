import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/oolaf_music/music_list.dart';
import 'package:oolaf_flutted/components/oolaf_player/floating_ball.dart';
import 'package:oolaf_flutted/model/oolaf_music/index.dart';
import 'package:oolaf_flutted/pages/oolaf_dynamic_audio/controllers/oolaf_audio_favorites_controller.dart';
import 'package:oolaf_flutted/pages/oolaf_dynamic_audio/controllers/oolaf_audio_page_loader.dart';
import 'package:oolaf_flutted/pages/oolaf_dynamic_audio/controllers/oolaf_audio_playback_controller.dart';
import 'package:oolaf_flutted/pages/oolaf_dynamic_audio/widgets/audio_library_content.dart';
import 'package:oolaf_flutted/pages/oolaf_dynamic_audio/widgets/audio_library_header.dart';
import 'package:oolaf_flutted/pages/oolaf_dynamic_audio/widgets/track_picker_sheet.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class OolafDynamicAudioPage extends StatefulWidget {
  const OolafDynamicAudioPage({super.key});

  @override
  State<OolafDynamicAudioPage> createState() => _OolafDynamicAudioPageState();
}

class _OolafDynamicAudioPageState extends State<OolafDynamicAudioPage> {
  final GlobalKey<OolafMusicListState> _musicListKey =
      GlobalKey<OolafMusicListState>();
  final OolafAudioFavoritesController _favoritesController =
      OolafAudioFavoritesController();
  final OolafAudioPlaybackController _playbackController =
      oolafAudioPlaybackController;
  final OolafAudioPageLoader _pageLoader = OolafAudioPageLoader();

  @override
  void initState() {
    super.initState();
    _favoritesController.addListener(_handleFavoritesChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final store = StoreProvider.of<AppState>(context, listen: false);
      _pageLoader.loadIndexFromCacheOrRemote(store);
      _favoritesController.loadFavorites();
      _playbackController.restorePlayback(store);
    });
  }

  @override
  void dispose() {
    _favoritesController.removeListener(_handleFavoritesChanged);
    _favoritesController.dispose();
    super.dispose();
  }

  void _handleFavoritesChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _toggleFavorite(String url) async {
    await _favoritesController.toggleFavorite(url);
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
            .where((track) => _favoritesController.favoriteUrls.contains(track.cdnUrl))
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
    TrackPickerSheet.show(
      context,
      title: title,
      emptyText: emptyText,
      buildTracks: buildTracks,
      showSearchInput: showSearchInput,
      enableFavoriteToggle: enableFavoriteToggle,
      favoriteUrls: _favoritesController.favoriteUrls,
      onLocateTrack: _locateTrack,
      onToggleFavorite: _toggleFavorite,
    );
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFD43C33);
    const headerImageUrl = 'https://picsum.photos/seed/oolaf-music/128/128';
    final Store<AppState> store = StoreProvider.of<AppState>(
      context,
      listen: false,
    );
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
                  onPressed: () {
                    _pageLoader.refreshIndex(store);
                  },
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
                        const AudioLibraryHeader(
                          headerImageUrl: headerImageUrl,
                        ),
                        AudioLibraryContent(
                          isLoading: isLoading,
                          musicListKey: _musicListKey,
                          favoriteUrls: _favoritesController.favoriteUrls,
                          onToggleFavorite: _toggleFavorite,
                        ),
                      ],
                    );
                  },
                ),
                OolafFloatingBall(
                  onPrev: () {
                    return _playbackController.playPrevByState(store);
                  },
                  onNext: () {
                    return _playbackController.playNextByState(store);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_template_start/model/oolaf_music/index.dart';
import 'package:flutter_template_start/store/index.dart';
import 'package:flutter_template_start/store/oolaf_music/action.dart';
import 'package:flutter_template_start/store/oolaf_music/state.dart';
import 'package:flutter_template_start/utils/oolaf_audio_player.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class OolafMusicListItem {
  const OolafMusicListItem({
    required this.key,
    required this.depth,
    required this.entry,
    required this.isExpanded,
  });

  final String key;
  final int depth;
  final OolafMusicEntry entry;
  final bool isExpanded;

  bool get isFolder => entry.isFolder;
  bool get isFile => entry.isFile;
}

class OolafMusicList extends StatefulWidget {
  const OolafMusicList({
    super.key,
    required this.favoriteUrls,
    required this.onToggleFavorite,
  });

  final Set<String> favoriteUrls;
  final ValueChanged<String> onToggleFavorite;

  @override
  State<OolafMusicList> createState() => OolafMusicListState();
}

class OolafMusicListState extends State<OolafMusicList> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _rowKeys = <String, GlobalKey>{};

  int _playRequestId = 0;

  double _estimatedOffsetForIndex(
    List<OolafMusicListItem> items,
    int rowIndex,
  ) {
    var offset = 0.0;
    for (var i = 0; i < rowIndex; i += 1) {
      offset += items[i].isFile ? 65 : 49;
    }
    return offset;
  }

  String _groupKeyForItem(OolafMusicListItem item) {
    final segments = item.key.split('/');
    if (segments.length <= 1) {
      return '__root__';
    }
    segments.removeLast();
    return segments.join('/');
  }

  List<OolafMusicListItem> _flatten(
    Map<String, OolafMusicEntry> entries,
    Set<String> expandedKeys, {
    required int depth,
    required String parentKey,
  }) {
    final folders = <MapEntry<String, OolafMusicEntry>>[];
    final files = <MapEntry<String, OolafMusicEntry>>[];

    for (final item in entries.entries) {
      if (item.value.isFolder) {
        folders.add(item);
      } else {
        files.add(item);
      }
    }

    int compareByName(
      MapEntry<String, OolafMusicEntry> a,
      MapEntry<String, OolafMusicEntry> b,
    ) {
      return a.key.compareTo(b.key);
    }

    folders.sort(compareByName);
    files.sort(compareByName);

    final result = <OolafMusicListItem>[];

    void appendItem(MapEntry<String, OolafMusicEntry> item) {
      final key = parentKey.isEmpty ? item.key : '$parentKey/${item.key}';
      final isExpanded = expandedKeys.contains(key);
      result.add(
        OolafMusicListItem(
          key: key,
          depth: depth,
          entry: item.value,
          isExpanded: isExpanded,
        ),
      );

      if (item.value.isFolder && isExpanded) {
        final children = item.value.children;
        if (children != null && children.isNotEmpty) {
          result.addAll(
            _flatten(
              children,
              expandedKeys,
              depth: depth + 1,
              parentKey: key,
            ),
          );
        }
      }
    }

    for (final folder in folders) {
      appendItem(folder);
    }
    for (final file in files) {
      appendItem(file);
    }

    return result;
  }

  Future<void> locateAndPlay(OolafMusicTrackItem track) async {
    final store = StoreProvider.of<AppState>(context);
    final music = store.state.oolafMusic;
    final nextExpanded = Set<String>.from(music.expandedKeys)
      ..addAll(track.ancestorKeys);

    store.dispatch(OolafSetExpandedKeysAction(nextExpanded));
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) {
      return;
    }

    final index = store.state.oolafMusic.index;
    if (index == null) {
      return;
    }

    final items = _flatten(
      index.entries,
      store.state.oolafMusic.expandedKeys,
      depth: 0,
      parentKey: '',
    );
    final rowIndex = items.indexWhere((item) => item.key == track.key);
    if (rowIndex >= 0 && _scrollController.hasClients) {
      final rowContext = _rowKeys[track.key]?.currentContext;
      if (rowContext != null) {
        if (!rowContext.mounted) {
          return;
        }
        await Scrollable.ensureVisible(
          rowContext,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: 0.45,
        );
      } else {
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        final offset =
            _estimatedOffsetForIndex(items, rowIndex).clamp(0, maxScrollExtent);
        await _scrollController.animateTo(
          offset.toDouble(),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
        await Future<void>.delayed(const Duration(milliseconds: 40));
        if (!mounted) {
          return;
        }
        final builtRowContext = _rowKeys[track.key]?.currentContext;
        if (builtRowContext != null) {
          if (!builtRowContext.mounted) {
            return;
          }
          await Scrollable.ensureVisible(
            builtRowContext,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: 0.45,
          );
        }
      }
    }

    final isCurrent = store.state.oolafMusic.nowPlaying?.cdnUrl == track.cdnUrl;
    final isPlaying = store.state.oolafMusic.isPlaying;
    if (isCurrent && isPlaying) {
      return;
    }

    await _playTrack(track, items);
  }

  Future<void> _playTrack(
    OolafMusicTrackItem track,
    List<OolafMusicListItem> items,
  ) async {
    final store = StoreProvider.of<AppState>(context);
    final requestId = ++_playRequestId;
    final groupTrackItems = items
        .where((item) => item.isFile)
        .where((item) => _groupKeyForItem(item) == track.parentKey)
        .toList();
    final queue = groupTrackItems
        .map((item) => OolafTrack(
              title: item.entry.displayName,
              cdnUrl: item.entry.cdnUri.toString(),
            ))
        .toList();
    final queueIndex = queue.indexWhere((item) => item.cdnUrl == track.cdnUrl);

    try {
      store.dispatch(const OolafClearTrackLoadingAction());
      store.dispatch(
        OolafSetTrackLoadingAction(cdnUrl: track.cdnUrl, isLoading: true),
      );
      store.dispatch(
        OolafSetNowPlayingAction(
          title: track.title,
          cdnUrl: track.cdnUrl,
          queue: queue,
          queueIndex: queueIndex,
          queueGroupKey: track.parentKey,
        ),
      );

      await oolafAudioPlayer.setUrl(track.cdnUrl);
      if (requestId != _playRequestId) {
        return;
      }
      await oolafAudioPlayer.play();
      if (requestId != _playRequestId) {
        return;
      }

      store.dispatch(
        OolafPlayTrackAction(
          title: track.title,
          cdnUrl: track.cdnUrl,
          queue: queue,
          queueIndex: queueIndex,
          queueGroupKey: track.parentKey,
        ),
      );
    } catch (error) {
      if (requestId == _playRequestId) {
        EasyLoading.showToast('播放失败');
      }
    } finally {
      if (requestId == _playRequestId) {
        store.dispatch(const OolafClearTrackLoadingAction());
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFD43C33);
    return StoreConnector<
        AppState,
        ({
          OolafMusicIndex? index,
          Set<String> expanded,
          String? playingUrl,
          bool isPlaying,
          Set<String> loadingUrls,
        })>(
      distinct: true,
      converter: (store) {
        return (
          index: store.state.oolafMusic.index,
          expanded: store.state.oolafMusic.expandedKeys,
          playingUrl: store.state.oolafMusic.nowPlaying?.cdnUrl,
          isPlaying: store.state.oolafMusic.isPlaying,
          loadingUrls: store.state.oolafMusic.loadingUrls,
        );
      },
      builder: (context, vm) {
        final index = vm.index;
        if (index == null) {
          return const SizedBox.shrink();
        }

        final items = _flatten(
          index.entries,
          vm.expanded,
          depth: 0,
          parentKey: '',
        );

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            final rowKey = _rowKeys.putIfAbsent(item.key, () => GlobalKey());
            final left = 12.0 + item.depth * 12.0;

            final isActive =
                item.isFile && vm.playingUrl == item.entry.cdnUri.toString();
            final isRowLoading = item.isFile &&
                vm.loadingUrls.contains(item.entry.cdnUri.toString());

            return Material(
              key: rowKey,
              color: isActive ? const Color(0xFFFFF4F4) : Colors.white,
              child: InkWell(
                onTap: () async {
                  final store = StoreProvider.of<AppState>(context);
                  if (item.isFolder) {
                    store.dispatch(OolafToggleFolderExpandedAction(item.key));
                    return;
                  }

                  final url = item.entry.cdnUri.toString();
                  if (vm.playingUrl == url && vm.isPlaying) {
                    return;
                  }

                  await _playTrack(
                    OolafMusicTrackItem(
                      key: item.key,
                      parentKey: _groupKeyForItem(item),
                      ancestorKeys: item.key
                          .split('/')
                          .take(item.key.split('/').length - 1)
                          .fold<List<String>>(<String>[], (keys, segment) {
                        final next =
                            keys.isEmpty ? segment : '${keys.last}/$segment';
                        return <String>[...keys, next];
                      }),
                      entry: item.entry,
                    ),
                    items,
                  );
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(left, 14, 12, 14),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF0F0F0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (item.isFolder)
                        Icon(
                          item.isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          size: 20,
                          color: Colors.black54,
                        )
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.entry.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: isActive ? themeColor : null,
                                fontWeight: isActive ? FontWeight.w600 : null,
                              ),
                        ),
                      ),
                      if (item.isFile)
                        IconButton(
                          onPressed: () {
                            widget.onToggleFavorite(
                              item.entry.cdnUri.toString(),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: Icon(
                            widget.favoriteUrls
                                    .contains(item.entry.cdnUri.toString())
                                ? Icons.star
                                : Icons.star_border,
                            size: 20,
                            color: themeColor,
                          ),
                        ),
                      if (item.isFile)
                        isActive
                            ? vm.isPlaying
                                ? const Icon(
                                    Icons.pause_circle_filled,
                                    size: 22,
                                    color: themeColor,
                                  )
                                : const Icon(
                                    Icons.play_circle_outline,
                                    size: 22,
                                    color: themeColor,
                                  )
                            : isRowLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: themeColor,
                                    ),
                                  )
                                : const Icon(
                                    Icons.play_circle_outline,
                                    size: 22,
                                    color: themeColor,
                                  ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/model/oolaf_music/index.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/oolaf_music/action.dart';
import 'package:oolaf_flutted/store/oolaf_music/state.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';
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

  List<OolafMusicListItem> _lastItems = const <OolafMusicListItem>[];
  Timer? _prefetchDebounce;

  int _playRequestId = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollPrefetch);
  }

  void _onScrollPrefetch() {
    _prefetchDebounce?.cancel();
    _prefetchDebounce = Timer(const Duration(milliseconds: 160), () {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      final items = _lastItems;
      if (items.isEmpty) {
        return;
      }

      final offset = _scrollController.offset;
      final approxIndex = (offset / 60.0).floor().clamp(0, items.length - 1);

      var prefetched = 0;
      for (var i = approxIndex; i < items.length && prefetched < 3; i += 1) {
        final item = items[i];
        if (!item.isFile) {
          continue;
        }
        final url = item.entry.cdnUri.toString();
        oolafAudioPlayer.prefetchUrl(url);
        prefetched += 1;
      }
    });
  }

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
    _prefetchDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<
        AppState,
        ({
          OolafMusicIndex? index,
          Set<String> expanded,
          String? playingUrl,
          bool isPlaying,
          OolafPlaybackState playbackState,
          Set<String> loadingUrls,
        })>(
      distinct: true,
      converter: (store) {
        return (
          index: store.state.oolafMusic.index,
          expanded: store.state.oolafMusic.expandedKeys,
          playingUrl: store.state.oolafMusic.nowPlaying?.cdnUrl,
          isPlaying: store.state.oolafMusic.isPlaying,
          playbackState: store.state.oolafMusic.playbackState,
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

        _lastItems = items;

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 92),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            final rowKey = _rowKeys.putIfAbsent(item.key, () => GlobalKey());
            final left = 10.0 + item.depth * 12.0;

            final isActive =
                item.isFile && vm.playingUrl == item.entry.cdnUri.toString();
            final isRowLoading = item.isFile &&
                vm.loadingUrls.contains(item.entry.cdnUri.toString());
            final isBuffering =
                isActive && vm.playbackState == OolafPlaybackState.buffering;

            return KeyedSubtree(
              key: rowKey,
              child: _OolafMusicListRow(
                leftPadding: left,
                title: item.entry.displayName,
                isFolder: item.isFolder,
                isExpanded: item.isExpanded,
                isActive: isActive,
                isRowLoading: isRowLoading,
                isBuffering: isBuffering,
                isPlaying: vm.isPlaying,
                isFavorite:
                    widget.favoriteUrls.contains(item.entry.cdnUri.toString()),
                onToggleFavorite: item.isFile
                    ? () {
                        widget.onToggleFavorite(
                          item.entry.cdnUri.toString(),
                        );
                      }
                    : null,
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
              ),
            );
          },
        );
      },
    );
  }
}

class _OolafMusicListRow extends StatefulWidget {
  const _OolafMusicListRow({
    required this.leftPadding,
    required this.title,
    required this.isFolder,
    required this.isExpanded,
    required this.isActive,
    required this.isRowLoading,
    required this.isBuffering,
    required this.isPlaying,
    required this.isFavorite,
    required this.onTap,
    this.onToggleFavorite,
  });

  final double leftPadding;
  final String title;
  final bool isFolder;
  final bool isExpanded;
  final bool isActive;
  final bool isRowLoading;
  final bool isBuffering;
  final bool isPlaying;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final Future<void> Function() onTap;

  @override
  State<_OolafMusicListRow> createState() => _OolafMusicListRowState();
}

class _OolafMusicListRowState extends State<_OolafMusicListRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFD43C33);

    final background = widget.isActive
        ? const Color(0xFFFFF2F2)
        : _isPressed
            ? const Color(0x0A000000)
            : Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await widget.onTap();
      },
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.fromLTRB(widget.leftPadding, 12, 12, 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isActive
                ? const Color(0x22D43C33)
                : const Color(0x0F000000),
          ),
        ),
        child: Row(
          children: [
            if (widget.isFolder)
              Icon(
                widget.isExpanded
                    ? CupertinoIcons.chevron_down
                    : CupertinoIcons.chevron_right,
                size: 18,
                color: Colors.black54,
              )
            else
              const SizedBox(width: 18),
            const SizedBox(width: 8),
            if (widget.isFolder)
              const Icon(
                CupertinoIcons.folder_fill,
                size: 18,
                color: Color(0xFF8E8E93),
              )
            else
              const Icon(
                CupertinoIcons.music_note,
                size: 18,
                color: Color(0xFF8E8E93),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      color: widget.isActive
                          ? themeColor
                          : const Color(0xFF1C1C1E),
                      fontWeight:
                          widget.isActive ? FontWeight.w700 : FontWeight.w600,
                    ),
              ),
            ),
            if (widget.onToggleFavorite != null)
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(36, 36),
                onPressed: widget.onToggleFavorite,
                child: Icon(
                  widget.isFavorite
                      ? CupertinoIcons.star_fill
                      : CupertinoIcons.star,
                  size: 18,
                  color: themeColor,
                ),
              ),
            if (!widget.isFolder)
              widget.isActive
                  ? widget.isBuffering
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CupertinoActivityIndicator(radius: 11),
                        )
                      : widget.isPlaying
                          ? const Icon(
                              CupertinoIcons.pause_circle_fill,
                              size: 22,
                              color: themeColor,
                            )
                          : const Icon(
                              CupertinoIcons.play_circle_fill,
                              size: 22,
                              color: themeColor,
                            )
                  : widget.isRowLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CupertinoActivityIndicator(radius: 11),
                        )
                      : const Icon(
                          CupertinoIcons.play_circle,
                          size: 22,
                          color: themeColor,
                        ),
          ],
        ),
      ),
    );
  }
}

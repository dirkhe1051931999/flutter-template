import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_search_player_page.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/utils/short_video_blocked_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_collection_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_offline_cache_persistence.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class ShortVideoSearchResultPage extends StatefulWidget {
  const ShortVideoSearchResultPage({
    super.key,
    required this.keyword,
  });

  final String keyword;

  @override
  State<ShortVideoSearchResultPage> createState() =>
      _ShortVideoSearchResultPageState();
}

class _ShortVideoSearchResultPageState
    extends State<ShortVideoSearchResultPage> {
  static const int _loadMoreThreshold = 4;
  static const int _gridCrossAxisCount = 2;
  static const double _gridGap = 8;

  final ScrollController _scrollController = ScrollController();

  List<ShortVideoItem> _allItems = const <ShortVideoItem>[];
  Set<String> _favoriteVideoIds = const <String>{};
  ShortVideoBlockedSnapshot _blockedSnapshot = const ShortVideoBlockedSnapshot(
    videoIds: <String>{},
    sources: <String>{},
    titleKeywords: <String>{},
  );
  bool _isLoading = true;
  bool _isPaging = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _totalPage = 1;
  int _requestGeneration = 0;
  _SearchResultSortMode _sortMode = _SearchResultSortMode.relevance;
  String? _sourceFilter;

  List<ShortVideoItem> get _items {
    final filtered = _filterBlockedVideos(_allItems).where((item) {
      final filter = _sourceFilter;
      if (filter == null) {
        return true;
      }
      return (item.source ?? '短视频') == filter;
    }).toList(growable: false);

    if (_sortMode == _SearchResultSortMode.latest) {
      filtered.sort((a, b) => _updateTimeRank(b).compareTo(_updateTimeRank(a)));
    }
    return filtered;
  }

  List<String> get _sourceOptions {
    final sources = <String>{};
    for (final item in _filterBlockedVideos(_allItems)) {
      sources.add(item.source ?? '短视频');
    }
    final result = sources.toList(growable: false)..sort();
    return result;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadFavoriteState();
    _loadBlockedState();
    _loadSearchPage(1, reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    if (_items.isEmpty) {
      return;
    }
    final position = _scrollController.position;
    if (position.extentAfter > 480) {
      return;
    }
    _loadMoreIfNeeded(_items.length - 1);
  }

  int _updateTimeRank(ShortVideoItem item) {
    final raw = item.updateTime ?? '';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 8) {
      return int.tryParse(digits.substring(0, 8)) ?? 0;
    }
    return 0;
  }

  void _openPlayerPage(int index) {
    if (index < 0 || index >= _items.length) {
      return;
    }
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => ShortVideoSearchPlayerPage(
          keyword: widget.keyword,
          initialItems: _items,
          initialIndex: index,
          initialPage: _currentPage,
          totalPage: _totalPage,
          hasMore: _hasMore,
        ),
      ),
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

  Future<void> _loadBlockedState() async {
    final blockedSnapshot = await ShortVideoBlockedPersistence.loadSnapshot();
    if (!mounted) {
      return;
    }
    setState(() {
      _blockedSnapshot = blockedSnapshot;
      if (_sourceFilter != null && !_sourceOptions.contains(_sourceFilter)) {
        _sourceFilter = null;
      }
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

      setState(() {
        _allItems = _filterBlockedVideos(result.items);
        _currentPage = result.currentPage;
        _totalPage = result.totalPage;
        _hasMore = result.hasMore && result.items.isNotEmpty;
        if (_sourceFilter != null && !_sourceOptions.contains(_sourceFilter)) {
          _sourceFilter = null;
        }
      });
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
      setState(() {
        _hasMore = false;
      });
      return;
    }

    final requestGeneration = ++_requestGeneration;
    _isPaging = true;
    if (mounted) {
      setState(() {});
    }

    try {
      final result = await getShortVideoSearchPage(
        keyword: widget.keyword.trim(),
        page: nextPage,
      );
      if (!mounted || requestGeneration != _requestGeneration) {
        return;
      }
      if (result.items.isEmpty) {
        setState(() {
          _hasMore = false;
        });
        return;
      }

      setState(() {
        _allItems = _appendUniqueVideos(
          _allItems,
          _filterBlockedVideos(result.items),
        );
        _currentPage = result.currentPage;
        _totalPage = result.totalPage;
        _hasMore = result.hasMore;
        if (_sourceFilter != null && !_sourceOptions.contains(_sourceFilter)) {
          _sourceFilter = null;
        }
      });
    } finally {
      if (requestGeneration == _requestGeneration) {
        _isPaging = false;
        if (mounted) {
          setState(() {});
        }
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

  @override
  Widget build(BuildContext context) {
    final visibleItems = _items;
    final sourceOptions = _sourceOptions;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.keyword),
        previousPageTitle: '搜索',
        trailing: visibleItems.isEmpty
            ? null
            : Text(
                '$_currentPage/$_totalPage',
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
      child: SafeArea(
        child: visibleItems.isEmpty
            ? Center(
                child: _isLoading
                    ? const CupertinoActivityIndicator(radius: 14)
                    : const Text(
                        '暂无结果',
                        style: TextStyle(color: Color(0xFF8E8E93)),
                      ),
              )
            : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: _SearchResultToolbar(
                      sortMode: _sortMode,
                      sourceFilter: _sourceFilter,
                      sourceOptions: sourceOptions,
                      onSortChanged: (mode) {
                        setState(() {
                          _sortMode = mode;
                        });
                      },
                      onSourceChanged: (source) {
                        setState(() {
                          _sourceFilter = source;
                        });
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = visibleItems[index];
                          return _SearchResultGridItem(
                            item: item,
                            isFavorite: _favoriteVideoIds.contains(item.id),
                            onTap: () {
                              _openPlayerPage(index);
                            },
                            onTapFavorite: () async {
                              await _toggleFavorite(item);
                            },
                            onTapWatchLater: () async {
                              await _saveWatchLater(item);
                            },
                            onTapOfflineCache: () async {
                              await _saveOfflineCache(item);
                            },
                            onTapShare: () async {
                              await _copyShareText(item);
                            },
                          );
                        },
                        childCount: visibleItems.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _gridCrossAxisCount,
                        crossAxisSpacing: _gridGap,
                        mainAxisSpacing: _gridGap,
                        childAspectRatio: 0.62,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Center(
                        child: _isPaging
                            ? const CupertinoActivityIndicator(radius: 12)
                            : Text(
                                _hasMore ? '滑动到底加载更多' : '没有更多了',
                                style: const TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

enum _SearchResultSortMode {
  relevance,
  latest,
  duration,
}

class _SearchResultToolbar extends StatelessWidget {
  const _SearchResultToolbar({
    required this.sortMode,
    required this.sourceFilter,
    required this.sourceOptions,
    required this.onSortChanged,
    required this.onSourceChanged,
  });

  final _SearchResultSortMode sortMode;
  final String? sourceFilter;
  final List<String> sourceOptions;
  final ValueChanged<_SearchResultSortMode> onSortChanged;
  final ValueChanged<String?> onSourceChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CupertinoSlidingSegmentedControl<_SearchResultSortMode>(
            groupValue: sortMode,
            backgroundColor: const Color(0xFFE9EAEE),
            thumbColor: CupertinoColors.white,
            padding: const EdgeInsets.all(2),
            children: const {
              _SearchResultSortMode.relevance: _SortSegmentLabel('相关'),
              _SearchResultSortMode.latest: _SortSegmentLabel('最新'),
              _SearchResultSortMode.duration: _SortSegmentLabel('时长'),
            },
            onValueChanged: (value) {
              if (value == null) {
                return;
              }
              if (value == _SearchResultSortMode.duration) {
                showCupertinoDialog<void>(
                  context: context,
                  builder: (dialogContext) {
                    return CupertinoAlertDialog(
                      title: const Text('暂不可用'),
                      content: const Text('当前搜索接口没有返回视频时长，暂时无法按时长排序。'),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text('知道了'),
                        ),
                      ],
                    );
                  },
                );
                return;
              }
              onSortChanged(value);
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ScrollConfiguration(
              behavior: const _HorizontalDragScrollBehavior(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _SourceFilterChip(
                      label: '全部来源',
                      selected: sourceFilter == null,
                      onTap: () {
                        onSourceChanged(null);
                      },
                    ),
                    for (final source in sourceOptions)
                      _SourceFilterChip(
                        label: source,
                        selected: sourceFilter == source,
                        onTap: () {
                          onSourceChanged(source);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortSegmentLabel extends StatelessWidget {
  const _SortSegmentLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF1C1C1E),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _SourceFilterChip extends StatelessWidget {
  const _SourceFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        borderRadius: BorderRadius.circular(18),
        onPressed: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 32,
          constraints: const BoxConstraints(minWidth: 62, maxWidth: 132),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                selected ? CupertinoColors.activeBlue : CupertinoColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? CupertinoColors.activeBlue
                  : const Color(0xFFE1E2E7),
              width: 0.5,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x22007AFF),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? CupertinoColors.white : const Color(0xFF1C1C1E),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _HorizontalDragScrollBehavior extends CupertinoScrollBehavior {
  const _HorizontalDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class _SearchResultGridItem extends StatelessWidget {
  const _SearchResultGridItem({
    required this.item,
    required this.isFavorite,
    required this.onTap,
    required this.onTapFavorite,
    required this.onTapWatchLater,
    required this.onTapOfflineCache,
    required this.onTapShare,
  });

  final ShortVideoItem item;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onTapFavorite;
  final VoidCallback onTapWatchLater;
  final VoidCallback onTapOfflineCache;
  final VoidCallback onTapShare;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomNetworkImage(
                      item.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const ColoredBox(
                          color: Color(0xFFE5E5EA),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.exclamationmark_triangle,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: Row(
                        children: [
                          if ((item.avatarUrl ?? '').isNotEmpty)
                            ClipOval(
                              child: CustomNetworkImage(
                                item.avatarUrl!,
                                width: 22,
                                height: 22,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return const _SearchResultAvatarFallback();
                                },
                              ),
                            )
                          else
                            const _SearchResultAvatarFallback(),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.updateTime ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    color: Color(0x99000000),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
              child: Text(
                item.source ?? '短视频',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 11,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: _GridActionButton(
                      icon: isFavorite
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: isFavorite
                          ? CupertinoColors.systemRed
                          : const Color(0xFF8E8E93),
                      onTap: onTapFavorite,
                    ),
                  ),
                  Expanded(
                    child: _GridActionButton(
                      icon: CupertinoIcons.time,
                      onTap: onTapWatchLater,
                    ),
                  ),
                  Expanded(
                    child: _GridActionButton(
                      icon: CupertinoIcons.cloud_download,
                      onTap: onTapOfflineCache,
                    ),
                  ),
                  Expanded(
                    child: _GridActionButton(
                      icon: CupertinoIcons.share,
                      onTap: onTapShare,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridActionButton extends StatelessWidget {
  const _GridActionButton({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF8E8E93),
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 4),
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _SearchResultAvatarFallback extends StatelessWidget {
  const _SearchResultAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Color(0x66FFFFFF),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        CupertinoIcons.person_fill,
        size: 12,
        color: CupertinoColors.white,
      ),
    );
  }
}

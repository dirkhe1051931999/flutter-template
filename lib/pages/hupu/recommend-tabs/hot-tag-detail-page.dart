// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_feed_card.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_load_more_footer.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_status_view.dart';

const double _hotTagHeroHeight = 212;

class HupuHotTagDetailPage extends StatefulWidget {
  const HupuHotTagDetailPage({
    required this.tagId,
    this.initialTitle = '',
    super.key,
  });

  final int tagId;
  final String initialTitle;

  @override
  State<HupuHotTagDetailPage> createState() => _HupuHotTagDetailPageState();
}

class _HupuHotTagDetailPageState extends State<HupuHotTagDetailPage> {
  HupuTagDetail? _detail;
  bool _isLoading = true;
  String? _errorMessage;
  int _activeTabIndex = 0;
  final Map<int, double> _tabScrollOffsets = <int, double>{};

  bool get _isHeroCollapsed {
    final detail = _detail;
    if (detail == null) {
      return false;
    }
    final tabs = detail.tabs.isEmpty
        ? const <HupuTagDetailTab>[
            HupuTagDetailTab(name: '推荐', enName: 'hot', tabType: 1),
            HupuTagDetailTab(name: '实时', enName: 'latest', tabType: 2),
          ]
        : detail.tabs;
    if (_activeTabIndex < 0 || _activeTabIndex >= tabs.length) {
      return false;
    }
    final tabType = tabs[_activeTabIndex].tabType;
    return (_tabScrollOffsets[tabType] ?? 0) >= _hotTagHeroHeight;
  }

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await getHupuTagDetail(tagId: widget.tagId);
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openPostDetail(HupuTagThreadItem item) async {
    if (item.tid.isEmpty) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuPostDetailPage(
          tid: item.tid,
          fid: item.fid,
          topicId: item.topicId,
          initialTitle: item.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        backgroundColor: Color(0xFFF5F6F8),
        child: Center(
          child: CupertinoActivityIndicator(radius: 14),
        ),
      );
    }

    final detail = _detail;
    if (detail == null) {
      return CupertinoPageScaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        child: SafeArea(
          child: HupuStatusView(
            message: '词条详情加载失败',
            detail: _errorMessage,
            onRetry: _loadDetail,
          ),
        ),
      );
    }

    final tabs = detail.tabs.isEmpty
        ? const <HupuTagDetailTab>[
            HupuTagDetailTab(name: '推荐', enName: 'hot', tabType: 1),
            HupuTagDetailTab(name: '实时', enName: 'latest', tabType: 2),
          ]
        : detail.tabs;
    final initialIndex = _resolveInitialIndex(detail);
    if (_activeTabIndex != initialIndex) {
      _activeTabIndex = initialIndex;
    }

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                heightFactor: _isHeroCollapsed ? 0 : 1,
                child: SizedBox(
                  height: _hotTagHeroHeight,
                  child: _HotTagDetailHero(
                    detail: detail,
                    fallbackTitle: widget.initialTitle,
                  ),
                ),
              ),
            ),
            Expanded(
              child: LinkedTabView(
                initialIndex: initialIndex,
                onIndexChanged: (index, _) {
                  if (_activeTabIndex == index) {
                    return;
                  }
                  setState(() {
                    _activeTabIndex = index;
                  });
                },
                tabBarHeight: 48,
                tabBarPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabSpacing: 26,
                items: tabs
                    .map(
                      (tab) => LinkedTabItem(
                        id: '${tab.tabType}',
                        label: tab.name,
                        child: _HotTagThreadListTab(
                          tagId: detail.tagId,
                          tabType: tab.tabType,
                          onOpenPost: _openPostDetail,
                          onScrollOffsetChanged: (offset) {
                            final previous = _tabScrollOffsets[tab.tabType];
                            if (previous == offset) {
                              return;
                            }
                            if (!mounted) {
                              return;
                            }
                            setState(() {
                              _tabScrollOffsets[tab.tabType] = offset;
                            });
                          },
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _resolveInitialIndex(HupuTagDetail detail) {
    final targetTabType = detail.defaultTab;
    if (targetTabType <= 0) {
      return 0;
    }
    final index = detail.tabs.indexWhere((item) => item.tabType == targetTabType);
    return index < 0 ? 0 : index;
  }
}

class _HotTagDetailHero extends StatelessWidget {
  const _HotTagDetailHero({
    required this.detail,
    required this.fallbackTitle,
  });

  final HupuTagDetail detail;
  final String fallbackTitle;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _parseColor(detail.bannerRgb) ?? const Color(0xFF54696B);
    final title = detail.name.isNotEmpty ? detail.name : fallbackTitle;

    return SizedBox(
      height: 212,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  backgroundColor.withValues(alpha: 0.95),
                  backgroundColor,
                ],
              ),
            ),
          ),
          if (detail.banner.trim().isNotEmpty)
            CustomNetworkImage(
              detail.banner,
              fit: BoxFit.cover,
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0x66000000),
                  const Color(0xA6000000),
                  backgroundColor.withValues(alpha: 0.96),
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            left: 6,
            child: CupertinoButton(
              padding: const EdgeInsets.all(10),
              minimumSize: const Size(40, 40),
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(
                CupertinoIcons.back,
                color: Color(0xFFFFFFFF),
                size: 28,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_formatCount(detail.topicPostCount)}帖子  ${_formatPv(detail.pv)}阅读',
                        style: const TextStyle(
                          color: Color(0xFFE8EDF0),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (detail.rank > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x1FFFFFFF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0x33FFFFFF),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NO.${detail.rank}',
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '虎扑热榜',
                          style: TextStyle(
                            color: Color(0xFFD8E0E4),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

class _HotTagThreadListTab extends StatefulWidget {
  const _HotTagThreadListTab({
    required this.tagId,
    required this.tabType,
    required this.onOpenPost,
    required this.onScrollOffsetChanged,
  });

  final int tagId;
  final int tabType;
  final Future<void> Function(HupuTagThreadItem item) onOpenPost;
  final ValueChanged<double> onScrollOffsetChanged;

  @override
  State<_HotTagThreadListTab> createState() => _HotTagThreadListTabState();
}

class _HotTagThreadListTabState extends State<_HotTagThreadListTab>
    with AutomaticKeepAliveClientMixin<_HotTagThreadListTab> {
  final ScrollController _scrollController = ScrollController();
  final List<HupuTagThreadItem> _items = <HupuTagThreadItem>[];
  final Set<String> _tidSet = <String>{};

  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  String _lastCursor = '';
  int _page = 1;
  HupuLoadMoreState _loadMoreState = HupuLoadMoreState.idle;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onScrollOffsetChanged(0);
    });
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    widget.onScrollOffsetChanged(
      _scrollController.hasClients ? _scrollController.offset : 0,
    );
    if (!_scrollController.hasClients ||
        _isInitialLoading ||
        _isLoadingMore ||
        !_hasMore) {
      return;
    }
    if (_scrollController.position.extentAfter > 420) {
      return;
    }
    unawaited(_loadMore());
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await getHupuTagThreadList(
        tagId: widget.tagId,
        tabType: widget.tabType,
        page: 1,
      );
      if (!mounted) {
        return;
      }
      final mergedItems = _mergeItems(response.items, reset: true);
      setState(() {
        _items
          ..clear()
          ..addAll(mergedItems);
        _page = 1;
        _lastCursor = response.cursor;
        _hasMore = response.hasNextPage && mergedItems.isNotEmpty;
        _loadMoreState =
            _hasMore ? HupuLoadMoreState.idle : HupuLoadMoreState.noMore;
        _isInitialLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isInitialLoading || _isLoadingMore || !_hasMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _loadMoreState = HupuLoadMoreState.loading;
    });

    try {
      final response = await getHupuTagThreadList(
        tagId: widget.tagId,
        tabType: widget.tabType,
        page: _page + 1,
        lastCursor: _lastCursor,
      );
      if (!mounted) {
        return;
      }
      final beforeCount = _items.length;
      final mergedItems = _mergeItems(response.items);
      final appendedCount = mergedItems.length - beforeCount;
      final hasMore = response.hasNextPage && appendedCount > 0;

      setState(() {
        _items
          ..clear()
          ..addAll(mergedItems);
        _page += 1;
        _lastCursor = response.cursor;
        _hasMore = hasMore;
        _loadMoreState =
            hasMore ? HupuLoadMoreState.idle : HupuLoadMoreState.noMore;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _loadMoreState = HupuLoadMoreState.error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  List<HupuTagThreadItem> _mergeItems(
    List<HupuTagThreadItem> incomingItems, {
    bool reset = false,
  }) {
    if (reset) {
      _tidSet.clear();
    }
    final merged = reset ? <HupuTagThreadItem>[] : List<HupuTagThreadItem>.from(_items);
    for (final item in incomingItems) {
      if (item.tid.isEmpty || _tidSet.contains(item.tid)) {
        continue;
      }
      _tidSet.add(item.tid);
      merged.add(item);
    }
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isInitialLoading) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 13),
      );
    }

    if (_errorMessage != null && _items.isEmpty) {
      return HupuStatusView(
        message: '列表加载失败',
        detail: _errorMessage,
        onRetry: _loadInitial,
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text(
          '暂无内容',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 14,
          ),
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          sliver: SliverList.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: HupuFeedCard(
                  item: item.toFeedItem(),
                  onTap: () => widget.onOpenPost(item),
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
            child: HupuLoadMoreFooter(
              state: _loadMoreState,
              errorMessage: _errorMessage,
              onRetry: _loadMore,
            ),
          ),
        ),
      ],
    );
  }
}

Color? _parseColor(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    return null;
  }
  final hex = normalized.startsWith('#') ? normalized.substring(1) : normalized;
  if (hex.length != 6) {
    return null;
  }
  final colorValue = int.tryParse(hex, radix: 16);
  if (colorValue == null) {
    return null;
  }
  return Color(0xFF000000 | colorValue);
}

String _formatCount(int value) {
  if (value >= 10000) {
    return '${(value / 10000).toStringAsFixed(value >= 100000 ? 0 : 1)}万';
  }
  return '$value';
}

String _formatPv(int value) {
  if (value >= 100000000) {
    return '${(value / 100000000).toStringAsFixed(1)}亿';
  }
  if (value >= 10000) {
    return '${(value / 10000).toStringAsFixed(1)}万';
  }
  return '$value';
}

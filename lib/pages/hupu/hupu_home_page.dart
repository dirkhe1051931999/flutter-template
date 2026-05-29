import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_video_queue_page.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_feed_card.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_load_more_footer.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_refresh_indicator.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_status_view.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_gallery_preview.dart';

const Set<PointerDeviceKind> _hupuHomeDragDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown,
};

const double _hupuHomeRefreshTriggerDistance = 108;

class HupuHomePage extends StatefulWidget {
  const HupuHomePage({super.key});

  @override
  State<HupuHomePage> createState() => _HupuHomePageState();
}

class _HupuHomePageState extends State<HupuHomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<HupuFeedItem> _items = <HupuFeedItem>[];
  final Set<String> _itemKeys = <String>{};
  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  HupuLoadMoreState _loadMoreState = HupuLoadMoreState.idle;
  int _activeTopTabIndex = 1;

  static const List<String> _topTabs = <String>['关注', '推荐', '赛事'];

  List<HupuFeedItem> get _videoItems {
    return _items
        .where((item) => item.video?.isPlayable == true)
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _fetchInitial();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || _isInitialLoading) {
      return;
    }
    final position = _scrollController.position;
    if (position.extentAfter > 420) {
      return;
    }
    unawaited(_onLoading());
  }

  Future<void> _fetchInitial() async {
    if (_isRefreshing || _isLoadingMore) {
      return;
    }

    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await getHupuHotList(
        isFirst: true,
        isRefresh: true,
      );
      final merged = _mergeItems(response.items, reset: true);
      if (!mounted) {
        return;
      }
      setState(() {
        _items
          ..clear()
          ..addAll(merged);
        _hasMore = response.items.isNotEmpty;
        _isInitialLoading = false;
        _loadMoreState = response.items.isNotEmpty
            ? HupuLoadMoreState.idle
            : HupuLoadMoreState.noMore;
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

  Future<void> _onRefresh() async {
    if (_isRefreshing || _isLoadingMore) {
      return;
    }

    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    } else {
      _isRefreshing = true;
    }
    try {
      final response = await getHupuHotList(
        isFirst: true,
        isRefresh: true,
      );
      final merged = _mergeItems(response.items, reset: true);
      if (!mounted) {
        return;
      }
      setState(() {
        _items
          ..clear()
          ..addAll(merged);
        _hasMore = response.items.isNotEmpty;
        _errorMessage = null;
        _loadMoreState = response.items.isNotEmpty
            ? HupuLoadMoreState.idle
            : HupuLoadMoreState.noMore;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
          _loadMoreState =
              _items.isEmpty ? HupuLoadMoreState.idle : HupuLoadMoreState.error;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      } else {
        _isRefreshing = false;
      }
    }
  }

  Future<void> _onLoading() async {
    if (_isInitialLoading || _isRefreshing || _isLoadingMore || !_hasMore) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingMore = true;
        _loadMoreState = HupuLoadMoreState.loading;
      });
    } else {
      _isLoadingMore = true;
      _loadMoreState = HupuLoadMoreState.loading;
    }
    try {
      final previousLength = _items.length;
      final response = await getHupuHotList(
        isFirst: false,
        isRefresh: false,
      );
      final merged = _mergeItems(response.items);
      final appended = merged.length - previousLength;
      if (!mounted) {
        return;
      }

      setState(() {
        _items
          ..clear()
          ..addAll(merged);
        _hasMore = response.items.isNotEmpty && appended > 0;
        _errorMessage = null;
        _loadMoreState =
            _hasMore ? HupuLoadMoreState.idle : HupuLoadMoreState.noMore;
      });

      final noMoreData = response.items.isEmpty || appended == 0;
      if (noMoreData && mounted) {
        setState(() {
          _hasMore = false;
          _loadMoreState = HupuLoadMoreState.noMore;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
          _loadMoreState = HupuLoadMoreState.error;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      } else {
        _isLoadingMore = false;
      }
    }
  }

  Future<void> _openVideoQueue(HupuFeedItem item) async {
    if (item.video?.isPlayable != true) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) {
          return HupuVideoQueuePage(
            initialVideoId: item.uniqueKey,
            videoItemsProvider: () => _videoItems,
            onLoadMore: _onLoading,
            hasMoreProvider: () => _hasMore,
          );
        },
      ),
    );
  }

  Future<void> _openImageGallery(HupuFeedItem item) async {
    final imageUrls = item.pics
        .map((entry) => entry.url.trim())
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
    if (imageUrls.isEmpty) {
      return;
    }
    await openShortVideoImageGallery(
      context,
      imageUrls: imageUrls,
      initialImageUrl: imageUrls.first,
    );
  }

  Future<void> _openPostDetail(HupuFeedItem item) async {
    if (item.tid.isEmpty) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) {
          return HupuPostDetailPage(
            tid: item.tid,
            fid: item.fid,
            topicId: item.topicId,
            initialTitle: item.title,
          );
        },
      ),
    );
  }

  List<HupuFeedItem> _mergeItems(
    List<HupuFeedItem> incoming, {
    bool reset = false,
  }) {
    final merged = reset ? <HupuFeedItem>[] : List<HupuFeedItem>.from(_items);
    final seenKeys = reset ? <String>{} : Set<String>.from(_itemKeys);

    for (final item in incoming) {
      final key = item.uniqueKey;
      if (key.isEmpty || seenKeys.contains(key)) {
        continue;
      }
      seenKeys.add(key);
      merged.add(item);
    }

    _itemKeys
      ..clear()
      ..addAll(seenKeys);

    return merged;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          _HupuHomeHeader(
            tabs: _topTabs,
            activeIndex: _activeTopTabIndex,
            onTapTab: (index) {
              setState(() {
                _activeTopTabIndex = index;
              });
            },
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isInitialLoading) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    if (_items.isEmpty) {
      return HupuStatusView(
        message: _errorMessage == null ? '暂无内容' : '加载失败',
        detail: _errorMessage,
        onRetry: _fetchInitial,
      );
    }

    return ScrollConfiguration(
      behavior: const CupertinoScrollBehavior().copyWith(
        dragDevices: _hupuHomeDragDevices,
      ),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: _onRefresh,
            refreshTriggerPullDistance: _hupuHomeRefreshTriggerDistance,
            refreshIndicatorExtent: 96,
            builder: _buildRefreshIndicator,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            sliver: SliverList.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: HupuFeedCard(
                    item: _items[index],
                    onTap: () => _openPostDetail(_items[index]),
                    onTapVideo: () => _openVideoQueue(_items[index]),
                    onTapMedia: () => _openImageGallery(_items[index]),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              child: Column(
                children: [
                  HupuLoadMoreFooter(
                    state: _loadMoreState,
                    errorMessage: _errorMessage,
                    onRetry: _onLoading,
                  ),
                  if (_errorMessage != null &&
                      _loadMoreState != HupuLoadMoreState.error)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshIndicator(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) {
    final progress =
        (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.2);
    final isArmed = refreshState == RefreshIndicatorMode.armed ||
        refreshState == RefreshIndicatorMode.refresh;
    final isRefreshing =
        refreshState == RefreshIndicatorMode.refresh || _isRefreshing;
    return HupuRefreshIndicator(
      progress: progress,
      isArmed: isArmed,
      isRefreshing: isRefreshing,
    );
  }
}

class _HupuHomeHeader extends StatelessWidget {
  const _HupuHomeHeader({
    required this.tabs,
    required this.activeIndex,
    required this.onTapTab,
  });

  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onTapTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F1F4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2, right: 12),
            child: Text(
              '虎扑',
              style: TextStyle(
                color: Color(0xFFE31B23),
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(tabs.length, (index) {
                final isActive = activeIndex == index;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTapTab(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 28),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tabs[index],
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF1F1F1F)
                                : const Color(0xFF9A9AA3),
                            fontSize: isActive ? 18 : 16,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 24,
                          height: 3,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFE93B3D)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const Icon(
            CupertinoIcons.search,
            size: 22,
            color: Color(0xFF202127),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

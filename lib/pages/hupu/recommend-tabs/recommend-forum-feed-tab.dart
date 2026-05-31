// ignore_for_file: file_names

import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_video_queue_page.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_feed_card.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_load_more_footer.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_refresh_indicator.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_status_view.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_gallery_preview.dart';

const Set<PointerDeviceKind> _hupuForumFeedDragDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown,
};

class HupuRecommendForumFeedTab extends StatefulWidget {
  const HupuRecommendForumFeedTab({
    required this.forumName,
    super.key,
  });

  final String forumName;

  @override
  State<HupuRecommendForumFeedTab> createState() =>
      _HupuRecommendForumFeedTabState();
}

class _HupuRecommendForumFeedTabState extends State<HupuRecommendForumFeedTab>
    with AutomaticKeepAliveClientMixin<HupuRecommendForumFeedTab> {
  final ScrollController _scrollController = ScrollController();
  final List<HupuFeedItem> _items = <HupuFeedItem>[];
  final Set<String> _itemKeys = <String>{};

  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  HupuLoadMoreState _loadMoreState = HupuLoadMoreState.idle;

  @override
  bool get wantKeepAlive => true;

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
  void didUpdateWidget(covariant HupuRecommendForumFeedTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.forumName != widget.forumName) {
      _resetAndReload();
    }
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
    if (_scrollController.position.extentAfter > 420) {
      return;
    }
    unawaited(_loadMore());
  }

  void _resetAndReload() {
    _items.clear();
    _itemKeys.clear();
    _hasMore = true;
    _loadMoreState = HupuLoadMoreState.idle;
    _errorMessage = null;
    _isInitialLoading = true;
    if (mounted) {
      setState(() {});
    }
    unawaited(_fetchInitial());
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
      final response = await getHupuForumFeed(
        forumName: widget.forumName,
        isFirst: true,
        isRefresh: true,
      );
      final mergedItems = _mergeItems(response.items, reset: true);
      if (!mounted) {
        return;
      }
      setState(() {
        _items
          ..clear()
          ..addAll(mergedItems);
        _hasMore = response.items.isNotEmpty;
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

  Future<void> _refresh() async {
    if (_isRefreshing || _isLoadingMore || _isInitialLoading) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      final response = await getHupuForumFeed(
        forumName: widget.forumName,
        isFirst: true,
        isRefresh: true,
      );
      final mergedItems = _mergeItems(response.items, reset: true);
      if (!mounted) {
        return;
      }
      setState(() {
        _items
          ..clear()
          ..addAll(mergedItems);
        _hasMore = response.items.isNotEmpty;
        _loadMoreState =
            _hasMore ? HupuLoadMoreState.idle : HupuLoadMoreState.noMore;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _loadMoreState =
            _items.isEmpty ? HupuLoadMoreState.idle : HupuLoadMoreState.error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isInitialLoading || _isRefreshing || _isLoadingMore || !_hasMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _loadMoreState = HupuLoadMoreState.loading;
    });

    try {
      final previousLength = _items.length;
      final response = await getHupuForumFeed(
        forumName: widget.forumName,
        isFirst: false,
        isRefresh: false,
      );
      final mergedItems = _mergeItems(response.items);
      final appendedCount = mergedItems.length - previousLength;
      final hasMore = response.items.isNotEmpty && appendedCount > 0;
      if (!mounted) {
        return;
      }
      setState(() {
        _items
          ..clear()
          ..addAll(mergedItems);
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

  List<HupuFeedItem> _mergeItems(
    List<HupuFeedItem> incomingItems, {
    bool reset = false,
  }) {
    final merged = reset ? <HupuFeedItem>[] : List<HupuFeedItem>.from(_items);
    final seenKeys = reset ? <String>{} : Set<String>.from(_itemKeys);

    for (final item in incomingItems) {
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

  Future<void> _openPostDetail(HupuFeedItem item) async {
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

  Future<void> _openVideoQueue(HupuFeedItem item) async {
    if (item.video?.isPlayable != true) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuVideoQueuePage(
          initialVideoId: item.uniqueKey,
          videoItemsProvider: () => _videoItems,
          onLoadMore: _loadMore,
          hasMoreProvider: () => _hasMore,
        ),
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

  Widget _buildRefreshIndicator(
    BuildContext context,
    LinkedTabRefreshState state,
    double progress,
  ) {
    final isArmed = state == LinkedTabRefreshState.armed ||
        state == LinkedTabRefreshState.refreshing;
    final isRefreshing = state == LinkedTabRefreshState.refreshing ||
        state == LinkedTabRefreshState.complete ||
        _isRefreshing;
    return HupuRefreshIndicator(
      progress: progress,
      isArmed: isArmed,
      isRefreshing: isRefreshing,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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

    return LinkedTabPageRefresh(
      onRefresh: _refresh,
      indicatorBuilder: _buildRefreshIndicator,
      child: ScrollConfiguration(
        behavior: const CupertinoScrollBehavior().copyWith(
          dragDevices: _hupuForumFeedDragDevices,
          scrollbars: false,
        ),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverList.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: HupuFeedCard(
                    item: item,
                    onTap: () => _openPostDetail(item),
                    onTapVideo: () => _openVideoQueue(item),
                    onTapMedia: () => _openImageGallery(item),
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                child: HupuLoadMoreFooter(
                  state: _loadMoreState,
                  errorMessage: _errorMessage,
                  onRetry: _loadMore,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

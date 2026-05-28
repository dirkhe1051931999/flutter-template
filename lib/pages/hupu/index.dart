import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_video_queue_page.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_feed_card.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_home_floating_button.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_load_more_footer.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_refresh_indicator.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_status_view.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_top_bar.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_gallery_preview.dart';

const Set<PointerDeviceKind> _hupuDragDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown,
};

const double _hupuRefreshTriggerDistance = 108;

class HupuPage extends StatefulWidget {
  const HupuPage({super.key});

  @override
  State<HupuPage> createState() => _HupuPageState();
}

class _HupuPageState extends State<HupuPage> {
  final ScrollController _scrollController = ScrollController();
  final List<HupuFeedItem> _items = <HupuFeedItem>[];
  final Set<String> _itemKeys = <String>{};
  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  HupuLoadMoreState _loadMoreState = HupuLoadMoreState.idle;
  bool _isHomeButtonEmphasized = false;

  static const List<String> _tabs = <String>[
    '推荐',
    '热榜',
    '篮球',
    '足球',
    '步行街',
    '数码',
    '影视',
  ];

  List<HupuFeedItem> get _videoItems {
    return _items
        .where((item) => item.video?.isPlayable == true)
        .toList(growable: false);
  }

  void _softenHomeButton() {
    if (!_isHomeButtonEmphasized || !mounted) {
      return;
    }
    setState(() {
      _isHomeButtonEmphasized = false;
    });
  }

  void _emphasizeHomeButton() {
    if (_isHomeButtonEmphasized || !mounted) {
      return;
    }
    setState(() {
      _isHomeButtonEmphasized = true;
    });
  }

  void _backToFunctionEntry() {
    _emphasizeHomeButton();
    final navigator = Navigator.of(context);
    if (!navigator.canPop()) {
      return;
    }
    navigator.popUntil((route) => route.isFirst);
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
          _loadMoreState = _items.isEmpty
              ? HupuLoadMoreState.idle
              : HupuLoadMoreState.error;
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
        _loadMoreState = _hasMore
            ? HupuLoadMoreState.idle
            : HupuLoadMoreState.noMore;
      });

      final noMoreData = response.items.isEmpty || appended == 0;
      if (noMoreData) {
        if (mounted) {
          setState(() {
            _hasMore = false;
            _loadMoreState = HupuLoadMoreState.noMore;
          });
        }
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
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (_) => _softenHomeButton(),
              child: Column(
                children: [
                  const HupuTopBar(tabs: _tabs),
                  Expanded(
                    child: _buildBody(),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 18,
              child: HupuHomeFloatingButton(
                isEmphasized: _isHomeButtonEmphasized,
                onTap: _backToFunctionEntry,
                onPointerDown: _emphasizeHomeButton,
              ),
            ),
          ],
        ),
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
        dragDevices: _hupuDragDevices,
      ),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: _onRefresh,
            refreshTriggerPullDistance: _hupuRefreshTriggerDistance,
            refreshIndicatorExtent: 96,
            builder: _buildRefreshIndicator,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            sliver: SliverList.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HupuFeedCard(
                    item: _items[index],
                    onTapVideo: () => _openVideoQueue(_items[index]),
                    onTapMedia: () => _openImageGallery(_items[index]),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              child: Column(
                children: [
                  HupuLoadMoreFooter(
                    state: _loadMoreState,
                    errorMessage: _errorMessage,
                    onRetry: _onLoading,
                  ),
                  if (_errorMessage != null && _loadMoreState != HupuLoadMoreState.error)
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
    final progress = (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.2);
    final isArmed = refreshState == RefreshIndicatorMode.armed ||
        refreshState == RefreshIndicatorMode.refresh;
    final isRefreshing = refreshState == RefreshIndicatorMode.refresh || _isRefreshing;
    return HupuRefreshIndicator(
      progress: progress,
      isArmed: isArmed,
      isRefreshing: isRefreshing,
    );
  }
}

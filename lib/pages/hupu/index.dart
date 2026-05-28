import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_feed_card.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_status_view.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_top_bar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

const Set<PointerDeviceKind> _hupuDragDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown,
};

class HupuPage extends StatefulWidget {
  const HupuPage({super.key});

  @override
  State<HupuPage> createState() => _HupuPageState();
}

class _HupuPageState extends State<HupuPage> {
  final RefreshController _refreshController = RefreshController();
  final List<HupuFeedItem> _items = <HupuFeedItem>[];
  final Set<String> _itemKeys = <String>{};
  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  static const List<String> _tabs = <String>[
    '推荐',
    '热榜',
    '篮球',
    '足球',
    '步行街',
    '数码',
    '影视',
  ];

  @override
  void initState() {
    super.initState();
    _fetchInitial();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
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
      _refreshController.refreshCompleted();
      return;
    }

    _isRefreshing = true;
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
      });
      _refreshController.refreshCompleted();
      _refreshController.resetNoData();
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
        });
      }
      _refreshController.refreshFailed();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _onLoading() async {
    if (_isInitialLoading || _isRefreshing || _isLoadingMore || !_hasMore) {
      _refreshController.loadComplete();
      return;
    }

    _isLoadingMore = true;
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
      });

      final noMoreData = response.items.isEmpty || appended == 0;
      if (noMoreData) {
        if (mounted) {
          setState(() {
            _hasMore = false;
          });
        }
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
        });
      }
      _refreshController.loadFailed();
    } finally {
      _isLoadingMore = false;
    }
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
        child: Column(
          children: [
            const HupuTopBar(tabs: _tabs),
            Expanded(
              child: _buildBody(),
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
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: _hasMore,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        header: const WaterDropHeader(
          complete: Icon(Icons.check_circle_outline, color: Color(0xFFE5484D)),
        ),
        footer: const ClassicFooter(
          idleText: '上拉加载更多',
          loadingText: '加载中...',
          noDataText: '没有更多了',
          failedText: '加载失败，重试',
          canLoadingText: '释放加载更多',
        ),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          itemCount: _items.length + 1,
          itemBuilder: (context, index) {
            if (index == _items.length) {
              if (_errorMessage == null || _items.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HupuFeedCard(item: _items[index]),
            );
          },
        ),
      ),
    );
  }
}

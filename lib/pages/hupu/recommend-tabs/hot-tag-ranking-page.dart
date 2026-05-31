// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/recommend-tabs/hot-tag-detail-page.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_load_more_footer.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_refresh_indicator.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_status_view.dart';

class HupuHotTagRankingPage extends StatefulWidget {
  const HupuHotTagRankingPage({super.key});

  @override
  State<HupuHotTagRankingPage> createState() => _HupuHotTagRankingPageState();
}

class _HupuHotTagRankingPageState extends State<HupuHotTagRankingPage> {
  final ScrollController _scrollController = ScrollController();
  final List<HupuHotTagItem> _items = <HupuHotTagItem>[];

  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  String _subtitle = '实时热榜，每10分钟更新一次';
  int _page = 1;

  HupuLoadMoreState _loadMoreState = HupuLoadMoreState.idle;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
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
    if (!_scrollController.hasClients ||
        _isInitialLoading ||
        _isRefreshing ||
        _isLoadingMore ||
        !_hasMore ||
        _items.isEmpty) {
      return;
    }

    if (_scrollController.position.extentAfter > 360) {
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
      final response = await getHupuHotTags(page: 1);
      if (!mounted) {
        return;
      }

      setState(() {
        _items
          ..clear()
          ..addAll(response.items);
        _page = response.page;
        _hasMore = response.page < response.totalPage;
        _loadMoreState =
            _hasMore ? HupuLoadMoreState.idle : HupuLoadMoreState.noMore;
        _subtitle = _buildSubtitle(response);
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
    if (_isRefreshing || _isInitialLoading) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      final response = await getHupuHotTags(page: 1);
      if (!mounted) {
        return;
      }

      setState(() {
        _items
          ..clear()
          ..addAll(response.items);
        _page = response.page;
        _hasMore = response.page < response.totalPage;
        _loadMoreState =
            _hasMore ? HupuLoadMoreState.idle : HupuLoadMoreState.noMore;
        _subtitle = _buildSubtitle(response);
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
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
    if (_isInitialLoading ||
        _isRefreshing ||
        _isLoadingMore ||
        !_hasMore ||
        _items.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _loadMoreState = HupuLoadMoreState.loading;
    });

    try {
      final nextPage = _page + 1;
      final response = await getHupuHotTags(page: nextPage);
      if (!mounted) {
        return;
      }

      final incomingItems = response.items
          .where((item) => !_items.any((existing) => existing.tagId == item.tagId))
          .toList(growable: false);

      setState(() {
        _items.addAll(incomingItems);
        _page = response.page;
        _hasMore = response.page < response.totalPage && incomingItems.isNotEmpty;
        _loadMoreState =
            _hasMore ? HupuLoadMoreState.idle : HupuLoadMoreState.noMore;
        _subtitle = _buildSubtitle(response);
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

  Future<void> _openHotTagDetail(HupuHotTagItem item) async {
    if (item.tagId <= 0) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuHotTagDetailPage(
          tagId: item.tagId,
          initialTitle: item.tagName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      child: SafeArea(
        bottom: false,
        child: _isInitialLoading
            ? const Center(
                child: CupertinoActivityIndicator(radius: 14),
              )
            : _items.isEmpty
                ? HupuStatusView(
                    message: _errorMessage == null ? '暂无热榜词条' : '加载热榜失败',
                    detail: _errorMessage,
                    onRetry: _loadInitial,
                  )
                : LinkedTabPageRefresh(
                    onRefresh: _onRefresh,
                    indicatorBuilder: _buildRefreshIndicator,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildHeroHeader(context),
                        ),
                        SliverToBoxAdapter(
                          child: Transform.translate(
                            offset: const Offset(0, -8),
                          child: _buildRankingPanel(),
                        ),
                        ),
                        SliverToBoxAdapter(
                          child: Transform.translate(
                            offset: const Offset(0, -4),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              child: HupuLoadMoreFooter(
                                state: _loadMoreState,
                                errorMessage: _errorMessage,
                                onRetry: _loadMore,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      height: 238,
      decoration: const BoxDecoration(
        color: Color(0xFFE60012),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF1730),
            Color(0xFFE60012),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _HupuHotTagHeaderPainter(),
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 4,
            child: CupertinoButton(
              padding: const EdgeInsets.all(12),
              minimumSize: const Size(40, 40),
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(
                CupertinoIcons.back,
                color: Color(0xFFFFFFFF),
                size: 28,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '虎扑热榜',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _subtitle,
                  style: const TextStyle(
                    color: Color(0xFFFFD7DC),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int index = 0; index < _items.length; index++)
            _HupuHotTagRankingTile(
              item: _items[index],
              isLast: index == _items.length - 1,
              onTap: () => _openHotTagDetail(_items[index]),
            ),
        ],
      ),
    );
  }
}

class _HupuHotTagRankingTile extends StatelessWidget {
  const _HupuHotTagRankingTile({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  final HupuHotTagItem item;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isTopThree = item.rank <= 3;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(
                    color: Color(0xFFF0F1F4),
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              alignment: Alignment.centerLeft,
              child: Text(
                '${item.rank}',
                style: TextStyle(
                  color: isTopThree
                      ? const Color(0xFFE5484D)
                      : const Color(0xFF394150),
                  fontSize: item.rank >= 10 ? 18 : 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.tagName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF23262D),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.28,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              CupertinoIcons.flame_fill,
              color: Color(0xFF9AA3B2),
              size: 15,
            ),
            const SizedBox(width: 5),
            Text(
              _formatHotTagHeat(item.heat),
              style: const TextStyle(
                color: Color(0xFF9AA3B2),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HupuHotTagHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lightPaint = Paint()..color = const Color(0x11FFFFFF);
    final mediumPaint = Paint()..color = const Color(0x14FFFFFF);

    final path1 = Path()
      ..moveTo(size.width * 0.02, size.height * 0.72)
      ..lineTo(size.width * 0.36, size.height * 0.10)
      ..lineTo(size.width * 0.56, size.height * 0.10)
      ..lineTo(size.width * 0.22, size.height * 0.72)
      ..close();
    canvas.drawPath(path1, lightPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.56, size.height * 0.18)
      ..lineTo(size.width * 0.82, size.height * 0.02)
      ..lineTo(size.width * 0.92, size.height * 0.02)
      ..lineTo(size.width * 0.66, size.height * 0.18)
      ..close();
    canvas.drawPath(path2, mediumPaint);

    final path3 = Path()
      ..moveTo(size.width * 0.64, size.height * 0.62)
      ..lineTo(size.width * 0.90, size.height * 0.24)
      ..lineTo(size.width, size.height * 0.24)
      ..lineTo(size.width * 0.74, size.height * 0.62)
      ..close();
    canvas.drawPath(path3, lightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _buildSubtitle(HupuHotTagPage page) {
  if (page.totalPage > 1) {
    return '实时热榜，每10分钟更新一次';
  }
  return '实时热榜';
}

String _formatHotTagHeat(int heat) {
  if (heat >= 10000) {
    return '${(heat / 10000).toStringAsFixed(2)}万';
  }
  return '$heat';
}

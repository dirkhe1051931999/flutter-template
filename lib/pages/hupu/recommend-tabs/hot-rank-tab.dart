// ignore_for_file: file_names

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_user_detail_helper.dart';
import 'package:oolaf_flutted/pages/hupu/recommend-tabs/hot-tag-detail-page.dart';
import 'package:oolaf_flutted/pages/hupu/recommend-tabs/hot-tag-ranking-page.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_load_more_footer.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_refresh_indicator.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_status_view.dart';

const Set<PointerDeviceKind> _hupuHotRankDragDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown,
};

class HupuRecommendHotRankTab extends StatefulWidget {
  const HupuRecommendHotRankTab({super.key});

  @override
  State<HupuRecommendHotRankTab> createState() =>
      _HupuRecommendHotRankTabState();
}

class _HupuRecommendHotRankTabState extends State<HupuRecommendHotRankTab>
    with AutomaticKeepAliveClientMixin<HupuRecommendHotRankTab> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();

  List<HupuHotTagItem> _hotTags = const <HupuHotTagItem>[];
  List<HupuHotRankCategory> _categories = const <HupuHotRankCategory>[];
  final Map<int, _HupuHotRankCategoryState> _categoryStateMap =
      <int, _HupuHotRankCategoryState>{};

  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  int? _activeCategoryId;

  @override
  bool get wantKeepAlive => true;

  _HupuHotRankCategoryState? get _activeCategoryState {
    final categoryId = _activeCategoryId;
    if (categoryId == null) {
      return null;
    }
    return _categoryStateMap[categoryId];
  }

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
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final activeState = _activeCategoryState;
    if (!_scrollController.hasClients ||
        activeState == null ||
        _isInitialLoading ||
        activeState.isLoadingMore ||
        !activeState.hasMore) {
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
      final responses = await Future.wait<dynamic>([
        getHupuHotTags(),
        getHupuHotRankCategories(),
      ]);
      final hotTagPage = responses[0] as HupuHotTagPage;
      final categories = responses[1] as List<HupuHotRankCategory>;
      final initialCategoryId = categories.isNotEmpty ? categories.first.id : 0;
      final rankResponse = categories.isNotEmpty
          ? await getHupuHotRankList(categoryId: initialCategoryId)
          : const HupuHotRankResponse(
              items: <HupuHotRankItem>[],
              totalCount: 0,
              adPageId: '',
            );

      if (!mounted) {
        return;
      }

      final categoryStateMap = <int, _HupuHotRankCategoryState>{};
      if (categories.isNotEmpty) {
        categoryStateMap[initialCategoryId] =
            _HupuHotRankCategoryState.fromResponse(rankResponse);
      }

      setState(() {
        _hotTags = hotTagPage.items;
        _categories = categories;
        _categoryStateMap
          ..clear()
          ..addAll(categoryStateMap);
        _activeCategoryId = categories.isNotEmpty ? initialCategoryId : null;
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
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      final activeCategoryId = _activeCategoryId;
      final responses = await Future.wait<dynamic>([
        getHupuHotTags(),
        getHupuHotRankCategories(),
      ]);
      final hotTagPage = responses[0] as HupuHotTagPage;
      final categories = responses[1] as List<HupuHotRankCategory>;
      final nextCategoryId = _pickNextCategoryId(
        categories: categories,
        preferredCategoryId: activeCategoryId,
      );
      final rankResponse = nextCategoryId == null
          ? const HupuHotRankResponse(
              items: <HupuHotRankItem>[],
              totalCount: 0,
              adPageId: '',
            )
          : await getHupuHotRankList(categoryId: nextCategoryId);

      if (!mounted) {
        return;
      }

      setState(() {
        _hotTags = hotTagPage.items;
        _categories = categories;
        if (nextCategoryId != null) {
          _categoryStateMap[nextCategoryId] =
              _HupuHotRankCategoryState.fromResponse(rankResponse);
        }
        _activeCategoryId = nextCategoryId;
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

  Future<void> _switchCategory(HupuHotRankCategory category) async {
    if (_activeCategoryId == category.id) {
      return;
    }

    setState(() {
      _activeCategoryId = category.id;
    });

    _scrollCategoryIntoView(category.id);

    final existingState = _categoryStateMap[category.id];
    if (existingState != null && existingState.items.isNotEmpty) {
      return;
    }

    setState(() {
      _categoryStateMap[category.id] = const _HupuHotRankCategoryState(
        items: <HupuHotRankItem>[],
        hasMore: true,
        isLoadingMore: false,
        loadMoreState: HupuLoadMoreState.loading,
      );
    });

    try {
      final response = await getHupuHotRankList(categoryId: category.id);
      if (!mounted || _activeCategoryId != category.id) {
        return;
      }

      setState(() {
        _categoryStateMap[category.id] =
            _HupuHotRankCategoryState.fromResponse(response);
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted || _activeCategoryId != category.id) {
        return;
      }
      setState(() {
        _categoryStateMap[category.id] = _HupuHotRankCategoryState(
          items: const <HupuHotRankItem>[],
          hasMore: true,
          isLoadingMore: false,
          loadMoreState: HupuLoadMoreState.error,
          errorMessage: error.toString(),
        );
      });
    }
  }

  Future<void> _retryActiveCategory() async {
    final categoryId = _activeCategoryId;
    if (categoryId == null) {
      return;
    }

    setState(() {
      _categoryStateMap[categoryId] = const _HupuHotRankCategoryState(
        items: <HupuHotRankItem>[],
        hasMore: true,
        isLoadingMore: false,
        loadMoreState: HupuLoadMoreState.loading,
      );
    });

    try {
      final response = await getHupuHotRankList(categoryId: categoryId);
      if (!mounted || _activeCategoryId != categoryId) {
        return;
      }
      setState(() {
        _categoryStateMap[categoryId] =
            _HupuHotRankCategoryState.fromResponse(response);
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted || _activeCategoryId != categoryId) {
        return;
      }
      setState(() {
        _categoryStateMap[categoryId] = _HupuHotRankCategoryState(
          items: const <HupuHotRankItem>[],
          hasMore: true,
          isLoadingMore: false,
          loadMoreState: HupuLoadMoreState.error,
          errorMessage: error.toString(),
        );
      });
    }
  }

  Future<void> _loadMore() async {
    final categoryId = _activeCategoryId;
    final activeState = _activeCategoryState;
    if (categoryId == null ||
        activeState == null ||
        activeState.isLoadingMore ||
        !activeState.hasMore) {
      return;
    }

    setState(() {
      _categoryStateMap[categoryId] = activeState.copyWith(
        isLoadingMore: true,
        loadMoreState: HupuLoadMoreState.loading,
      );
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 240));
      if (!mounted || _activeCategoryId != categoryId) {
        return;
      }

      setState(() {
        _categoryStateMap[categoryId] = activeState.copyWith(
          hasMore: false,
          isLoadingMore: false,
          loadMoreState: HupuLoadMoreState.noMore,
        );
      });
    } catch (error) {
      if (!mounted || _activeCategoryId != categoryId) {
        return;
      }

      setState(() {
        _categoryStateMap[categoryId] = activeState.copyWith(
          hasMore: true,
          isLoadingMore: false,
          loadMoreState: HupuLoadMoreState.error,
          errorMessage: error.toString(),
        );
      });
    }
  }

  int? _pickNextCategoryId({
    required List<HupuHotRankCategory> categories,
    required int? preferredCategoryId,
  }) {
    if (categories.isEmpty) {
      return null;
    }
    if (preferredCategoryId == null) {
      return categories.first.id;
    }
    final matched = categories.any((item) => item.id == preferredCategoryId);
    return matched ? preferredCategoryId : categories.first.id;
  }

  void _scrollCategoryIntoView(int categoryId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_categoryScrollController.hasClients) {
        return;
      }
      final index = _categories.indexWhere((item) => item.id == categoryId);
      if (index < 0) {
        return;
      }
      final estimatedOffset = math.max(0, (index * 86) - 40).toDouble();
      final maxOffset = _categoryScrollController.position.maxScrollExtent;
      _categoryScrollController.animateTo(
        estimatedOffset.clamp(0, maxOffset),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _openPostDetail(HupuHotRankItem item) async {
    if (item.thread.tid.isEmpty) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) {
          return HupuPostDetailPage(
            tid: item.thread.tid,
            fid: item.thread.fid,
            topicId: item.thread.topicId,
            initialTitle: item.thread.title,
          );
        },
      ),
    );
  }

  Future<void> _openHotTagRankingPage() async {
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => const HupuHotTagRankingPage(),
      ),
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

  Future<void> _openUserDetail({
    required String puid,
    required String nickname,
    required String avatar,
  }) {
    return openHupuUserDetail(
      context,
      puid: puid,
      initialNickname: nickname,
      initialAvatar: avatar,
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

    if (_errorMessage != null &&
        _hotTags.isEmpty &&
        _categories.isEmpty &&
        _activeCategoryState == null) {
      return HupuStatusView(
        message: '加载热榜失败',
        detail: _errorMessage,
        onRetry: _loadInitial,
      );
    }

    final activeState = _activeCategoryState;
    final items = activeState?.items ?? const <HupuHotRankItem>[];

    return LinkedTabPageRefresh(
      onRefresh: _onRefresh,
      indicatorBuilder: _buildRefreshIndicator,
      child: ScrollConfiguration(
        behavior: const CupertinoScrollBehavior().copyWith(
          dragDevices: _hupuHotRankDragDevices,
          scrollbars: false,
        ),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHotTagSection(),
            ),
            SliverToBoxAdapter(
              child: _buildHotPostHeader(),
            ),
            if (activeState != null &&
                activeState.items.isEmpty &&
                activeState.loadMoreState == HupuLoadMoreState.loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 56),
                  child: Center(
                    child: CupertinoActivityIndicator(radius: 13),
                  ),
                ),
              )
            else if (activeState != null &&
                activeState.items.isEmpty &&
                activeState.loadMoreState == HupuLoadMoreState.error)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: HupuStatusView(
                    message: '加载热帖失败',
                    detail: activeState.errorMessage,
                    onRetry: _retryActiveCategory,
                  ),
                ),
              )
            else if (items.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(
                    child: Text(
                      '暂无热帖内容',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: _HupuHotRankCard(
                      item: items[index],
                      onTap: () => _openPostDetail(items[index]),
                      onTapAuthor: items[index].thread.puid.isEmpty
                          ? null
                          : () => _openUserDetail(
                                puid: items[index].thread.puid,
                                nickname: items[index].thread.nickname,
                                avatar: items[index].thread.header,
                              ),
                      onTapLightReplyAuthor:
                          items[index].thread.lightReplies.isEmpty ||
                                  items[index].thread.lightReplies.first.puid
                                      .isEmpty
                              ? null
                              : () => _openUserDetail(
                                    puid: items[index]
                                        .thread
                                        .lightReplies
                                        .first
                                        .puid,
                                    nickname: items[index]
                                        .thread
                                        .lightReplies
                                        .first
                                        .nickname,
                                    avatar: items[index]
                                        .thread
                                        .lightReplies
                                        .first
                                        .header,
                                  ),
                    ),
                  );
                },
              ),
            if (activeState != null && items.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  child: HupuLoadMoreFooter(
                    state: activeState.loadMoreState,
                    errorMessage: activeState.errorMessage,
                    onRetry: _loadMore,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotTagSection() {
    final visibleTags = _hotTags.take(10).toList(growable: false);
    final leftTags = visibleTags.where((item) => item.rank.isOdd).toList();
    final rightTags = visibleTags.where((item) => item.rank.isEven).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '热榜词条',
                  style: TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _openHotTagRankingPage,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '完整榜单 >',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                      children: leftTags
                        .map(
                          (item) => _HupuHotTagTile(
                            item: item,
                            onTap: () => _openHotTagDetail(item),
                          ),
                        )
                        .toList(growable: false),
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                      children: rightTags
                        .map(
                          (item) => _HupuHotTagTile(
                            item: item,
                            onTap: () => _openHotTagDetail(item),
                          ),
                        )
                        .toList(growable: false),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotPostHeader() {
    final activeId = _activeCategoryId;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '热帖榜',
              style: TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              controller: _categoryScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Row(
                children: _categories.map((item) {
                  final isActive = item.id == activeId;
                  return GestureDetector(
                    onTap: () => _switchCategory(item),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFF2F3F5)
                            : const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFFE0E3E8)
                              : const Color(0xFFECEEF2),
                        ),
                      ),
                      child: Text(
                        item.name,
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF1C1C1E)
                              : const Color(0xFF8E8E93),
                          fontSize: 13,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HupuHotTagTile extends StatelessWidget {
  const _HupuHotTagTile({
    required this.item,
    required this.onTap,
  });

  final HupuHotTagItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isTopThree = item.rank > 0 && item.rank <= 3;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${item.rank}',
                style: TextStyle(
                  color: isTopThree
                      ? const Color(0xFFE5484D)
                      : const Color(0xFF22262F),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.tagName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1C1C1E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatHeat(item.heat),
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
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
    );
  }
}

class _HupuHotRankCard extends StatelessWidget {
  const _HupuHotRankCard({
    required this.item,
    required this.onTap,
    this.onTapAuthor,
    this.onTapLightReplyAuthor,
  });

  final HupuHotRankItem item;
  final VoidCallback onTap;
  final VoidCallback? onTapAuthor;
  final VoidCallback? onTapLightReplyAuthor;

  @override
  Widget build(BuildContext context) {
    final thread = item.thread;
    final lightReply =
        thread.lightReplies.isNotEmpty ? thread.lightReplies.first : null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRankBadge(),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapAuthor,
                  child: ClipOval(
                    child: CustomNetworkImage(
                      thread.header,
                      width: 38,
                      height: 38,
                      skeletonBorderRadius: BorderRadius.circular(19),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTapAuthor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          thread.nickname.isEmpty ? '虎扑用户' : thread.nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF30343B),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatThreadMeta(thread, item.createTimeText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              thread.title,
              style: const TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 17,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_buildSummaryText(thread).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _buildSummaryText(thread),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF5B616C),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
            if (thread.pics.isNotEmpty) ...[
              const SizedBox(height: 12),
              _HupuHotRankMediaGrid(images: thread.pics),
            ],
            if (lightReply != null && lightReply.content.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _HupuHotRankLightReplyCard(
                reply: lightReply,
                onTapUser: onTapLightReplyAuthor,
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (thread.topicLogo.trim().isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: CustomNetworkImage(
                            thread.topicLogo,
                            width: 18,
                            height: 18,
                            skeletonBorderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          thread.primarySectionName.isEmpty
                              ? '虎扑社区'
                              : thread.primarySectionName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _HupuHotRankStat(
                  icon: CupertinoIcons.hand_thumbsup,
                  value: thread.recommendNum,
                ),
                const SizedBox(width: 14),
                _HupuHotRankStat(
                  icon: CupertinoIcons.chat_bubble,
                  value: thread.replies,
                ),
                const SizedBox(width: 14),
                _HupuHotRankStat(
                  icon: CupertinoIcons.share_up,
                  value: thread.shareNum,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    final isTopThree = item.order > 0 && item.order <= 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isTopThree ? const Color(0xFFFFF1F0) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'NO.${item.order}',
        style: TextStyle(
          color: isTopThree ? const Color(0xFFE5484D) : const Color(0xFF61656D),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _HupuHotRankMediaGrid extends StatelessWidget {
  const _HupuHotRankMediaGrid({
    required this.images,
  });

  final List<HupuHotRankImage> images;

  @override
  Widget build(BuildContext context) {
    final previewImages = images.take(3).toList(growable: false);
    if (previewImages.isEmpty) {
      return const SizedBox.shrink();
    }

    if (previewImages.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: _safeAspectRatio(previewImages.first),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomNetworkImage(
                previewImages.first.url,
                fit: BoxFit.cover,
                skeletonBorderRadius: BorderRadius.circular(12),
              ),
              if (previewImages.first.isGif) _buildGifBadge(),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 118,
      child: Row(
        children: List<Widget>.generate(previewImages.length, (index) {
          final image = previewImages[index];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomNetworkImage(
                      image.url,
                      fit: BoxFit.cover,
                      skeletonBorderRadius: BorderRadius.circular(12),
                    ),
                    if (image.isGif) _buildGifBadge(),
                    if (index == previewImages.length - 1 && images.length > 3)
                      Container(
                        color: const Color(0x66000000),
                        alignment: Alignment.center,
                        child: Text(
                          '+${images.length - 3}',
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGifBadge() {
    return Positioned(
      right: 8,
      bottom: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xAA000000),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'GIF',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  double _safeAspectRatio(HupuHotRankImage image) {
    if (image.width <= 0 || image.height <= 0) {
      return 1.35;
    }
    final ratio = image.width / image.height;
    return ratio.clamp(0.75, 1.85);
  }
}

class _HupuHotRankLightReplyCard extends StatelessWidget {
  const _HupuHotRankLightReplyCard({
    required this.reply,
    this.onTapUser,
  });

  final HupuHotRankLightReply reply;
  final VoidCallback? onTapUser;

  @override
  Widget build(BuildContext context) {
    final previewImage =
        reply.pics.isNotEmpty ? reply.pics.first.url.trim() : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapUser,
            child: ClipOval(
              child: CustomNetworkImage(
                reply.header,
                width: 26,
                height: 26,
                skeletonBorderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onTapUser,
                        child: Text(
                          reply.nickname.isEmpty ? '虎扑用户' : reply.nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF5A5F69),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (reply.lightCount > 0)
                      Text(
                        '亮了 ${_formatNumber(reply.lightCount)}',
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  reply.content,
                  style: const TextStyle(
                    color: Color(0xFF454A54),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                if (previewImage.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomNetworkImage(
                      previewImage,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      skeletonBorderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HupuHotRankStat extends StatelessWidget {
  const _HupuHotRankStat({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF8E8E93),
        ),
        const SizedBox(width: 4),
        Text(
          _formatNumber(value),
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HupuHotRankCategoryState {
  const _HupuHotRankCategoryState({
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
    required this.loadMoreState,
    this.errorMessage,
  });

  final List<HupuHotRankItem> items;
  final bool hasMore;
  final bool isLoadingMore;
  final HupuLoadMoreState loadMoreState;
  final String? errorMessage;

  factory _HupuHotRankCategoryState.fromResponse(HupuHotRankResponse response) {
    final hasMore = response.totalCount > response.items.length;
    return _HupuHotRankCategoryState(
      items: response.items,
      hasMore: hasMore,
      isLoadingMore: false,
      loadMoreState:
          hasMore ? HupuLoadMoreState.idle : HupuLoadMoreState.noMore,
    );
  }

  _HupuHotRankCategoryState copyWith({
    List<HupuHotRankItem>? items,
    bool? hasMore,
    bool? isLoadingMore,
    HupuLoadMoreState? loadMoreState,
    String? errorMessage,
  }) {
    return _HupuHotRankCategoryState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreState: loadMoreState ?? this.loadMoreState,
      errorMessage: errorMessage,
    );
  }
}

String _buildSummaryText(HupuHotRankThread thread) {
  final summary = thread.summary.trim();
  if (summary.isNotEmpty) {
    return summary;
  }

  final normalized = thread.content
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return normalized;
}

String _formatThreadMeta(HupuHotRankThread thread, String fallbackTimeText) {
  final parts = <String>[
    if (thread.topicName.trim().isNotEmpty) thread.topicName.trim(),
  ];

  final timeText = fallbackTimeText.trim().isNotEmpty
      ? fallbackTimeText.trim()
      : _formatAbsoluteTime(thread.createTime);
  if (timeText.isNotEmpty) {
    parts.add(timeText);
  }

  return parts.join('  ');
}

String _formatHeat(int heat) {
  if (heat >= 100000000) {
    return '${(heat / 100000000).toStringAsFixed(1)}亿热度';
  }
  if (heat >= 10000) {
    return '${(heat / 10000).toStringAsFixed(1)}万热度';
  }
  return '$heat热度';
}

String _formatNumber(int value) {
  if (value >= 10000) {
    final display = value / 10000;
    return display >= 100
        ? '${display.toStringAsFixed(0)}万'
        : '${display.toStringAsFixed(1)}万';
  }
  return '$value';
}

String _formatAbsoluteTime(int seconds) {
  if (seconds <= 0) {
    return '';
  }
  final time = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true)
      .toLocal();
  return DateFormat('MM-dd HH:mm').format(time);
}

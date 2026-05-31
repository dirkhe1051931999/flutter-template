// ignore_for_file: file_names

import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_nba_hot_news_page.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_nba_schedule_page.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_refresh_indicator.dart';

const Set<PointerDeviceKind> _nbaTopTabDragDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown,
};

class HupuSportsNbaNewsTab extends StatefulWidget {
  const HupuSportsNbaNewsTab({super.key});

  @override
  State<HupuSportsNbaNewsTab> createState() => _HupuSportsNbaNewsTabState();
}

class _HupuSportsNbaNewsTabState extends State<HupuSportsNbaNewsTab>
    with AutomaticKeepAliveClientMixin<HupuSportsNbaNewsTab> {
  final ScrollController _scrollController = ScrollController();
  List<HupuNbaShortcut> _shortcuts = const <HupuNbaShortcut>[];
  HupuNbaRecommendedMatch? _recommendedMatch;
  List<HupuNbaNewsItem> _hotNews = const <HupuNbaNewsItem>[];
  final List<HupuNbaNewsItem> _news = <HupuNbaNewsItem>[];
  final Set<String> _newsIds = <String>{};
  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _topNewsCount = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    unawaited(_fetchInitial());
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
        _isLoadingMore ||
        !_hasMore) {
      return;
    }
    if (_scrollController.position.extentAfter <= 420) {
      unawaited(_loadMoreNews());
    }
  }

  Future<void> _fetchInitial({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isInitialLoading = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }

    try {
      final data = await getHupuNbaTopTabData();
      if (!mounted) {
        return;
      }
      setState(() {
        _shortcuts = data.shortcuts;
        _recommendedMatch = data.recommendedMatch;
        _hotNews = data.hotNews.take(2).toList(growable: false);
        _topNewsCount = data.topNewsCount;
        _news
          ..clear()
          ..addAll(data.news);
        _newsIds
          ..clear()
          ..addAll(data.news.map((item) => item.nid));
        _hasMore = data.news.isNotEmpty;
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

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore || !_hasMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await getHupuNbaNewsPage(newsId: _nextNewsId);
      final incoming = response.items
          .where((item) => !_newsIds.contains(item.nid))
          .toList(growable: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _news.addAll(incoming);
        _newsIds.addAll(incoming.map((item) => item.nid));
        _hasMore = response.items.isNotEmpty && incoming.isNotEmpty;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      await _fetchInitial(showLoading: false);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
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

  String get _nextNewsId {
    if (_news.isEmpty) {
      return '';
    }
    return _news.last.nid;
  }

  Future<void> _openPostDetail(HupuNbaNewsItem item) async {
    if (item.tid.isEmpty) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuPostDetailPage(
          tid: item.tid,
          initialTitle: item.title,
        ),
      ),
    );
  }

  Future<void> _openHotNewsPage() async {
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => const HupuNbaHotNewsPage(),
      ),
    );
  }

  Future<void> _openSchedulePage() async {
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => const HupuNbaSchedulePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isInitialLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    if (_news.isEmpty && _errorMessage != null) {
      return const SizedBox.shrink();
    }

    return LinkedTabPageRefresh(
      onRefresh: _onRefresh,
      indicatorBuilder: _buildRefreshIndicator,
      child: ScrollConfiguration(
        behavior: const CupertinoScrollBehavior().copyWith(
          dragDevices: _nbaTopTabDragDevices,
        ),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Column(
                  children: [
                    if (_recommendedMatch != null)
                      _NbaMatchCard(
                        match: _recommendedMatch!,
                        onTapSchedule: _openSchedulePage,
                      ),
                    if (_recommendedMatch != null) const SizedBox(height: 30),
                    if (_shortcuts.isNotEmpty) _NbaShortcutRow(items: _shortcuts),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            ),
            if (_news.length > _topNewsCount)
              SliverList.builder(
                itemCount: _topNewsCount,
                itemBuilder: (context, index) {
                  final item = _news[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _NbaArticleTile(
                      article: item,
                      onTap: () => _openPostDetail(item),
                    ),
                  );
                },
              ),
            if (_hotNews.isNotEmpty)
              SliverToBoxAdapter(
                child: _NbaHotNewsSection(
                  items: _hotNews,
                  onTapItem: _openPostDetail,
                  onTapMore: _openHotNewsPage,
                ),
              ),
            SliverList.builder(
              itemCount: (_news.length - _topNewsCount).clamp(0, _news.length),
              itemBuilder: (context, index) {
                final item = _news[index + _topNewsCount];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _NbaArticleTile(
                    article: item,
                    onTap: () => _openPostDetail(item),
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: _NbaLoadMoreFooter(
                isLoading: _isLoadingMore,
                hasMore: _hasMore,
                errorMessage: _errorMessage,
                onRetry: _loadMoreNews,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NbaMatchCard extends StatelessWidget {
  const _NbaMatchCard({
    required this.match,
    required this.onTapSchedule,
  });

  final HupuNbaRecommendedMatch match;
  final VoidCallback onTapSchedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE8E9ED)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MatchTeam(
                  rank: '[${match.awayBigScore}]',
                  name: match.awayTeamName,
                  logoUrl: match.awayTeamLogo,
                  alignRight: true,
                ),
              ),
              const SizedBox(width: 18),
              _MatchTime(match: match),
              const SizedBox(width: 18),
              Expanded(
                child: _MatchTeam(
                  rank: '[${match.homeBigScore}]',
                  name: match.homeTeamName,
                  logoUrl: match.homeTeamLogo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: const Color(0xFFEDEEF2)),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapSchedule,
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  Text(
                    match.dateText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF202127),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    match.matchTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF202127),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    match.matchCountText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF202127),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    size: 18,
                    color: Color(0xFF707682),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchTeam extends StatelessWidget {
  const _MatchTeam({
    required this.rank,
    required this.name,
    required this.logoUrl,
    this.alignRight = false,
  });

  final String rank;
  final String name;
  final String logoUrl;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      '$rank $name',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16, color: Color(0xFF202127)),
    );
    final logo = Image.network(
      logoUrl,
      width: 48,
      height: 48,
      fit: BoxFit.contain,
    );
    return Row(
      mainAxisAlignment:
          alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignRight
          ? <Widget>[Flexible(child: text), const SizedBox(width: 8), logo]
          : <Widget>[logo, const SizedBox(width: 8), Flexible(child: text)],
    );
  }
}

class _MatchTime extends StatelessWidget {
  const _MatchTime({required this.match});

  final HupuNbaRecommendedMatch match;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          match.statusText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202127),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          match.iconText,
          style: const TextStyle(fontSize: 14, color: Color(0xFF8F96A3)),
        ),
      ],
    );
  }
}

class _NbaShortcutRow extends StatelessWidget {
  const _NbaShortcutRow({required this.items});

  final List<HupuNbaShortcut> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.take(5).map((item) => _ShortcutItem(item: item)).toList(),
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  const _ShortcutItem({required this.item});

  final HupuNbaShortcut item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF7F7FB),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.network(item.icon, fit: BoxFit.contain),
                ),
              ),
              if (item.name == '2K手游')
                Positioned(
                  top: 0,
                  right: -1,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF453A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '新游',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            maxLines: 1,
            style: const TextStyle(fontSize: 16, color: Color(0xFF202127)),
          ),
        ],
      ),
    );
  }
}

class _NbaHotNewsSection extends StatelessWidget {
  const _NbaHotNewsSection({
    required this.items,
    required this.onTapItem,
    required this.onTapMore,
  });

  final List<HupuNbaNewsItem> items;
  final ValueChanged<HupuNbaNewsItem> onTapItem;
  final VoidCallback onTapMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 0),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F7), width: 8),
          bottom: BorderSide(color: Color(0xFFF3F4F7), width: 8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
        child: Column(
          children: [
            const _SectionTitle(
              title: '热门资讯',
              subtitle: '实时更新热门资讯',
            ),
            const SizedBox(height: 4),
            ...items.map(
              (item) => _NbaArticleTile(
                article: item,
                onTap: () => onTapItem(item),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapMore,
              child: const SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '查看更多',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4F5663),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 17,
                      color: Color(0xFF8B92A0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF202127),
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF9AA1AE),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _NbaArticleTile extends StatelessWidget {
  const _NbaArticleTile({
    required this.article,
    required this.onTap,
  });

  final HupuNbaNewsItem article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEDEEF2), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.35,
                      color: Color(0xFF202127),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.replySummary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF7D8491),
                          ),
                        ),
                      ),
                      if (article.isPinned) const _PinnedBadge(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                article.imageUrl,
                width: 118,
                height: 84,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedBadge extends StatelessWidget {
  const _PinnedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      color: const Color(0xFFFFECEC),
      child: const Text(
        '置顶',
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFFFF453A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NbaLoadMoreFooter extends StatelessWidget {
  const _NbaLoadMoreFooter({
    required this.isLoading,
    required this.hasMore,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CupertinoActivityIndicator(radius: 12)),
      );
    }

    if (errorMessage != null) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 18),
        onPressed: onRetry,
        child: const Text('加载失败，点此重试'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          hasMore ? '上拉加载更多' : '没有更多了',
          style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
        ),
      ),
    );
  }
}

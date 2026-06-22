// ignore_for_file: file_names

import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/components/route_page_header/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_topic_detail_page.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_refresh_indicator.dart';

const Set<PointerDeviceKind> _sportsNewsTabDragDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.stylus,
  PointerDeviceKind.unknown,
};

class HupuSportsNewsConfig {
  const HupuSportsNewsConfig({
    required this.title,
    required this.categoryCode,
    required this.tagCode,
    required this.pinnedSubtitle,
    required this.hotSubtitle,
    this.showPinned = true,
    this.showHot = true,
    this.showNewsFeed = true,
    this.showTopics = false,
  });

  final String title;
  final String categoryCode;
  final String tagCode;
  final String pinnedSubtitle;
  final String hotSubtitle;
  final bool showPinned;
  final bool showHot;
  final bool showNewsFeed;
  final bool showTopics;
}

class HupuSportsNewsTab extends StatefulWidget {
  const HupuSportsNewsTab({
    required this.config,
    super.key,
  });

  final HupuSportsNewsConfig config;

  @override
  State<HupuSportsNewsTab> createState() => _HupuSportsNewsTabState();
}

class _HupuSportsNewsTabState extends State<HupuSportsNewsTab>
    with AutomaticKeepAliveClientMixin<HupuSportsNewsTab> {
  final ScrollController _scrollController = ScrollController();
  List<HupuSportsNewsItem> _pinnedNews = const <HupuSportsNewsItem>[];
  List<HupuSportsNewsItem> _hotNews = const <HupuSportsNewsItem>[];
  List<HupuCompetitionTopic> _topics = const <HupuCompetitionTopic>[];
  final List<HupuSportsNewsItem> _news = <HupuSportsNewsItem>[];
  final Set<String> _newsIds = <String>{};
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

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
    if (!widget.config.showNewsFeed ||
        !_scrollController.hasClients ||
        _isLoading ||
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
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }

    try {
      final requests = <Future<Object>>[
        getHupuSportsNewsPage(
          categoryCode: widget.config.categoryCode,
          tagCode: widget.config.tagCode,
        ),
      ];
      if (widget.config.showHot) {
        requests.add(
          getHupuSportsHotNews(
            categoryCode: widget.config.categoryCode,
            tagCode: widget.config.tagCode,
            size: 30,
          ),
        );
      }
      if (widget.config.showTopics) {
        requests.add(getHupuCompetitionTopicList(code: widget.config.tagCode));
      }
      final results = await Future.wait<Object>(requests);
      if (!mounted) {
        return;
      }
      final newsPage = results[0] as HupuSportsNewsPage;
      final hotNews = widget.config.showHot
          ? results[1] as HupuSportsHotNewsData
          : const HupuSportsHotNewsData(items: <HupuSportsNewsItem>[]);
      final topicOffset = widget.config.showHot ? 2 : 1;
      final topics = widget.config.showTopics
          ? results[topicOffset] as List<HupuCompetitionTopic>
          : const <HupuCompetitionTopic>[];
      final topNewsCount = _resolveTopNewsCount(newsPage);
      final shouldShowFeed = widget.config.showNewsFeed;
      setState(() {
        _pinnedNews = widget.config.showPinned
            ? newsPage.items.take(topNewsCount).toList(growable: false)
            : const <HupuSportsNewsItem>[];
        _hotNews = hotNews.items.take(2).toList(growable: false);
        _topics = topics;
        _news
          ..clear()
          ..addAll(
            shouldShowFeed
                ? newsPage.items
                    .skip(widget.config.showPinned ? topNewsCount : 0)
                : const <HupuSportsNewsItem>[],
          );
        _newsIds
          ..clear()
          ..addAll(newsPage.items.map((item) => item.nid));
        _hasMore = newsPage.items.isNotEmpty;
        _isLoadingMore = false;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore || !_hasMore) {
      return;
    }
    setState(() {
      _isLoadingMore = true;
      _errorMessage = null;
    });
    try {
      final page = await getHupuSportsNewsPage(
        categoryCode: widget.config.categoryCode,
        tagCode: widget.config.tagCode,
        newsId: _nextNewsId,
      );
      final incoming = page.items
          .where((item) => !_newsIds.contains(item.nid))
          .toList(growable: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _news.addAll(incoming);
        _newsIds.addAll(incoming.map((item) => item.nid));
        _hasMore = page.items.isNotEmpty && incoming.isNotEmpty;
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

  int _resolveTopNewsCount(HupuSportsNewsPage page) {
    if (!widget.config.showPinned) {
      return 0;
    }
    if (page.topNewsCount > 0) {
      return page.topNewsCount.clamp(0, page.items.length);
    }
    final firstNormalIndex = page.items.indexWhere((item) => !item.isPinned);
    if (firstNormalIndex < 0) {
      return page.items.length;
    }
    return firstNormalIndex;
  }

  String get _nextNewsId {
    if (_newsIds.isEmpty) {
      return '';
    }
    if (_news.isNotEmpty) {
      return _news.last.nid;
    }
    if (_pinnedNews.isNotEmpty) {
      return _pinnedNews.last.nid;
    }
    return '';
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

  Future<void> _openPostDetail(HupuSportsNewsItem item) async {
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
        builder: (_) => HupuSportsHotNewsPage(config: widget.config),
      ),
    );
  }

  Future<void> _openTopic(HupuCompetitionTopic topic) async {
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuTopicDetailPage(
          topicId: topic.topicId,
          initialTitle: topic.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    if (_pinnedNews.isEmpty &&
        _hotNews.isEmpty &&
        _topics.isEmpty &&
        _news.isEmpty &&
        _errorMessage != null) {
      return _SportsErrorView(
        detail: _errorMessage,
        onRetry: () => _fetchInitial(),
      );
    }

    return LinkedTabPageRefresh(
      onRefresh: _onRefresh,
      indicatorBuilder: _buildRefreshIndicator,
      child: ScrollConfiguration(
        behavior: const CupertinoScrollBehavior().copyWith(
          dragDevices: _sportsNewsTabDragDevices,
        ),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            if (_topics.isNotEmpty)
              SliverToBoxAdapter(
                child: _CompetitionTopicSection(
                  topics: _topics,
                  onTapTopic: _openTopic,
                ),
              ),
            if (_pinnedNews.isNotEmpty)
              SliverToBoxAdapter(
                child: _SportsNewsSection(
                  title: '置顶新闻',
                  subtitle: widget.config.pinnedSubtitle,
                  items: _pinnedNews,
                  onTapItem: _openPostDetail,
                ),
              ),
            if (_hotNews.isNotEmpty)
              SliverToBoxAdapter(
                child: _SportsHotNewsPreviewSection(
                  subtitle: widget.config.hotSubtitle,
                  items: _hotNews,
                  onTapItem: _openPostDetail,
                  onTapMore: _openHotNewsPage,
                ),
              ),
            if (_news.isNotEmpty)
              SliverToBoxAdapter(
                child: _SportsNewsSection(
                  title: '普通新闻',
                  subtitle: '上拉加载更多',
                  items: _news,
                  onTapItem: _openPostDetail,
                ),
              ),
            if (widget.config.showNewsFeed)
              SliverToBoxAdapter(
                child: _SportsLoadMoreFooter(
                  isLoading: _isLoadingMore,
                  hasMore: _hasMore,
                  errorMessage: _errorMessage,
                  onRetry: _loadMoreNews,
                ),
              ),
            if (_errorMessage != null)
              SliverToBoxAdapter(
                child: _InlineErrorText(detail: _errorMessage!),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class HupuSportsHotNewsPage extends StatefulWidget {
  const HupuSportsHotNewsPage({
    required this.config,
    super.key,
  });

  final HupuSportsNewsConfig config;

  @override
  State<HupuSportsHotNewsPage> createState() => _HupuSportsHotNewsPageState();
}

class _HupuSportsHotNewsPageState extends State<HupuSportsHotNewsPage> {
  final ScrollController _scrollController = ScrollController();
  final List<HupuSportsNewsItem> _items = <HupuSportsNewsItem>[];
  final Set<String> _newsIds = <String>{};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  String? _errorMessage;

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
        _isLoading ||
        _isLoadingMore ||
        !_hasMore) {
      return;
    }
    if (_scrollController.position.extentAfter <= 420) {
      unawaited(_loadMore());
    }
  }

  Future<void> _fetchInitial() async {
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _errorMessage = null;
      _page = 1;
    });
    try {
      final data = await getHupuSportsHotNews(
        categoryCode: widget.config.categoryCode,
        tagCode: widget.config.tagCode,
        page: 1,
        size: 30,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _items
          ..clear()
          ..addAll(data.items);
        _newsIds
          ..clear()
          ..addAll(data.items.map((item) => item.nid));
        _hasMore = data.items.isNotEmpty;
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

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) {
      return;
    }
    final nextPage = _page + 1;
    setState(() {
      _isLoadingMore = true;
      _errorMessage = null;
    });
    try {
      final data = await getHupuSportsHotNews(
        categoryCode: widget.config.categoryCode,
        tagCode: widget.config.tagCode,
        page: nextPage,
        size: 30,
      );
      final incoming = data.items
          .where((item) => !_newsIds.contains(item.nid))
          .toList(growable: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _page = nextPage;
        _items.addAll(incoming);
        _newsIds.addAll(incoming.map((item) => item.nid));
        _hasMore = data.items.isNotEmpty && incoming.isNotEmpty;
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

  Future<void> _openPostDetail(HupuSportsNewsItem item) async {
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: RoutePageNavigationBar(
        title: '热门资讯',
        subtitle: widget.config.title,
        onBack: () => Navigator.of(context).maybePop(),
        height: 68,
      ),
      child: SafeArea(
        bottom: false,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }
    if (_items.isEmpty && _errorMessage != null) {
      return _SportsErrorView(detail: _errorMessage, onRetry: _fetchInitial);
    }
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          sliver: SliverList.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return _SportsHotNewsTile(
                item: item,
                onTap: () => _openPostDetail(item),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: _SportsLoadMoreFooter(
            isLoading: _isLoadingMore,
            hasMore: _hasMore,
            errorMessage: _errorMessage,
            onRetry: _loadMore,
          ),
        ),
      ],
    );
  }
}

class _CompetitionTopicSection extends StatelessWidget {
  const _CompetitionTopicSection({
    required this.topics,
    required this.onTapTopic,
  });

  final List<HupuCompetitionTopic> topics;
  final ValueChanged<HupuCompetitionTopic> onTapTopic;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F7), width: 6),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '热门话题',
            style: TextStyle(
              color: Color(0xFF202127),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 12,
            children: topics
                .map(
                  (topic) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTapTopic(topic),
                    child: Text(
                      topic.name,
                      style: const TextStyle(
                        color: Color(0xFF3B414C),
                        fontSize: 16,
                        height: 1.2,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _SportsHotNewsPreviewSection extends StatelessWidget {
  const _SportsHotNewsPreviewSection({
    required this.subtitle,
    required this.items,
    required this.onTapItem,
    required this.onTapMore,
  });

  final String subtitle;
  final List<HupuSportsNewsItem> items;
  final ValueChanged<HupuSportsNewsItem> onTapItem;
  final VoidCallback onTapMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      color: CupertinoColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
        child: Column(
          children: [
            _SectionTitle(title: '热门资讯', subtitle: subtitle),
            const SizedBox(height: 2),
            ...items.map(
              (item) => _SportsArticleTile(
                article: item,
                imageWidth: 112,
                imageHeight: 68,
                onTap: () => onTapItem(item),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapMore,
              child: const SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '查看更多',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4F5663),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
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

class _SportsNewsSection extends StatelessWidget {
  const _SportsNewsSection({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.onTapItem,
  });

  final String title;
  final String subtitle;
  final List<HupuSportsNewsItem> items;
  final ValueChanged<HupuSportsNewsItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      color: CupertinoColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
        child: Column(
          children: [
            _SectionTitle(title: title, subtitle: subtitle),
            const SizedBox(height: 2),
            ...items.map(
              (item) => _SportsArticleTile(
                article: item,
                imageWidth: 96,
                imageHeight: 68,
                onTap: () => onTapItem(item),
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
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF9AA1AE),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SportsArticleTile extends StatelessWidget {
  const _SportsArticleTile({
    required this.article,
    required this.imageWidth,
    required this.imageHeight,
    required this.onTap,
  });

  final HupuSportsNewsItem article;
  final double imageWidth;
  final double imageHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
                      fontSize: 17,
                      height: 1.3,
                      color: Color(0xFF202127),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.replySummary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
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
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CustomNetworkImage(
                article.imageUrl,
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
                skeletonBorderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SportsHotNewsTile extends StatelessWidget {
  const _SportsHotNewsTile({
    required this.item,
    required this.onTap,
  });

  final HupuSportsNewsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SportsArticleTile(
      article: item,
      imageWidth: 118,
      imageHeight: 84,
      onTap: onTap,
    );
  }
}

class _PinnedBadge extends StatelessWidget {
  const _PinnedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      color: const Color(0xFFFFECEC),
      child: const Text(
        '置顶',
        style: TextStyle(
          fontSize: 11,
          color: Color(0xFFFF453A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SportsLoadMoreFooter extends StatelessWidget {
  const _SportsLoadMoreFooter({
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
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CupertinoActivityIndicator(radius: 10)),
      );
    }
    if (errorMessage != null) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 14),
        onPressed: onRetry,
        child: const Text(
          '加载失败，点此重试',
          style: TextStyle(fontSize: 13, color: Color(0xFFE5484D)),
        ),
      );
    }
    if (!hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(
            '没有更多了',
            style: TextStyle(fontSize: 12, color: Color(0xFF9AA1AE)),
          ),
        ),
      );
    }
    return const SizedBox(height: 18);
  }
}

class _SportsErrorView extends StatelessWidget {
  const _SportsErrorView({
    required this.detail,
    required this.onRetry,
  });

  final String? detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton(
        onPressed: onRetry,
        child: Text(detail == null ? '加载失败，点此重试' : '加载失败，点此重试\n$detail'),
      ),
    );
  }
}

class _InlineErrorText extends StatelessWidget {
  const _InlineErrorText({required this.detail});

  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Text(
        '部分内容加载失败：$detail',
        style: const TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 12,
          height: 1.4,
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_load_more_footer.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_refresh_indicator.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_status_view.dart';

const String _homeTeamDefaultTeamId = '1901000000501300';
const int _homeTeamDefaultTopicId = 132;
const String _homeTeamDefaultTagName = '独行侠专区';

class HupuHomeTeamPage extends StatefulWidget {
  const HupuHomeTeamPage({
    this.teamId,
    this.showPageHeader = true,
    super.key,
  });

  final String? teamId;
  final bool showPageHeader;

  @override
  State<HupuHomeTeamPage> createState() => _HupuHomeTeamPageState();
}

class _HupuHomeTeamPageState extends State<HupuHomeTeamPage> {
  HupuAttentionTeam? _team;
  List<HupuHomeTeamTab> _tabs = const <HupuHomeTeamTab>[];
  bool _isLoading = true;
  String? _errorMessage;

  String get _effectiveTeamId {
    final id = _team?.teamId ?? '';
    if (id.isNotEmpty) {
      return id;
    }
    final configuredId = widget.teamId ?? '';
    if (configuredId.isNotEmpty) {
      return configuredId;
    }
    return _homeTeamDefaultTeamId;
  }

  int get _effectiveTopicId {
    final topicId = _team?.topicId ?? 0;
    if (topicId > 0) {
      return topicId;
    }
    return _homeTeamDefaultTopicId;
  }

  String get _effectiveTopicName {
    final topicName = _team?.topicName ?? '';
    if (topicName.isNotEmpty) {
      return topicName;
    }
    return _homeTeamDefaultTagName;
  }

  List<HupuHomeTeamTab> get _displayTabs {
    final normalizedTabs = <String, HupuHomeTeamTab>{};
    for (final item in _tabs) {
      if (!item.showTab) {
        continue;
      }
      final normalizedKey = _normalizeTabKey(item);
      if (normalizedKey.isEmpty || normalizedTabs.containsKey(normalizedKey)) {
        continue;
      }
      normalizedTabs[normalizedKey] = HupuHomeTeamTab(
        key: normalizedKey,
        name: _resolveTabName(normalizedKey, item.name),
        url: item.url,
        showTab: true,
      );
    }

    final defaults = <String, HupuHomeTeamTab>{
      'bbs':
          const HupuHomeTeamTab(key: 'bbs', name: '专区', url: '', showTab: true),
      'news': const HupuHomeTeamTab(
          key: 'news', name: '资讯', url: '', showTab: true),
      'games': const HupuHomeTeamTab(
          key: 'games', name: '赛程', url: '', showTab: true),
      'players': const HupuHomeTeamTab(
          key: 'players', name: '球员', url: '', showTab: true),
    };

    return <HupuHomeTeamTab>[
      normalizedTabs['bbs'] ?? defaults['bbs']!,
      normalizedTabs['news'] ?? defaults['news']!,
      normalizedTabs['games'] ?? defaults['games']!,
      normalizedTabs['players'] ?? defaults['players']!,
    ];
  }

  String _normalizeTabKey(HupuHomeTeamTab tab) {
    final key = tab.key.toLowerCase();
    final name = tab.name;
    if (key == 'bbs' || name.contains('专区')) {
      return 'bbs';
    }
    if (key == 'news' || name.contains('资讯')) {
      return 'news';
    }
    if (key.contains('game') ||
        key.contains('schedule') ||
        name.contains('赛程')) {
      return 'games';
    }
    if (key.contains('player') || name.contains('球员')) {
      return 'players';
    }
    return '';
  }

  String _resolveTabName(String key, String name) {
    if (name.isNotEmpty) {
      return name;
    }
    if (key == 'bbs') {
      return '专区';
    }
    if (key == 'news') {
      return '资讯';
    }
    if (key == 'games') {
      return '赛程';
    }
    return '球员';
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadInitial());
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final attentionData = await getHupuAttentionTeamList();
      final configuredTeamId = widget.teamId ?? _homeTeamDefaultTeamId;
      final resolvedTeam = _resolveTeam(attentionData.teams, configuredTeamId);
      final teamId = resolvedTeam?.teamId ?? configuredTeamId;
      final tabs = await getHupuHomeTeamTabs(teamId: teamId);

      if (!mounted) {
        return;
      }
      setState(() {
        _team = resolvedTeam;
        _tabs = tabs;
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

  HupuAttentionTeam? _resolveTeam(
    List<HupuAttentionTeam> teams,
    String configuredTeamId,
  ) {
    if (teams.isEmpty) {
      return null;
    }
    final targetId =
        configuredTeamId.isNotEmpty ? configuredTeamId : _homeTeamDefaultTeamId;
    final exactIndex = teams.indexWhere((item) => item.teamId == targetId);
    if (exactIndex >= 0) {
      return teams[exactIndex];
    }
    return teams.first;
  }

  Future<void> _openPostDetailByTid(
    String tid, {
    String initialTitle = '',
  }) async {
    if (tid.isEmpty) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuPostDetailPage(
          tid: tid,
          topicId: _effectiveTopicId,
          initialTitle: initialTitle,
        ),
      ),
    );
  }

  Widget _buildTabChild(HupuHomeTeamTab tab) {
    if (tab.key == 'bbs') {
      return _HomeTeamBbsTab(
        topicId: _effectiveTopicId,
        topicName: _effectiveTopicName,
        onTapThread: (thread) {
          return _openPostDetailByTid(
            thread.tid,
            initialTitle: thread.title,
          );
        },
      );
    }
    if (tab.key == 'news') {
      return _HomeTeamNewsTab(
        teamId: _effectiveTeamId,
        onTapNews: (news) {
          return _openPostDetailByTid(
            news.tid,
            initialTitle: news.title,
          );
        },
      );
    }
    if (tab.key == 'games') {
      return _HomeTeamScheduleTab(teamId: _effectiveTeamId);
    }
    return _HomeTeamPlayersTab(teamId: _effectiveTeamId);
  }

  int _resolveInitialTabIndex(List<HupuHomeTeamTab> tabs) {
    final bbsIndex = tabs.indexWhere((item) => item.key == 'bbs');
    return bbsIndex < 0 ? 0 : bbsIndex;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _displayTabs;
    final body = _isLoading
        ? const Center(child: CupertinoActivityIndicator(radius: 14))
        : _errorMessage != null && _team == null
            ? HupuStatusView(
                message: '主队加载失败',
                detail: _errorMessage,
                onRetry: _loadInitial,
              )
            : LinkedTabView(
                items: tabs
                    .map(
                      (item) => LinkedTabItem(
                        id: item.key,
                        label: item.name,
                        child: _buildTabChild(item),
                      ),
                    )
                    .toList(growable: false),
                initialIndex: _resolveInitialTabIndex(tabs),
                tabBarHeight: 44,
                tabBarPadding: const EdgeInsets.symmetric(horizontal: 12),
                tabSpacing: 28,
                activeTabColor: const Color(0xFF202127),
                inactiveTabColor: const Color(0xFF9398A5),
                activeIndicatorColor: const Color(0xFFE5484D),
                activeFontSize: 17,
                inactiveFontSize: 17,
              );

    if (!widget.showPageHeader) {
      return ColoredBox(
        color: const Color(0xFFFFFFFF),
        child: body,
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('我的主队'),
      ),
      child: SafeArea(
        bottom: false,
        child: body,
      ),
    );
  }
}

class _HomeTeamNewsTab extends StatefulWidget {
  const _HomeTeamNewsTab({
    required this.teamId,
    required this.onTapNews,
  });

  final String teamId;
  final Future<void> Function(HupuHomeTeamNewsItem item) onTapNews;

  @override
  State<_HomeTeamNewsTab> createState() => _HomeTeamNewsTabState();
}

class _HomeTeamNewsTabState extends State<_HomeTeamNewsTab>
    with AutomaticKeepAliveClientMixin<_HomeTeamNewsTab> {
  final ScrollController _scrollController = ScrollController();
  final List<HupuHomeTeamNewsItem> _items = <HupuHomeTeamNewsItem>[];
  final Set<String> _nidSet = <String>{};

  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  HupuLoadMoreState _loadMoreState = HupuLoadMoreState.idle;

  @override
  bool get wantKeepAlive => true;

  String get _nextNewsId {
    if (_items.isEmpty) {
      return '0';
    }
    return _items.last.nid;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    unawaited(_loadInitial());
  }

  @override
  void didUpdateWidget(covariant _HomeTeamNewsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teamId != widget.teamId) {
      unawaited(_loadInitial());
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
    if (!_scrollController.hasClients ||
        _isInitialLoading ||
        _isLoadingMore ||
        !_hasMore) {
      return;
    }
    if (_scrollController.position.extentAfter <= 420) {
      unawaited(_loadMore());
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await getHupuHomeTeamNewsPage(
        teamId: widget.teamId,
        newsId: '0',
      );
      if (!mounted) {
        return;
      }

      final merged = _mergeItems(response.items, reset: true);
      final hasMore = merged.isNotEmpty;
      setState(() {
        _items
          ..clear()
          ..addAll(merged);
        _hasMore = hasMore;
        _loadMoreState =
            hasMore ? HupuLoadMoreState.idle : HupuLoadMoreState.noMore;
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
      final response = await getHupuHomeTeamNewsPage(
        teamId: widget.teamId,
        newsId: _nextNewsId,
      );
      if (!mounted) {
        return;
      }

      final beforeCount = _items.length;
      final merged = _mergeItems(response.items);
      final appendedCount = merged.length - beforeCount;
      final hasMore = response.items.isNotEmpty && appendedCount > 0;

      setState(() {
        _items
          ..clear()
          ..addAll(merged);
        _hasMore = hasMore;
        _errorMessage = null;
        _loadMoreState =
            hasMore ? HupuLoadMoreState.idle : HupuLoadMoreState.noMore;
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

  List<HupuHomeTeamNewsItem> _mergeItems(
    List<HupuHomeTeamNewsItem> incoming, {
    bool reset = false,
  }) {
    if (reset) {
      _nidSet.clear();
    }
    final merged = reset
        ? <HupuHomeTeamNewsItem>[]
        : List<HupuHomeTeamNewsItem>.from(_items);
    for (final item in incoming) {
      if (item.nid.isEmpty || _nidSet.contains(item.nid)) {
        continue;
      }
      _nidSet.add(item.nid);
      merged.add(item);
    }
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isInitialLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 13));
    }

    if (_errorMessage != null && _items.isEmpty) {
      return HupuStatusView(
        message: '资讯加载失败',
        detail: _errorMessage,
        onRetry: _loadInitial,
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text(
          '暂无资讯',
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
        SliverList.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return _HomeTeamNewsTile(
              item: item,
              onTap: () => widget.onTapNews(item),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
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

class _HomeTeamNewsTile extends StatelessWidget {
  const _HomeTeamNewsTile({
    required this.item,
    required this.onTap,
  });

  final HupuHomeTeamNewsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl.trim().isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F1F4), width: 0.7),
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
                    item.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 17,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.replySummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomNetworkImage(
                  item.imageUrl,
                  width: 118,
                  height: 82,
                  fit: BoxFit.cover,
                  skeletonBorderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeTeamBbsTab extends StatefulWidget {
  const _HomeTeamBbsTab({
    required this.topicId,
    required this.topicName,
    required this.onTapThread,
  });

  final int topicId;
  final String topicName;
  final Future<void> Function(HupuHomeTeamTopicThread item) onTapThread;

  @override
  State<_HomeTeamBbsTab> createState() => _HomeTeamBbsTabState();
}

class _HomeTeamBbsTabState extends State<_HomeTeamBbsTab>
    with AutomaticKeepAliveClientMixin<_HomeTeamBbsTab> {
  final ScrollController _scrollController = ScrollController();
  final List<HupuHomeTeamTopicThread> _items = <HupuHomeTeamTopicThread>[];
  final Set<String> _tidSet = <String>{};

  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  HupuLoadMoreState _loadMoreState = HupuLoadMoreState.idle;
  int _page = 1;
  int _stamp = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    unawaited(_loadInitial());
  }

  @override
  void didUpdateWidget(covariant _HomeTeamBbsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topicId != widget.topicId) {
      unawaited(_loadInitial());
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
    if (!_scrollController.hasClients ||
        _isInitialLoading ||
        _isLoadingMore ||
        !_hasMore) {
      return;
    }
    if (_scrollController.position.extentAfter <= 420) {
      unawaited(_loadMore());
    }
  }

  int _requestWidth() {
    return 518;
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await getHupuHomeTeamTopicThreads(
        topicId: widget.topicId,
        page: 1,
        stamp: 0,
        width: _requestWidth(),
      );
      if (!mounted) {
        return;
      }

      final merged = _mergeItems(response.items, reset: true);
      final hasMore = response.hasNextPage && merged.isNotEmpty;
      setState(() {
        _items
          ..clear()
          ..addAll(merged);
        _page = 1;
        _stamp = response.stamp;
        _hasMore = hasMore;
        _loadMoreState =
            hasMore ? HupuLoadMoreState.idle : HupuLoadMoreState.noMore;
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
      final response = await getHupuHomeTeamTopicThreads(
        topicId: widget.topicId,
        page: _page + 1,
        stamp: _stamp,
        width: _requestWidth(),
      );
      if (!mounted) {
        return;
      }

      final beforeCount = _items.length;
      final merged = _mergeItems(response.items);
      final appendedCount = merged.length - beforeCount;
      final hasMore = response.hasNextPage && appendedCount > 0;

      setState(() {
        _items
          ..clear()
          ..addAll(merged);
        _page += 1;
        _stamp = response.stamp;
        _hasMore = hasMore;
        _errorMessage = null;
        _loadMoreState =
            hasMore ? HupuLoadMoreState.idle : HupuLoadMoreState.noMore;
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

  List<HupuHomeTeamTopicThread> _mergeItems(
    List<HupuHomeTeamTopicThread> incoming, {
    bool reset = false,
  }) {
    if (reset) {
      _tidSet.clear();
    }
    final merged = reset
        ? <HupuHomeTeamTopicThread>[]
        : List<HupuHomeTeamTopicThread>.from(_items);
    for (final item in incoming) {
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
      return const Center(child: CupertinoActivityIndicator(radius: 13));
    }

    if (_errorMessage != null && _items.isEmpty) {
      return HupuStatusView(
        message: '专区加载失败',
        detail: _errorMessage,
        onRetry: _loadInitial,
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text(
          '暂无帖子',
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 2),
            child: Text(
              widget.topicName,
              style: const TextStyle(
                color: Color(0xFF7E8796),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return _HomeTeamThreadTile(
              item: item,
              onTap: () => widget.onTapThread(item),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
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

class _HomeTeamThreadTile extends StatelessWidget {
  const _HomeTeamThreadTile({
    required this.item,
    required this.onTap,
  });

  final HupuHomeTeamTopicThread item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl.trim().isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F1F4), width: 0.7),
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
                    item.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 17,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8D95A4),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.replies} 回复 / ${item.lightReplies} 推荐',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomNetworkImage(
                  item.imageUrl,
                  width: 114,
                  height: 76,
                  fit: BoxFit.cover,
                  skeletonBorderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeTeamScheduleTab extends StatefulWidget {
  const _HomeTeamScheduleTab({required this.teamId});

  final String teamId;

  @override
  State<_HomeTeamScheduleTab> createState() => _HomeTeamScheduleTabState();
}

class _HomeTeamScheduleTabState extends State<_HomeTeamScheduleTab>
    with AutomaticKeepAliveClientMixin<_HomeTeamScheduleTab> {
  final ScrollController _scrollController = ScrollController();
  final List<HupuHomeTeamScheduleDay> _days = <HupuHomeTeamScheduleDay>[];
  final Set<String> _dayKeys = <String>{};
  final Map<String, GlobalKey> _dayAnchors = <String, GlobalKey>{};

  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingPrev = false;
  bool _isLoadingNext = false;
  bool _hasPrev = true;
  bool _hasNext = true;
  bool _showTodayButton = false;
  bool _isAutoFocusing = false;
  String? _errorMessage;
  HupuHomeTeamScheduleStats? _stats;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    unawaited(_loadInitial());
  }

  @override
  void didUpdateWidget(covariant _HomeTeamScheduleTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teamId != widget.teamId) {
      unawaited(_loadInitial());
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
    if (!_scrollController.hasClients ||
        _isInitialLoading ||
        _isRefreshing ||
        _days.isEmpty) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels <= 180) {
      unawaited(_loadPrev());
    }
    if (position.extentAfter <= 380) {
      unawaited(_loadNext());
    }
    final show = _shouldShowTodayButton();
    if (show != _showTodayButton) {
      setState(() {
        _showTodayButton = show;
      });
    }
  }

  bool get _canLoadPrevByStats {
    final stats = _stats;
    if (stats == null || _days.isEmpty) {
      return true;
    }
    if (stats.earliestDate.isEmpty) {
      return true;
    }
    return _days.first.day.compareTo(stats.earliestDate) > 0;
  }

  bool get _canLoadNextByStats {
    final stats = _stats;
    if (stats == null || _days.isEmpty) {
      return true;
    }
    if (stats.latestDate.isEmpty) {
      return true;
    }
    return _days.last.day.compareTo(stats.latestDate) < 0;
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await getHupuHomeTeamScheduleList(teamId: widget.teamId);
      if (!mounted) {
        return;
      }
      final merged = _mergeDays(response.days, reset: true);
      setState(() {
        _dayAnchors.clear();
        _days
          ..clear()
          ..addAll(merged);
        _stats = response.stats;
        _hasPrev = merged.isNotEmpty && _canLoadPrevByStats;
        _hasNext = merged.isNotEmpty && _canLoadNextByStats;
        _isInitialLoading = false;
      });
      unawaited(_ensureFocusedRangeLoadedAndScroll(animated: false));
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
      _errorMessage = null;
    });
    try {
      final response = await getHupuHomeTeamScheduleList(teamId: widget.teamId);
      if (!mounted) {
        return;
      }
      final merged = _mergeDays(response.days, reset: true);
      setState(() {
        _dayAnchors.clear();
        _days
          ..clear()
          ..addAll(merged);
        _stats = response.stats;
        _hasPrev = merged.isNotEmpty && _canLoadPrevByStats;
        _hasNext = merged.isNotEmpty && _canLoadNextByStats;
      });
      unawaited(_ensureFocusedRangeLoadedAndScroll(animated: false));
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

  Future<void> _loadPrev() async {
    if (_isInitialLoading || _isRefreshing || _isLoadingPrev || !_hasPrev) {
      return;
    }
    final cursor = _days.isEmpty ? '' : _dateOffset(_days.first.day, -1);
    if (cursor.isEmpty) {
      setState(() {
        _hasPrev = false;
      });
      return;
    }

    setState(() {
      _isLoadingPrev = true;
    });
    final oldMaxExtent = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent
        : 0.0;

    try {
      final response = await getHupuHomeTeamScheduleList(
        teamId: widget.teamId,
        cursor: cursor,
        direction: HupuHomeTeamScheduleDirection.prev,
      );
      if (!mounted) {
        return;
      }
      final incoming = response.days
          .where((item) => item.day.isNotEmpty && !_dayKeys.contains(item.day))
          .toList(growable: false);
      setState(() {
        _days.insertAll(0, incoming);
        _dayKeys.addAll(incoming.map((item) => item.day));
        _stats = response.stats;
        _errorMessage = null;
        _hasPrev = incoming.isNotEmpty && _canLoadPrevByStats;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) {
          return;
        }
        final delta = _scrollController.position.maxScrollExtent - oldMaxExtent;
        _scrollController.jumpTo(_scrollController.offset + delta);
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
          _isLoadingPrev = false;
        });
      }
    }
  }

  Future<void> _loadNext() async {
    if (_isInitialLoading || _isRefreshing || _isLoadingNext || !_hasNext) {
      return;
    }
    final cursor = _days.isEmpty ? '' : _dateOffset(_days.last.day, 1);
    if (cursor.isEmpty) {
      setState(() {
        _hasNext = false;
      });
      return;
    }

    setState(() {
      _isLoadingNext = true;
    });

    try {
      final response = await getHupuHomeTeamScheduleList(
        teamId: widget.teamId,
        cursor: cursor,
        direction: HupuHomeTeamScheduleDirection.next,
      );
      if (!mounted) {
        return;
      }
      final incoming = response.days
          .where((item) => item.day.isNotEmpty && !_dayKeys.contains(item.day))
          .toList(growable: false);
      setState(() {
        _days.addAll(incoming);
        _dayKeys.addAll(incoming.map((item) => item.day));
        _stats = response.stats;
        _errorMessage = null;
        _hasNext = incoming.isNotEmpty && _canLoadNextByStats;
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
          _isLoadingNext = false;
        });
      }
    }
  }

  List<HupuHomeTeamScheduleDay> _mergeDays(
    List<HupuHomeTeamScheduleDay> incoming, {
    bool reset = false,
  }) {
    if (reset) {
      _dayKeys.clear();
    }
    final merged = reset
        ? <HupuHomeTeamScheduleDay>[]
        : List<HupuHomeTeamScheduleDay>.from(_days);
    for (final item in incoming) {
      if (item.day.isEmpty || _dayKeys.contains(item.day)) {
        continue;
      }
      _dayKeys.add(item.day);
      merged.add(item);
    }
    return merged;
  }

  bool _shouldShowTodayButton() {
    final focusDay = _resolvedFocusDay;
    if (focusDay.isEmpty || !_dayKeys.contains(focusDay)) {
      return false;
    }
    final anchorContext = _dayAnchors[focusDay]?.currentContext;
    if (anchorContext == null) {
      return true;
    }
    final box = anchorContext.findRenderObject();
    if (box is! RenderBox) {
      return true;
    }
    final offset = box.localToGlobal(Offset.zero).dy;
    return offset < 106 || offset > MediaQuery.of(context).size.height - 260;
  }

  void _scrollToToday({bool animated = true}) {
    final offset = _scrollOffsetForDay(_resolvedFocusDay);
    if (offset == null || !_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    final target =
        offset.clamp(position.minScrollExtent, position.maxScrollExtent);
    if (!animated) {
      _scrollController.jumpTo(target);
      return;
    }
    unawaited(
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      ),
    );
    if (_showTodayButton) {
      setState(() {
        _showTodayButton = false;
      });
    }
  }

  Future<void> _ensureFocusedRangeLoadedAndScroll(
      {required bool animated}) async {
    if (_isAutoFocusing || _days.isEmpty) {
      return;
    }
    _isAutoFocusing = true;
    try {
      final targetDate = _localTodayKey;
      while (mounted &&
          _days.isNotEmpty &&
          _days.last.day.compareTo(targetDate) < 0 &&
          _hasNext) {
        await _loadNext();
      }
      while (mounted &&
          _days.isNotEmpty &&
          _days.first.day.compareTo(targetDate) > 0 &&
          _hasPrev) {
        await _loadPrev();
      }
      if (!mounted) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToToday(animated: animated);
      });
    } finally {
      _isAutoFocusing = false;
    }
  }

  String get _resolvedFocusDay {
    final anchorMatchId = _stats?.anchorMatchId ?? '';
    if (anchorMatchId.isNotEmpty) {
      for (final day in _days) {
        for (final match in day.matches) {
          if (match.matchId == anchorMatchId) {
            return day.day;
          }
        }
      }
    }

    HupuHomeTeamScheduleDay? closestPastOrToday;
    HupuHomeTeamScheduleDay? closestFuture;
    for (final day in _days) {
      if (day.day.isEmpty) {
        continue;
      }
      if (day.day.compareTo(_localTodayKey) <= 0) {
        closestPastOrToday = day;
      } else {
        closestFuture ??= day;
      }
    }
    if (closestPastOrToday != null) {
      return closestPastOrToday.day;
    }
    if (closestFuture != null) {
      return closestFuture.day;
    }

    return _days.isNotEmpty ? _days.first.day : '';
  }

  String get _localTodayKey {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  double? _scrollOffsetForDay(String day) {
    if (day.isEmpty) {
      return null;
    }
    var offset = 0.0;
    for (final item in _days) {
      if (item.day == day) {
        return offset;
      }
      offset += 42 + (item.matches.length * 98);
    }
    return null;
  }

  GlobalKey _anchorForDay(String day) {
    return _dayAnchors.putIfAbsent(day, GlobalKey.new);
  }

  Widget _buildRefreshIndicator(
    BuildContext context,
    LinkedTabRefreshState state,
    double progress,
  ) {
    final isArmed = state == LinkedTabRefreshState.armed ||
        state == LinkedTabRefreshState.refreshing;
    final isRefreshing = state == LinkedTabRefreshState.refreshing ||
        state == LinkedTabRefreshState.complete;
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
      return const Center(child: CupertinoActivityIndicator(radius: 13));
    }

    if (_errorMessage != null && _days.isEmpty) {
      return HupuStatusView(
        message: '赛程加载失败',
        detail: _errorMessage,
        onRetry: _loadInitial,
      );
    }

    if (_days.isEmpty) {
      return const Center(
        child: Text(
          '暂无赛程',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 14,
          ),
        ),
      );
    }

    return LinkedTabPageRefresh(
      onRefresh: _onRefresh,
      indicatorBuilder: _buildRefreshIndicator,
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _TopLoadingIndicator(
                  isLoading: _isLoadingPrev,
                  hasMore: _hasPrev,
                ),
              ),
              SliverList.builder(
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  final day = _days[index];
                  return _HomeTeamScheduleDaySection(
                    key: _anchorForDay(day.day),
                    day: day,
                  );
                },
              ),
              SliverToBoxAdapter(
                child: _BottomLoadingIndicator(
                  isLoading: _isLoadingNext,
                  hasMore: _hasNext,
                ),
              ),
            ],
          ),
          if (_showTodayButton)
            Positioned(
              left: 0,
              right: 0,
              bottom: 78,
              child: Center(
                child: _TodayFloatingButton(
                  onTap: () => _scrollToToday(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeTeamScheduleDaySection extends StatelessWidget {
  const _HomeTeamScheduleDaySection({
    required this.day,
    super.key,
  });

  final HupuHomeTeamScheduleDay day;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 42,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          color: const Color(0xFFF4F5F8),
          child: Text(
            day.dayBlock,
            style: const TextStyle(
              color: Color(0xFF6E7582),
              fontSize: 14,
            ),
          ),
        ),
        ...day.matches.map((item) => _HomeTeamScheduleMatchTile(match: item)),
      ],
    );
  }
}

class _TodayFloatingButton extends StatelessWidget {
  const _TodayFloatingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        width: 62,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFE91B2A),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24E91B2A),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          '今日',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TopLoadingIndicator extends StatelessWidget {
  const _TopLoadingIndicator({
    required this.isLoading,
    required this.hasMore,
  });

  final bool isLoading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && hasMore) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 40,
      child: Center(
        child: isLoading
            ? const CupertinoActivityIndicator(radius: 10)
            : const Text(
                '已经到最前了',
                style: TextStyle(
                  color: Color(0xFF9AA1AE),
                  fontSize: 12,
                ),
              ),
      ),
    );
  }
}

class _BottomLoadingIndicator extends StatelessWidget {
  const _BottomLoadingIndicator({
    required this.isLoading,
    required this.hasMore,
  });

  final bool isLoading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Center(
        child: isLoading
            ? const CupertinoActivityIndicator(radius: 10)
            : Text(
                hasMore ? '' : '没有更多了',
                style: const TextStyle(
                  color: Color(0xFF9AA1AE),
                  fontSize: 13,
                ),
              ),
      ),
    );
  }
}

class _HomeTeamScheduleMatchTile extends StatelessWidget {
  const _HomeTeamScheduleMatchTile({required this.match});

  final HupuHomeTeamScheduleMatch match;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEEF2), width: 0.7),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.timeText,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    match.stageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9AA1AE),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HomeTeamScheduleTeamLine(
                  logoUrl: match.awayTeamLogo,
                  name: match.awayTeamName,
                  bigScore: match.awayBigScore,
                ),
                const SizedBox(height: 8),
                _HomeTeamScheduleTeamLine(
                  logoUrl: match.homeTeamLogo,
                  name: match.homeTeamName,
                  bigScore: match.homeBigScore,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 38,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _scoreText(match.awayScore),
                  style: TextStyle(
                    color: match.isCompleted
                        ? const Color(0xFF9AA1AE)
                        : const Color(0xFF202127),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _scoreText(match.homeScore),
                  style: const TextStyle(
                    color: Color(0xFF202127),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 58,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: const Color(0xFFEDEEF2),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    match.rightTitle,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (match.scoreText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      match.scoreText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9AA1AE),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _scoreText(int? score) => score == null ? '-' : '$score';
}

class _HomeTeamScheduleTeamLine extends StatelessWidget {
  const _HomeTeamScheduleTeamLine({
    required this.logoUrl,
    required this.name,
    required this.bigScore,
  });

  final String logoUrl;
  final String name;
  final int? bigScore;

  @override
  Widget build(BuildContext context) {
    final suffix = bigScore == null ? '' : '($bigScore)';
    return Row(
      children: [
        Image.network(
          logoUrl,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$name$suffix',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF202127),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeTeamPlayersTab extends StatefulWidget {
  const _HomeTeamPlayersTab({required this.teamId});

  final String teamId;

  @override
  State<_HomeTeamPlayersTab> createState() => _HomeTeamPlayersTabState();
}

class _HomeTeamPlayersTabState extends State<_HomeTeamPlayersTab>
    with AutomaticKeepAliveClientMixin<_HomeTeamPlayersTab> {
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();
  bool _isLoading = true;
  bool _isRepairingCachedData = false;
  String? _errorMessage;
  HupuHomeTeamPlayerData? _playerData;
  bool _isSyncingHorizontalScroll = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _headerScrollController.addListener(_syncHeaderToBody);
    _bodyScrollController.addListener(_syncBodyToHeader);
    unawaited(_loadInitial());
  }

  @override
  void didUpdateWidget(covariant _HomeTeamPlayersTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teamId != widget.teamId) {
      unawaited(_loadInitial());
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    unawaited(_loadInitial());
  }

  @override
  void dispose() {
    _headerScrollController
      ..removeListener(_syncHeaderToBody)
      ..dispose();
    _bodyScrollController
      ..removeListener(_syncBodyToHeader)
      ..dispose();
    super.dispose();
  }

  void _syncHeaderToBody() {
    if (_isSyncingHorizontalScroll || !_bodyScrollController.hasClients) {
      return;
    }
    _isSyncingHorizontalScroll = true;
    _bodyScrollController.jumpTo(
      _headerScrollController.offset.clamp(
        _bodyScrollController.position.minScrollExtent,
        _bodyScrollController.position.maxScrollExtent,
      ),
    );
    _isSyncingHorizontalScroll = false;
  }

  void _syncBodyToHeader() {
    if (_isSyncingHorizontalScroll || !_headerScrollController.hasClients) {
      return;
    }
    _isSyncingHorizontalScroll = true;
    _headerScrollController.jumpTo(
      _bodyScrollController.offset.clamp(
        _headerScrollController.position.minScrollExtent,
        _headerScrollController.position.maxScrollExtent,
      ),
    );
    _isSyncingHorizontalScroll = false;
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await getHupuHomeTeamPlayerData(teamId: widget.teamId);
      if (!mounted) {
        return;
      }
      setState(() {
        _playerData = response;
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

  Future<void> _onRefresh() async {
    await _loadInitial();
  }

  Widget _buildRefreshIndicator(
    BuildContext context,
    LinkedTabRefreshState state,
    double progress,
  ) {
    final isArmed = state == LinkedTabRefreshState.armed ||
        state == LinkedTabRefreshState.refreshing;
    final isRefreshing = state == LinkedTabRefreshState.refreshing ||
        state == LinkedTabRefreshState.complete;
    return HupuRefreshIndicator(
      progress: progress,
      isArmed: isArmed,
      isRefreshing: isRefreshing,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 13));
    }

    final playerData = _playerData;

    if (_errorMessage != null &&
        (playerData == null || playerData.players.isEmpty)) {
      return HupuStatusView(
        message: '球员加载失败',
        detail: _errorMessage,
        onRetry: _loadInitial,
      );
    }

    if (playerData == null || playerData.players.isEmpty) {
      return const Center(
        child: Text(
          '暂无球员数据',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 14,
          ),
        ),
      );
    }

    if (_shouldRepairCachedPlayerData(playerData)) {
      _isRepairingCachedData = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await _loadInitial();
        } finally {
          _isRepairingCachedData = false;
        }
      });
    }

    return LinkedTabPageRefresh(
      onRefresh: _onRefresh,
      indicatorBuilder: _buildRefreshIndicator,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          if (playerData.staff.isNotEmpty)
            SliverToBoxAdapter(
              child: _HomeTeamStaffSection(staff: playerData.staff),
            ),
          SliverToBoxAdapter(
            child: _HomeTeamPlayersStatsTable(
              players: playerData.players,
              columns: playerData.statColumns,
              headerScrollController: _headerScrollController,
              bodyScrollController: _bodyScrollController,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldRepairCachedPlayerData(HupuHomeTeamPlayerData playerData) {
    if (_isLoading || _isRepairingCachedData) {
      return false;
    }
    if (playerData.players.isEmpty || playerData.statColumns.isEmpty) {
      return false;
    }
    final firstColumnKey = playerData.statColumns.first.key;
    final hasAnyStatValue = playerData.players.any(
      (player) => player.statValue(firstColumnKey) != '--',
    );
    return !hasAnyStatValue;
  }
}

class _HomeTeamStaffSection extends StatelessWidget {
  const _HomeTeamStaffSection({required this.staff});

  final List<HupuHomeTeamStaffMember> staff;

  @override
  Widget build(BuildContext context) {
    final coach = staff.first;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F1F4), width: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '制服组',
            style: TextStyle(
              color: Color(0xFF7E8796),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomNetworkImage(
                  coach.photo,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  skeletonBorderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF202127),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coach.role,
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeTeamPlayersStatsTable extends StatelessWidget {
  const _HomeTeamPlayersStatsTable({
    required this.players,
    required this.columns,
    required this.headerScrollController,
    required this.bodyScrollController,
  });

  final List<HupuHomeTeamPlayer> players;
  final List<HupuHomeTeamPlayerStatColumn> columns;
  final ScrollController headerScrollController;
  final ScrollController bodyScrollController;

  static const double leftColumnWidth = 164;
  static const double dataColumnWidth = 72;
  static const double headerHeight = 44;
  static const double rowHeight = 72;

  @override
  Widget build(BuildContext context) {
    final tableWidth = columns.length * dataColumnWidth;
    return Container(
      color: CupertinoColors.white,
      child: Column(
        children: [
          Row(
            children: [
              const _TableHeaderCell(
                title: '球员',
                width: leftColumnWidth,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 14),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: headerScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: tableWidth,
                    child: Row(
                      children: columns
                          .map(
                            (column) => _TableHeaderCell(
                              title: column.label,
                              width: dataColumnWidth,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: leftColumnWidth,
                child: Column(
                  children: players
                      .map(
                        (player) => _FixedPlayerCell(
                          player: player,
                          height: rowHeight,
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: bodyScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: players
                          .map(
                            (player) => _ScrollableStatsRow(
                              player: player,
                              columns: columns,
                              columnWidth: dataColumnWidth,
                              height: rowHeight,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FixedPlayerCell extends StatelessWidget {
  const _FixedPlayerCell({
    required this.player,
    required this.height,
  });

  final HupuHomeTeamPlayer player;
  final double height;

  @override
  Widget build(BuildContext context) {
    final numberText =
        player.number.trim().isEmpty ? '--' : player.number.trim();
    final positionText =
        player.position.trim().isEmpty ? '未知位置' : player.position.trim();
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE8EBF0), width: 0.7),
          bottom: BorderSide(color: Color(0xFFF0F1F4), width: 0.7),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CustomNetworkImage(
              player.avatar,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              skeletonBorderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        player.playerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF202127),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (player.isInjured)
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91B2A),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$numberText号·$positionText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
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

class _ScrollableStatsRow extends StatelessWidget {
  const _ScrollableStatsRow({
    required this.player,
    required this.columns,
    required this.columnWidth,
    required this.height,
  });

  final HupuHomeTeamPlayer player;
  final List<HupuHomeTeamPlayerStatColumn> columns;
  final double columnWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F1F4), width: 0.7),
        ),
      ),
      child: Row(
        children: columns
            .map(
              (column) => Container(
                width: columnWidth,
                height: height,
                alignment: Alignment.center,
                child: Text(
                  player.statValue(column.key),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF202127),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  const _TableHeaderCell({
    required this.title,
    required this.width,
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
  });

  final String title;
  final double width;
  final Alignment alignment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: _HomeTeamPlayersStatsTable.headerHeight,
      alignment: alignment,
      padding: padding,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6F8),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8EBF0), width: 0.7),
        ),
      ),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF202127),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _dateOffset(String day, int deltaDays) {
  if (day.length < 10) {
    return '';
  }
  final value = DateTime.tryParse('${day.substring(0, 10)} 00:00:00');
  if (value == null) {
    return '';
  }
  final target = value.add(Duration(days: deltaDays));
  final month = target.month.toString().padLeft(2, '0');
  final date = target.day.toString().padLeft(2, '0');
  return '${target.year}-$month-$date';
}

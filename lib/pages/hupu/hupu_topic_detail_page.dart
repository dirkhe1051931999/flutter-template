import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/app_tab/app_tab_types.dart';
import 'package:oolaf_flutted/components/app_tab/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_user_detail_helper.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_load_more_footer.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_status_view.dart';

const double _topicHeaderExpandedHeight = 272;
const double _topicHeaderCollapsedHeight = 112;

class HupuTopicDetailPage extends StatefulWidget {
  const HupuTopicDetailPage({
    required this.topicId,
    this.initialTitle = '',
    super.key,
  });

  final int topicId;
  final String initialTitle;

  @override
  State<HupuTopicDetailPage> createState() => _HupuTopicDetailPageState();
}

class _HupuTopicDetailPageState extends State<HupuTopicDetailPage> {
  HupuTopicDetailResponse? _detailResponse;
  HupuTopicAdminResponse? _adminResponse;
  bool _isLoading = true;
  String? _errorMessage;
  int _activeTabIndex = 0;

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
      final responses = await Future.wait<dynamic>(<Future<dynamic>>[
        getHupuTopicDetail(topicId: widget.topicId),
        getHupuTopicAdmins(topicId: widget.topicId),
      ]);
      if (!mounted) {
        return;
      }

      final detail = responses[0] as HupuTopicDetailResponse;
      final admin = responses[1] as HupuTopicAdminResponse;
      final initialIndex = _resolveInitialTabIndex(detail);
      setState(() {
        _detailResponse = detail;
        _adminResponse = admin;
        _activeTabIndex = initialIndex;
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

  int _resolveInitialTabIndex(HupuTopicDetailResponse response) {
    if (response.tabs.isEmpty) {
      return 0;
    }
    return 0;
  }

  Future<void> _openThread(HupuTopicThreadItem item) async {
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuPostDetailPage(
          tid: item.tid,
          topicId: widget.topicId,
          initialTitle: item.title,
        ),
      ),
    );
  }

  Future<void> _openUser(HupuTopicThreadItem item) {
    return openHupuUserDetail(
      context,
      puid: item.puid,
      initialNickname: item.userName,
      initialAvatar: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        backgroundColor: Color(0xFFF5F6FA),
        child: Center(
          child: CupertinoActivityIndicator(radius: 14),
        ),
      );
    }

    if (_detailResponse == null) {
      return CupertinoPageScaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        child: SafeArea(
          child: HupuStatusView(
            message: '专区加载失败',
            detail: _errorMessage,
            onRetry: _loadInitial,
          ),
        ),
      );
    }

    final detailResponse = _detailResponse!;
    final topic = detailResponse.topic;
    final tabs = _buildTabItems(detailResponse);
    final headerTitle =
        topic.name.isNotEmpty ? topic.name : widget.initialTitle.trim();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      child: SafeArea(
        bottom: false,
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(
                pinned: true,
                delegate: _HupuTopicHeaderDelegate(
                  minExtentValue: _topicHeaderCollapsedHeight,
                  maxExtentValue: _topicHeaderExpandedHeight,
                  builder: (context, shrinkOffset, overlapsContent) {
                    final progress = (shrinkOffset /
                            (_topicHeaderExpandedHeight -
                                _topicHeaderCollapsedHeight))
                        .clamp(0.0, 1.0);
                    return _HupuTopicHeader(
                      topic: topic,
                      adminResponse: _adminResponse,
                      resources: detailResponse.resources,
                      title: headerTitle,
                      progress: progress,
                      onBack: () => Navigator.of(context).maybePop(),
                    );
                  },
                ),
              ),
            ];
          },
          body: Transform.translate(
            offset: const Offset(0, -18),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7FA),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildTabHeader(tabs),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: AppTabs(
                        items: tabs,
                        activeKey: _activeTabIndex,
                        onChange: (index) {
                          setState(() {
                            _activeTabIndex = index;
                          });
                        },
                        type: AppTabsType.line,
                        showHeader: false,
                        backgroundColor: const Color(0x00000000),
                        color: const Color(0xFFE31B23),
                        titleActiveColor: const Color(0xFF202127),
                        titleInactiveColor: const Color(0xFF8E8E93),
                        swipeable: true,
                        animated: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabHeader(List<AppTabItemData> tabs) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AppTabs(
        items: List<AppTabItemData>.generate(tabs.length, (index) {
          return AppTabItemData(title: tabs[index].title, child: const SizedBox());
        }),
        activeKey: _activeTabIndex,
        onChange: (index) {
          setState(() {
            _activeTabIndex = index;
          });
        },
        type: AppTabsType.line,
        backgroundColor: const Color(0x00000000),
        color: const Color(0xFFE31B23),
        titleActiveColor: const Color(0xFF202127),
        titleInactiveColor: const Color(0xFF8E8E93),
        shrink: true,
        showHeader: true,
        lazyRender: true,
        lineWidth: 24,
        headerHeight: 44,
      ),
    );
  }

  List<AppTabItemData> _buildTabItems(HupuTopicDetailResponse detailResponse) {
    final items = <AppTabItemData>[];
    for (final tab in detailResponse.tabs) {
      items.add(
        AppTabItemData(
          title: tab.name,
          child: _HupuTopicThreadsTab(
            key:
                ValueKey<String>('topic_${widget.topicId}_tab_${tab.tabType}_0'),
            topicId: widget.topicId,
            topicName: detailResponse.topic.name,
            tab: tab,
            onTapThread: _openThread,
            onTapUser: _openUser,
            topThreads: tab.tabType == 0 ? detailResponse.topThreads : const [],
          ),
        ),
      );
    }
    for (final zone in detailResponse.zones) {
      items.add(
        AppTabItemData(
          title: zone.zoneName,
          child: _HupuTopicThreadsTab(
            key: ValueKey<String>(
              'topic_${widget.topicId}_tab_2_zone_${zone.id}',
            ),
            topicId: widget.topicId,
            topicName: zone.zoneName,
            tab: const HupuTopicTab(name: '', tabType: 2, ename: ''),
            zone: zone,
            onTapThread: _openThread,
            onTapUser: _openUser,
          ),
        ),
      );
    }
    return items;
  }
}

class _HupuTopicThreadsTab extends StatefulWidget {
  const _HupuTopicThreadsTab({
    required this.topicId,
    required this.topicName,
    required this.tab,
    required this.onTapThread,
    required this.onTapUser,
    this.zone,
    this.topThreads = const <HupuTopicThreadItem>[],
    super.key,
  });

  final int topicId;
  final String topicName;
  final HupuTopicTab tab;
  final HupuTopicZone? zone;
  final List<HupuTopicThreadItem> topThreads;
  final Future<void> Function(HupuTopicThreadItem item) onTapThread;
  final Future<void> Function(HupuTopicThreadItem item) onTapUser;

  @override
  State<_HupuTopicThreadsTab> createState() => _HupuTopicThreadsTabState();
}

class _HupuTopicThreadsTabState extends State<_HupuTopicThreadsTab>
    with AutomaticKeepAliveClientMixin<_HupuTopicThreadsTab> {
  final List<HupuTopicThreadItem> _items = <HupuTopicThreadItem>[];
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
    unawaited(_loadInitial());
  }

  @override
  void didUpdateWidget(covariant _HupuTopicThreadsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final zoneChanged = oldWidget.zone?.id != widget.zone?.id;
    if (oldWidget.topicId != widget.topicId ||
        oldWidget.tab.tabType != widget.tab.tabType ||
        zoneChanged) {
      unawaited(_loadInitial());
    }
  }

  void _handleScrollMetrics(ScrollMetrics metrics) {
    if (_isInitialLoading || _isLoadingMore || !_hasMore) {
      return;
    }
    if (metrics.extentAfter <= 420) {
      unawaited(_loadMore());
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await getHupuTopicThreads(
        topicId: widget.topicId,
        tabType: _effectiveTabType,
        page: 1,
        stamp: 0,
        width: 518,
        zoneId: widget.zone?.id,
      );
      if (!mounted) {
        return;
      }

      final merged = _mergeItems(
        response.items,
        reset: true,
        prependTopThreads: widget.topThreads,
      );
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
      final response = await getHupuTopicThreads(
        topicId: widget.topicId,
        tabType: _effectiveTabType,
        page: _page + 1,
        stamp: _stamp,
        width: 518,
        zoneId: widget.zone?.id,
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

  int get _effectiveTabType {
    if (widget.zone != null) {
      return 2;
    }
    if (widget.tab.tabType == 0) {
      return 2;
    }
    return widget.tab.tabType;
  }

  List<HupuTopicThreadItem> _mergeItems(
    List<HupuTopicThreadItem> incoming, {
    bool reset = false,
    List<HupuTopicThreadItem> prependTopThreads = const <HupuTopicThreadItem>[],
  }) {
    if (reset) {
      _tidSet.clear();
    }
    final merged = <HupuTopicThreadItem>[];
    if (!reset) {
      merged.addAll(_items);
    }
    if (reset && prependTopThreads.isNotEmpty) {
      for (final item in prependTopThreads) {
        if (item.tid.isEmpty || _tidSet.contains(item.tid)) {
          continue;
        }
        _tidSet.add(item.tid);
        merged.add(item);
      }
    }
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

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth == 0 &&
            notification.metrics.axis == Axis.vertical) {
          _handleScrollMetrics(notification.metrics);
        }
        return false;
      },
      child: CustomScrollView(
        key: PageStorageKey<String>(
          'topic_threads_${widget.topicId}_${widget.zone?.id ?? widget.tab.tabType}',
        ),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
              child: Row(
                children: [
                  Text(
                    widget.zone?.zoneName.isNotEmpty == true
                        ? widget.zone!.zoneName
                        : '全部帖子',
                    style: const TextStyle(
                      color: Color(0xFF7E8796),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const _TopicSortPill(label: '最新回复', isActive: true),
                  const SizedBox(width: 8),
                  const _TopicSortPill(label: '最新发布'),
                ],
              ),
            ),
          ),
          SliverList.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return _HupuTopicThreadTile(
                item: item,
                onTap: () => widget.onTapThread(item),
                onTapUser:
                    item.puid.isEmpty ? null : () => widget.onTapUser(item),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: HupuLoadMoreFooter(
                state: _loadMoreState,
                errorMessage: _errorMessage,
                onRetry: _loadMore,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HupuTopicHeader extends StatelessWidget {
  const _HupuTopicHeader({
    required this.topic,
    required this.adminResponse,
    required this.resources,
    required this.title,
    required this.progress,
    required this.onBack,
  });

  final HupuTopicDetail topic;
  final HupuTopicAdminResponse? adminResponse;
  final List<HupuTopicResource> resources;
  final String title;
  final double progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        _parseHexColor(topic.backgroundColor, fallback: const Color(0xFFE31B23));
    final collapsedTitleOpacity = progress;
    final expandedOpacity = 1 - progress;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor,
                Color.lerp(backgroundColor, const Color(0xFFF7F7FA), 0.55)!,
              ],
            ),
          ),
        ),
        if (resources.isNotEmpty)
          Positioned.fill(
            child: Opacity(
              opacity: 0.26 * expandedOpacity,
              child: CustomNetworkImage(
                resources.first.backImageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF000000).withValues(alpha: 0.12),
                const Color(0xFF000000).withValues(alpha: 0.02),
                const Color(0xFFF7F7FA),
              ],
            ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TopicGlassIconButton(
                      icon: CupertinoIcons.back,
                      onTap: onBack,
                    ),
                    Expanded(
                      child: Opacity(
                        opacity: collapsedTitleOpacity,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
                Expanded(
                  child: ClipRect(
                    child: Opacity(
                      opacity: expandedOpacity,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFFFF)
                                            .withValues(alpha: 0.92),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: CustomNetworkImage(
                                          topic.displayLogo,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          skeletonBorderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${_formatCount(topic.threadCount)}帖子 / ${_formatCount(topic.followedUserCount)}JRs',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFFFCECEC),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (adminResponse?.adminApplicable == true)
                                    const _TopicRecruitLink(),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF)
                                      .withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        topic.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF7C8391),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '简介&版规详情 >',
                                      style: TextStyle(
                                        color: Color(0xFF3C76E1),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE31B23),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '+ 加入专区',
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HupuTopicHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HupuTopicHeaderDelegate({
    required this.minExtentValue,
    required this.maxExtentValue,
    required this.builder,
  });

  final double minExtentValue;
  final double maxExtentValue;
  final Widget Function(BuildContext, double, bool) builder;

  @override
  double get minExtent => minExtentValue;

  @override
  double get maxExtent => maxExtentValue;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context, shrinkOffset, overlapsContent);
  }

  @override
  bool shouldRebuild(covariant _HupuTopicHeaderDelegate oldDelegate) {
    return minExtentValue != oldDelegate.minExtentValue ||
        maxExtentValue != oldDelegate.maxExtentValue;
  }
}

class _HupuTopicThreadTile extends StatelessWidget {
  const _HupuTopicThreadTile({
    required this.item,
    required this.onTap,
    this.onTapUser,
  });

  final HupuTopicThreadItem item;
  final VoidCallback onTap;
  final VoidCallback? onTapUser;

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl.trim().isNotEmpty;
    final badge = item.primaryBadge;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
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
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTapUser,
                    child: Text(
                      item.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8992A3),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 17,
                      height: 1.42,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.statsText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF9AA1AE),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (badge != null)
                        _ThreadBadge(
                          label: badge.name,
                          colorHex: badge.colorHex,
                        )
                      else
                        Text(
                          item.timeText,
                          style: const TextStyle(
                            color: Color(0xFFC0C3CB),
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomNetworkImage(
                  item.imageUrl,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  skeletonBorderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThreadBadge extends StatelessWidget {
  const _ThreadBadge({
    required this.label,
    required this.colorHex,
  });

  final String label;
  final String colorHex;

  @override
  Widget build(BuildContext context) {
    final color = _parseHexColor(colorHex, fallback: const Color(0xFFE31B23));
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TopicSortPill extends StatelessWidget {
  const _TopicSortPill({
    required this.label,
    this.isActive = false,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFFFFF) : const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE9EBF0)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? const Color(0xFF202127) : const Color(0xFF6E7480),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TopicRecruitLink extends StatelessWidget {
  const _TopicRecruitLink();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          CupertinoIcons.person_2,
          color: Color(0xFFFFFFFF),
          size: 16,
        ),
        SizedBox(width: 4),
        Text(
          '招募版主 >',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TopicGlassIconButton extends StatelessWidget {
  const _TopicGlassIconButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.22),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: const Color(0xFFFFFFFF),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

String _formatCount(int value) {
  if (value >= 100000000) {
    final number = value / 100000000;
    return '${number.toStringAsFixed(number >= 10 ? 0 : 1)}亿';
  }
  if (value >= 10000) {
    final number = value / 10000;
    return '${number.toStringAsFixed(number >= 10 ? 0 : 1)}万';
  }
  return '$value';
}

Color _parseHexColor(String raw, {required Color fallback}) {
  final value = raw.trim().replaceFirst('#', '');
  if (value.isEmpty) {
    return fallback;
  }
  final normalized = value.length == 6 ? 'FF$value' : value;
  final colorValue = int.tryParse(normalized, radix: 16);
  if (colorValue == null) {
    return fallback;
  }
  return Color(colorValue);
}

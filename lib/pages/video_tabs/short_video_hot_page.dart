import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:oolaf_flutted/api/short_video/hot_tab.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_article_detail_page.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_hot_topic_detail_page.dart';
import 'package:oolaf_flutted/pages/video_tabs/watch_history_play_page.dart';
import 'package:oolaf_flutted/utils/short_video_article_history_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_watch_history_persistence.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class ShortVideoHotPage extends StatefulWidget {
  const ShortVideoHotPage({super.key});

  @override
  State<ShortVideoHotPage> createState() => _ShortVideoHotPageState();
}

class _ShortVideoHotPageState extends State<ShortVideoHotPage> {
  HotTabFeedType _activeTab = HotTabFeedType.hotspot;
  bool _isHeaderCollapsed = false;

  void _updateTab(HotTabFeedType nextTab) {
    if (_activeTab == nextTab) {
      return;
    }
    setState(() {
      _activeTab = nextTab;
      _isHeaderCollapsed = false;
    });
  }

  void _handleScrollOffsetChanged(double offset) {
    final shouldCollapse = offset > 24;
    if (_isHeaderCollapsed == shouldCollapse) {
      return;
    }
    setState(() {
      _isHeaderCollapsed = shouldCollapse;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isHotspot = _activeTab == HotTabFeedType.hotspot;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _HotPageHeader(
              activeTab: _activeTab,
              collapsed: _isHeaderCollapsed,
              onTabChanged: _updateTab,
            ),
            Expanded(
              child: IndexedStack(
                index: isHotspot ? 0 : 1,
                children: [
                  _HotTabFeedList(
                    key: const PageStorageKey<String>('hotspot_feed_list'),
                    type: HotTabFeedType.hotspot,
                    onScrollOffsetChanged: _handleScrollOffsetChanged,
                  ),
                  _HotTabFeedList(
                    key: const PageStorageKey<String>('must_see_feed_list'),
                    type: HotTabFeedType.mustSee,
                    onScrollOffsetChanged: _handleScrollOffsetChanged,
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

class _HotPageHeader extends StatelessWidget {
  const _HotPageHeader({
    required this.activeTab,
    required this.collapsed,
    required this.onTabChanged,
  });

  final HotTabFeedType activeTab;
  final bool collapsed;
  final ValueChanged<HotTabFeedType> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: EdgeInsets.only(bottom: collapsed ? 8 : 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF5A4B),
            Color(0xFFFF433B),
          ],
        ),
      ),
      child: Column(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            opacity: collapsed ? 0 : 1,
            child: ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                heightFactor: collapsed ? 0 : 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '凤凰热榜',
                        style: TextStyle(
                          fontSize: 34,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          color: CupertinoColors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC589),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          '实时更新，一榜扫尽全网热点',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB6371F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(56, collapsed ? 4 : 0, 56, 0),
            child: Row(
              children: [
                Expanded(
                  child: _HeaderTabButton(
                    label: '热点',
                    selected: activeTab == HotTabFeedType.hotspot,
                    onTap: () => onTabChanged(HotTabFeedType.hotspot),
                  ),
                ),
                Expanded(
                  child: _HeaderTabButton(
                    label: '必刷',
                    selected: activeTab == HotTabFeedType.mustSee,
                    onTap: () => onTabChanged(HotTabFeedType.mustSee),
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

class _HeaderTabButton extends StatelessWidget {
  const _HeaderTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayLabel = selected ? '↯$label↯' : label;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            displayLabel,
            style: TextStyle(
              fontSize: selected ? 19 : 16,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _HotTabFeedList extends StatefulWidget {
  const _HotTabFeedList({
    super.key,
    required this.type,
    required this.onScrollOffsetChanged,
  });

  final HotTabFeedType type;
  final ValueChanged<double> onScrollOffsetChanged;

  @override
  State<_HotTabFeedList> createState() => _HotTabFeedListState();
}

class _HotTabFeedListState extends State<_HotTabFeedList>
    with AutomaticKeepAliveClientMixin {
  static const String _hotspotSt = '17796904577820';
  static const String _hotspotSn = 'fa76b12bab87ceb060232746cc713f08';
  static const String _mustSeeSt = '17796905554779';
  static const String _mustSeeSn = '44ba44d2d777e5bf1dceb22c4b74f5a0';

  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isPaging = false;
  bool _hasMore = true;
  int _nextPage = 1;
  List<HotTabFeedItem> _items = const <HotTabFeedItem>[];

  @override
  bool get wantKeepAlive => true;

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

  HotTabRequest _buildRequest(int page) {
    final isHotspot = widget.type == HotTabFeedType.hotspot;
    return HotTabRequest(
      type: widget.type,
      page: page,
      st: isHotspot ? _hotspotSt : _mustSeeSt,
      sn: isHotspot ? _hotspotSn : _mustSeeSn,
    );
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _isPaging = false;
      _hasMore = true;
      _nextPage = 1;
      _items = const <HotTabFeedItem>[];
    });

    final result = await getHotTabFeedPage(
      request: _buildRequest(1),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _items = result.items;
      _nextPage = 2;
      _hasMore = result.hasMore;
      _isLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_isPaging || !_hasMore) {
      return;
    }

    setState(() {
      _isPaging = true;
    });

    final result = await getHotTabFeedPage(
      request: _buildRequest(_nextPage),
    );

    if (!mounted) {
      return;
    }

    final existingIds = _items.map((item) => item.id).toSet();
    final mergedItems = <HotTabFeedItem>[..._items];
    for (final item in result.items) {
      if (existingIds.add(item.id)) {
        mergedItems.add(item);
      }
    }

    setState(() {
      _items = mergedItems;
      _nextPage += 1;
      _hasMore = result.hasMore;
      _isPaging = false;
    });
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    widget.onScrollOffsetChanged(_scrollController.offset);
    if (_scrollController.position.extentAfter < 320) {
      _loadMore();
    }
  }

  Future<void> _copyLink(HotTabFeedItem item) async {
    final text = item.shareUrl.isNotEmpty
        ? item.shareUrl
        : (item.detailUrl.isNotEmpty ? item.detailUrl : item.title);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('已复制'),
          content: const Text('链接已复制到剪贴板。'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openTopicDetail(HotTabFeedItem item) async {
    if (item.eventName.isEmpty) {
      return;
    }
    await Navigator.of(context, rootNavigator: true).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => ShortVideoHotTopicDetailPage(eventName: item.eventName),
      ),
    );
  }

  Future<void> _openDocDetail(HotTabFeedItem item) async {
    if (item.detailUrl.isEmpty) {
      return;
    }
    final detail = await getShortVideoNewsDocDetail(detailUrl: item.detailUrl);
    if (!mounted) {
      return;
    }
    if (detail == null) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) {
          return CupertinoAlertDialog(
            title: const Text('加载失败'),
            content: const Text('文章详情暂时不可用，请稍后重试。'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('知道了'),
              ),
            ],
          );
        },
      );
      return;
    }

    await ShortVideoArticleHistoryPersistence.record(
      ShortVideoArticleHistoryEntry(
        docId: item.id,
        title: item.title,
        source: item.source,
        updateTime: item.updateTime,
        coverUrl: item.coverUrl,
        detailUrl: item.detailUrl,
        viewedAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (!mounted) {
      return;
    }

    await openShortVideoArticleDetailPage(
      context,
      detail: detail,
      coverUrl: item.coverUrl,
      detailUrl: item.detailUrl,
    );
  }

  Future<void> _openMustSeePlaylist(HotTabFeedItem item) async {
    final entries = _items
        .where((entry) => entry.isVideo && entry.videoUrl.isNotEmpty)
        .map(
          (entry) => ShortVideoWatchHistoryEntry(
            videoId: entry.id,
            title: entry.title,
            updateTime: entry.updateTime,
            coverUrl: entry.coverUrl,
            videoUrl: entry.videoUrl,
            source: entry.source,
            commentsUrl: entry.commentsUrl,
            commentsCount: entry.commentsCount,
            watchedAtMillis: DateTime.now().millisecondsSinceEpoch,
          ),
        )
        .toList(growable: false);
    if (entries.isEmpty) {
      return;
    }
    final initialIndex = entries.indexWhere((entry) => entry.videoId == item.id);
    if (initialIndex < 0) {
      return;
    }

    await ShortVideoWatchHistoryPersistence.record(entries[initialIndex]);
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (context) {
          return ShortVideoWatchHistoryPlayPage(
            entries: entries,
            initialIndex: initialIndex,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    if (_items.isEmpty) {
      return CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: _loadInitial),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                '暂无内容',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return wrapWithDesktopFriendlyScrollBehavior(
      CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
        CupertinoSliverRefreshControl(onRefresh: _loadInitial),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          sliver: SliverList.separated(
            itemBuilder: (context, index) {
              final item = _items[index];
              if (widget.type == HotTabFeedType.hotspot) {
                return _HotspotTopicCard(
                  item: item,
                  onTapTopic: () => _openTopicDetail(item),
                  onTapNews: () => _openDocDetail(item),
                  onCopyLink: () => _copyLink(item),
                );
              }
              return _MustSeeVideoCard(
                item: item,
                onTap: () {
                  if (item.isVideo) {
                    _openMustSeePlaylist(item);
                    return;
                  }
                  _openDocDetail(item);
                },
                onCopyLink: () => _copyLink(item),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                height: widget.type == HotTabFeedType.hotspot ? 8 : 0.5,
              );
            },
            itemCount: _items.length,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
            child: Center(
              child: _isPaging
                  ? const CupertinoActivityIndicator()
                  : Text(
                      _hasMore ? '上拉加载更多' : '已经到底了',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _HotspotTopicCard extends StatelessWidget {
  const _HotspotTopicCard({
    required this.item,
    required this.onTapTopic,
    required this.onTapNews,
    required this.onCopyLink,
  });

  final HotTabFeedItem item;
  final VoidCallback onTapTopic;
  final VoidCallback onTapNews;
  final VoidCallback onCopyLink;

  @override
  Widget build(BuildContext context) {
    final rankColor = switch (item.rankLabel) {
      '01' => const Color(0xFFFF5A36),
      '02' => const Color(0xFFFF8A00),
      '03' => const Color(0xFFFFB21C),
      _ => const Color(0xFF6F7782),
    };

    final topicTitle = item.hotTag.isNotEmpty ? item.hotTag : '# ${item.title}';

    return Container(
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'NO.${item.rankLabel}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: rankColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.hotLabel.isNotEmpty ? item.hotLabel : '热度上升',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onTapTopic,
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    topicTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202124),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const AppAssetIcon(
                  assetName: 'chevron-forward',
                  size: 16,
                  color: Color(0xFFB4B7BD),
                  fallbackIcon: CupertinoIcons.chevron_right,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTapNews,
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FeedCover(
                  imageUrl: item.coverUrl,
                  width: 108,
                  height: 76,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 76,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF202124),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.source}  ${item.commentsCount.isNotEmpty ? '${item.commentsCount}评' : item.updateTime}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9B9EA4),
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(24, 24),
                              onPressed: onCopyLink,
                              child: const AppAssetIcon(
                                assetName: 'share-social',
                                size: 16,
                                color: Color(0xFFB4B7BD),
                                fallbackIcon: CupertinoIcons.share,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _MustSeeVideoCard extends StatelessWidget {
  const _MustSeeVideoCard({
    required this.item,
    required this.onTap,
    required this.onCopyLink,
  });

  final HotTabFeedItem item;
  final VoidCallback onTap;
  final VoidCallback onCopyLink;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8B2D),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '必刷',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF8B2D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FeedCover(
                  imageUrl: item.coverUrl,
                  width: 108,
                  height: 76,
                  videoMeta: _buildVideoMeta(item),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 76,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.intro.isNotEmpty ? item.intro : item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C2F36),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.source}  ${item.commentsCount.isNotEmpty ? '${item.commentsCount}评' : item.updateTime}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9B9EA4),
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(24, 24),
                              onPressed: onCopyLink,
                              child: const AppAssetIcon(
                                assetName: 'share-social',
                                size: 16,
                                color: Color(0xFFB4B7BD),
                                fallbackIcon: CupertinoIcons.share,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildVideoMeta(HotTabFeedItem item) {
    if (item.durationSeconds > 0) {
      return _formatDuration(item.durationSeconds);
    }
    if (item.playCountText.isNotEmpty) {
      return item.playCountText;
    }
    return item.isVideo ? '视频' : '';
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final hours = minutes ~/ 60;
    final remainMinutes = minutes % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${remainMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _FeedCover extends StatelessWidget {
  const _FeedCover({
    required this.imageUrl,
    required this.width,
    required this.height,
    this.videoMeta,
  });

  final String imageUrl;
  final double width;
  final double height;
  final String? videoMeta;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: const Color(0xFFF0F2F5),
              child: imageUrl.isEmpty
                  ? const Center(
                      child: AppAssetIcon(
                        assetName: 'image',
                        size: 24,
                        color: Color(0xFFB8BDC6),
                        fallbackIcon: CupertinoIcons.photo,
                      ),
                    )
                  : CustomNetworkImage(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
            ),
            if (videoMeta != null && videoMeta!.isNotEmpty)
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xAA000000),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    videoMeta!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

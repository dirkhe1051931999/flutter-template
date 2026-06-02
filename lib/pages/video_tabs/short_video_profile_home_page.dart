import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_article_detail_page.dart';
import 'package:oolaf_flutted/pages/video_tabs/watch_history_play_page.dart';
import 'package:oolaf_flutted/utils/short_video_article_history_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_watch_history_persistence.dart';

class ShortVideoProfileHomePage extends StatefulWidget {
  const ShortVideoProfileHomePage({
    super.key,
    required this.initialSummary,
  });

  final ShortVideoProfileSummary initialSummary;

  @override
  State<ShortVideoProfileHomePage> createState() =>
      _ShortVideoProfileHomePageState();
}

class _ShortVideoProfileHomePageState extends State<ShortVideoProfileHomePage> {
  ShortVideoProfileSummary? _summary;
  final List<ShortVideoProfileFeedItem> _items = <ShortVideoProfileFeedItem>[];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  int _totalPage = 1;
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;

  bool get _hasMore => _currentPage < _totalPage;

  @override
  void initState() {
    super.initState();
    _summary = widget.initialSummary;
    _scrollController.addListener(_handleScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || _isInitialLoading) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      _loadMore();
    }
  }

  Future<void> _loadFirstPage() async {
    if (_isInitialLoading) {
      return;
    }
    setState(() {
      _isInitialLoading = true;
    });
    try {
      final result = await getShortVideoProfileFeedPage(
        guid: widget.initialSummary.guid,
        page: 1,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = result.userSummary ?? _summary;
        _items
          ..clear()
          ..addAll(result.items);
        _currentPage = result.currentPage;
        _totalPage = result.totalPage;
      });
    } catch (_) {
      if (mounted) {
        AppToast.showText('加载个人主页失败');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) {
      return;
    }
    setState(() {
      _isLoadingMore = true;
    });
    final nextPage = _currentPage + 1;
    try {
      final result = await getShortVideoProfileFeedPage(
        guid: widget.initialSummary.guid,
        page: nextPage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = result.userSummary ?? _summary;
        if (result.items.isNotEmpty) {
          _items.addAll(result.items);
        }
        _currentPage = result.currentPage;
        _totalPage = result.totalPage;
      });
    } catch (_) {
      if (mounted) {
        AppToast.showText('加载更多失败');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _openFeedTarget(ShortVideoProfileFeedItem item) async {
    final preview = item.articlePreview;
    if (preview.isVideo && preview.videoUrl.trim().isNotEmpty) {
      final entry = ShortVideoWatchHistoryEntry(
        videoId: preview.id,
        title: preview.title,
        updateTime: preview.updateTime,
        coverUrl: preview.thumbnail,
        videoUrl: preview.videoUrl,
        watchedAtMillis: DateTime.now().millisecondsSinceEpoch,
        source: preview.source,
        type: preview.type,
        commentsUrl: preview.commentsUrl.isEmpty ? null : preview.commentsUrl,
        commentsCount: preview.commentsCount,
      );
      await ShortVideoWatchHistoryPersistence.record(entry);
      if (!mounted) {
        return;
      }
      await openShortVideoSinglePlayPage(
        context,
        entry: entry,
      );
      return;
    }

    if (!preview.isDoc || preview.detailUrl.trim().isEmpty) {
      AppToast.showText('当前内容暂时无法打开');
      return;
    }

    final detail = await getShortVideoNewsDocDetail(
      detailUrl: preview.detailUrl,
    );
    if (detail == null) {
      if (mounted) {
        AppToast.showText('图文详情暂时不可用');
      }
      return;
    }
    await ShortVideoArticleHistoryPersistence.record(
      ShortVideoArticleHistoryEntry(
        docId: preview.id,
        title: preview.title,
        source: preview.source,
        updateTime: preview.updateTime,
        coverUrl: preview.thumbnail,
        detailUrl: preview.detailUrl,
        viewedAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (!mounted) {
      return;
    }
    await openShortVideoArticleDetailPage(
      context,
      detail: detail,
      coverUrl: preview.thumbnail,
      detailUrl: preview.detailUrl,
    );
  }

  Widget _buildBadge(ShortVideoProfileBadge badge) {
    if (badge.isPrimary) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3C36A),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          badge.label,
          style: const TextStyle(
            color: Color(0xFF8A5600),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.star_fill,
            size: 14,
            color: Color(0xFFF0A51A),
          ),
          const SizedBox(width: 4),
          Text(
            badge.label,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ShortVideoProfileSummary summary) {
    return Container(
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: CustomNetworkImage(
                  summary.avatarUrl,
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.nickname,
                      style: const TextStyle(
                        color: Color(0xFF1C1C1E),
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (summary.badges.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: summary.badges.map(_buildBadge).toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () {
                  AppToast.showText('编辑资料功能开发中');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF2B2B2B)),
                  ),
                  child: const Text(
                    '编辑资料',
                    style: TextStyle(
                      color: Color(0xFF2B2B2B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '简介：${summary.introduction.isNotEmpty ? summary.introduction : '暂无简介'}',
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                '关注 ${summary.followCount}',
                style: const TextStyle(
                  color: Color(0xFF5A5A5F),
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                '粉丝 ${summary.fansCount}',
                style: const TextStyle(
                  color: Color(0xFF5A5A5F),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(ShortVideoProfileFeedItem item) {
    return Container(
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: CustomNetworkImage(
                  (_summary?.avatarUrl.isNotEmpty == true
                          ? _summary!.avatarUrl
                          : item.userAvatarUrl),
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.userName,
                      style: const TextStyle(
                        color: Color(0xFF2B2B2B),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.publishTimeText,
                      style: const TextStyle(
                        color: Color(0xFF9A9AA1),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    '${item.likeCount}',
                    style: const TextStyle(
                      color: Color(0xFF6C6C70),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    CupertinoIcons.heart,
                    size: 20,
                    color: Color(0xFF9A9AA1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.content,
            style: const TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _openFeedTarget(item);
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CustomNetworkImage(
                      item.articlePreview.thumbnail,
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.articlePreview.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2B2B2B),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

  @override
  Widget build(BuildContext context) {
    final summary = _summary ?? widget.initialSummary;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: '我',
        middle: Text('个人主页'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.envelope_open),
            SizedBox(width: 16),
            Icon(CupertinoIcons.ellipsis),
          ],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: _loadFirstPage,
            ),
            SliverToBoxAdapter(
              child: _buildHeader(summary),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                color: CupertinoColors.white,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '评论',
                      style: TextStyle(
                        color: Color(0xFF1C1C1E),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 22,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4D4F),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (_isInitialLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CupertinoActivityIndicator()),
              )
            else if (_items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    '暂无评论内容',
                    style: TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 15,
                    ),
                  ),
                ),
              )
            else
              SliverList.separated(
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _buildCommentCard(item);
                },
                separatorBuilder: (_, __) => Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 16),
                  color: const Color(0xFFF0F0F0),
                ),
                itemCount: _items.length,
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: _isLoadingMore
                      ? const CupertinoActivityIndicator()
                      : Text(
                          _hasMore ? '上拉加载更多' : '没有更多了',
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 13,
                          ),
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

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/short_video/comment.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';

Future<void> showRealShortVideoCommentSheet(
  BuildContext context, {
  required ShortVideoItem item,
}) async {
  await showAppSheet<void>(
    context: context,
    barrierLabel: '视频评论',
    maxHeightFactor: 0.88,
    backgroundColor: const Color(0xFFF7F7FA),
    builder: (_) {
      return _RealShortVideoCommentSheet(item: item);
    },
  );
}

String formatShortVideoCommentCount(int count) {
  if (count >= 10000) {
    return '1w+';
  }
  return count.toString();
}

class _RealShortVideoCommentSheet extends StatefulWidget {
  const _RealShortVideoCommentSheet({required this.item});

  final ShortVideoItem item;

  @override
  State<_RealShortVideoCommentSheet> createState() =>
      _RealShortVideoCommentSheetState();
}

class _RealShortVideoCommentSheetState
    extends State<_RealShortVideoCommentSheet> {
  static const int _pageSize = 10;
  static const int _childrenPageSize = 4;

  final ScrollController _scrollController = ScrollController();

  ShortVideoCommentSortBy _sortBy = ShortVideoCommentSortBy.hot;
  List<ShortVideoCommentItem> _comments = const <ShortVideoCommentItem>[];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _loadMoreLocked = false;
  bool _hasMore = true;
  int _page = 1;
  int _totalCount = 0;
  String? _loadingChildrenCommentId;

  String get _docUrl {
    return widget.item.type == 'phvideo'
        ? (widget.item.commentsUrl?.trim().isNotEmpty == true
            ? widget.item.commentsUrl!.trim()
            : widget.item.id)
        : '';
  }

  bool get _supportsComment {
    return widget.item.type == 'phvideo' && _docUrl.isNotEmpty;
  }

  String get _titleText {
    if (_totalCount > 0) {
      return '${formatShortVideoCommentCount(_totalCount)}条评论';
    }
    final fallback = int.tryParse(widget.item.commentsCount) ?? 0;
    if (fallback > 0) {
      return '${formatShortVideoCommentCount(fallback)}条评论';
    }
    return '评论';
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
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _loadMoreLocked = true;
      _page = 1;
    });

    final result = await _fetchPage(page: 1);
    if (!mounted) {
      return;
    }

    setState(() {
      _comments = result.comments;
      _totalCount = result.totalCount;
      _hasMore = result.hasMore;
      _isLoading = false;
      _loadMoreLocked = false;
    });
  }

  Future<ShortVideoCommentPageResult> _fetchPage({required int page}) async {
    if (!_supportsComment) {
      return const ShortVideoCommentPageResult(
        comments: <ShortVideoCommentItem>[],
        totalCount: 0,
        page: 1,
        pageSize: _pageSize,
        hasMore: false,
      );
    }

    return getShortVideoComments(
      query: ShortVideoCommentQuery(
        docUrl: _docUrl,
        page: page,
        pageSize: _pageSize,
        sortBy: _sortBy,
      ),
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        _loadMoreLocked ||
        !_hasMore) {
      return;
    }
    if (_scrollController.position.extentAfter > 240) {
      return;
    }
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _loadMoreLocked || !_hasMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _loadMoreLocked = true;
    });

    final nextPage = _page + 1;
    final result = await _fetchPage(page: nextPage);
    if (!mounted) {
      return;
    }

    setState(() {
      _page = nextPage;
      _comments = <ShortVideoCommentItem>[
        ..._comments,
        ...result.comments,
      ];
      _totalCount = result.totalCount > 0 ? result.totalCount : _totalCount;
      _hasMore = result.hasMore && result.comments.isNotEmpty;
      _isLoadingMore = false;
      _loadMoreLocked = false;
    });
  }

  Future<void> _changeSort(ShortVideoCommentSortBy sortBy) async {
    if (_sortBy == sortBy || _isLoading) {
      return;
    }
    setState(() {
      _sortBy = sortBy;
    });
    await _loadInitial();
  }

  Future<void> _loadChildren(ShortVideoCommentItem parent) async {
    if (_loadingChildrenCommentId == parent.commentId) {
      return;
    }

    setState(() {
      _loadingChildrenCommentId = parent.commentId;
    });

    final nextPage = parent.childrenPage + 1;

    final children = await getShortVideoCommentChildren(
      query: ShortVideoCommentChildrenQuery(
        docUrl: parent.docUrl,
        commentId: parent.commentId,
        page: nextPage,
        pageSize: _childrenPageSize,
      ),
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _comments = _comments.map((item) {
        if (item.commentId != parent.commentId) {
          return item;
        }
        final mergedChildren = nextPage <= 1
            ? children
            : <ShortVideoCommentItem>[
                ...item.children,
                ...children.where((child) {
                  return !item.children.any(
                    (existing) => existing.commentId == child.commentId,
                  );
                }),
              ];
        return item.copyWith(
          children: mergedChildren,
          childrenPage: nextPage,
          canLoadMoreChildren: mergedChildren.length < item.replyCount &&
              children.isNotEmpty,
        );
      }).toList(growable: false);
      _loadingChildrenCommentId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Row(
            children: [
              Text(
                _titleText,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              const Spacer(),
              _CommentSortChip(
                label: _sortBy.label,
                onTap: () async {
                  await showCupertinoModalPopup<void>(
                    context: context,
                    builder: (sheetContext) {
                      return CupertinoActionSheet(
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () async {
                              Navigator.of(sheetContext).pop();
                              await _changeSort(ShortVideoCommentSortBy.hot);
                            },
                            child: const Text('按热度'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () async {
                              Navigator.of(sheetContext).pop();
                              await _changeSort(ShortVideoCommentSortBy.latest);
                            },
                            child: const Text('按时间'),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('取消'),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator(radius: 12))
              : !_supportsComment || _comments.isEmpty
                  ? const _CommentEmptyState()
                  : CustomScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        CupertinoSliverRefreshControl(onRefresh: _loadInitial),
                        SliverList.builder(
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            return _CommentListTile(
                              item: comment,
                              isLoadingReplies:
                                  _loadingChildrenCommentId == comment.commentId,
                              onTapLoadMoreReplies: comment.canLoadMoreChildren
                                  ? () => _loadChildren(comment)
                                  : null,
                            );
                          },
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Center(
                              child: _isLoadingMore
                                  ? const CupertinoActivityIndicator(radius: 10)
                                  : Text(
                                      _hasMore ? '继续下拉加载更多' : '没有更多评论了',
                                      style: const TextStyle(
                                        color: Color(0xFF8E8E93),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }
}

class _CommentSortChip extends StatelessWidget {
  const _CommentSortChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5C6270),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const AppAssetIcon(
              assetName: 'chevron-down',
              size: 12,
              color: Color(0xFF5C6270),
              fallbackIcon: CupertinoIcons.chevron_down,
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentEmptyState extends StatelessWidget {
  const _CommentEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            AppAssetIcon(
              assetName: 'chatbubbles',
              size: 42,
              color: Color(0xFFCACDD4),
              fallbackIcon: CupertinoIcons.chat_bubble_2_fill,
            ),
            SizedBox(height: 12),
            Text(
              '暂无评论，来抢沙发吧',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentListTile extends StatelessWidget {
  const _CommentListTile({
    required this.item,
    this.level = 0,
    this.onTapLoadMoreReplies,
    this.isLoadingReplies = false,
  });

  final ShortVideoCommentItem item;
  final int level;
  final VoidCallback? onTapLoadMoreReplies;
  final bool isLoadingReplies;

  @override
  Widget build(BuildContext context) {
    final avatarSize = level == 0 ? 38.0 : 28.0;
    final leftInset = 16.0 + level * 34.0;
    final replyPrefix = item.replyToUserName?.trim().isNotEmpty == true
        ? '回复 @${item.replyToUserName}：'
        : '';
    return Padding(
      padding: EdgeInsets.fromLTRB(leftInset, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CommentAvatar(
                avatarUrl: item.user.avatarUrl,
                size: avatarSize,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.user.name,
                            style: TextStyle(
                              color: level == 0
                                  ? const Color(0xFF717784)
                                  : const Color(0xFF8E8E93),
                              fontSize: level == 0 ? 13 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const AppAssetIcon(
                          assetName: 'heart-outline',
                          size: 16,
                          color: Color(0xFFB9BDC7),
                          fallbackIcon: CupertinoIcons.heart,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatShortVideoCommentCount(item.likeCount),
                          style: const TextStyle(
                            color: Color(0xFFB9BDC7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          if (replyPrefix.isNotEmpty)
                            TextSpan(
                              text: replyPrefix,
                              style: const TextStyle(
                                color: Color(0xFF5C6270),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          TextSpan(
                            text: item.content,
                            style: TextStyle(
                              color: const Color(0xFF141619),
                              fontSize: level == 0 ? 16 : 14,
                              height: 1.35,
                              fontWeight: level == 0
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          item.publishTimeText.isEmpty ? '刚刚' : item.publishTimeText,
                          style: const TextStyle(
                            color: Color(0xFFB0B4BE),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          '回复',
                          style: TextStyle(
                            color: Color(0xFF5C6270),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.children.isNotEmpty) ...[
            const SizedBox(height: 4),
            for (final child in item.children)
              _CommentListTile(
                item: child,
                level: level + 1,
              ),
          ],
          if (item.canLoadMoreChildren && onTapLoadMoreReplies != null)
            Padding(
              padding: EdgeInsets.only(left: avatarSize + 10, top: 6),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onTapLoadMoreReplies,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 1,
                      color: const Color(0xFFD0D4DB),
                    ),
                    const SizedBox(width: 8),
                    if (isLoadingReplies)
                      const CupertinoActivityIndicator(radius: 7)
                    else
                      Text(
                        '查看更多回复 (${formatShortVideoCommentCount(item.replyCount)})',
                        style: const TextStyle(
                          color: Color(0xFF8B92A0),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
}

class _CommentAvatar extends StatelessWidget {
  const _CommentAvatar({
    required this.avatarUrl,
    required this.size,
  });

  final String avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFECEEF3),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl.isEmpty
          ? AppAssetIcon(
              assetName: 'person',
              size: size * 0.55,
              color: const Color(0xFFB7BCC6),
              fallbackIcon: CupertinoIcons.person_fill,
            )
          : CustomNetworkImage(
              avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return AppAssetIcon(
                  assetName: 'person',
                  size: size * 0.55,
                  color: const Color(0xFFB7BCC6),
                  fallbackIcon: CupertinoIcons.person_fill,
                );
              },
            ),
    );
  }
}

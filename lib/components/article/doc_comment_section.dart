import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/short_video/comment.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/components/short_video/real_comment_sheet.dart'
    show formatShortVideoCommentCount;

class DocCommentSection extends StatefulWidget {
  const DocCommentSection({
    super.key,
    required this.docId,
    required this.initialCommentsCount,
    required this.scrollController,
  });

  final String docId;
  final String initialCommentsCount;
  final ScrollController scrollController;

  @override
  State<DocCommentSection> createState() => _DocCommentSectionState();
}

class _DocCommentSectionState extends State<DocCommentSection> {
  static const int _pageSize = 10;
  static const int _childrenPageSize = 4;

  ShortVideoCommentSortBy _sortBy = ShortVideoCommentSortBy.hot;
  List<ShortVideoCommentItem> _comments = const <ShortVideoCommentItem>[];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  int _totalCount = 0;
  String? _loadingChildrenCommentId;

  String get _titleText {
    if (_totalCount > 0) {
      return '${formatShortVideoCommentCount(_totalCount)}条评论';
    }
    final fallback = int.tryParse(widget.initialCommentsCount) ?? 0;
    if (fallback > 0) {
      return '${formatShortVideoCommentCount(fallback)}条评论';
    }
    return '评论';
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
    _loadInitial();
  }

  @override
  void didUpdateWidget(covariant DocCommentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController == widget.scrollController) {
      return;
    }
    oldWidget.scrollController.removeListener(_handleScroll);
    widget.scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _page = 1;
    });

    final result = await getShortVideoComments(
      query: ShortVideoCommentQuery(
        docUrl: widget.docId,
        page: 1,
        pageSize: _pageSize,
        sortBy: _sortBy,
      ),
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _comments = result.comments;
      _totalCount = result.totalCount;
      _hasMore = result.hasMore;
      _isLoading = false;
    });
  }

  void _handleScroll() {
    if (!widget.scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        !_hasMore) {
      return;
    }
    if (widget.scrollController.position.extentAfter > 240) {
      return;
    }
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = _page + 1;
    final result = await getShortVideoComments(
      query: ShortVideoCommentQuery(
        docUrl: widget.docId,
        page: nextPage,
        pageSize: _pageSize,
        sortBy: _sortBy,
      ),
    );
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
    });
  }

  Future<void> _changeSort(ShortVideoCommentSortBy nextSortBy) async {
    if (_sortBy == nextSortBy || _isLoading) {
      return;
    }
    setState(() {
      _sortBy = nextSortBy;
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
          canLoadMoreChildren:
              mergedChildren.length < item.replyCount && children.isNotEmpty,
        );
      }).toList(growable: false);
      _loadingChildrenCommentId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        const Text(
          '评论',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              _titleText,
              style: const TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await showCupertinoModalPopup<void>(
                  context: context,
                  builder: (sheetContext) => CupertinoActionSheet(
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
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _sortBy == ShortVideoCommentSortBy.hot ? '按热度' : '按时间',
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const AppAssetIcon(
                    assetName: 'chevron-down',
                    size: 14,
                    color: Color(0xFF8E8E93),
                    fallbackIcon: CupertinoIcons.chevron_down,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CupertinoActivityIndicator(radius: 12),
            ),
          )
        else if (_comments.isEmpty)
          const _DocCommentEmptyState()
        else
          Column(
            children: [
              for (var index = 0; index < _comments.length; index++) ...[
                if (index > 0) const SizedBox(height: 18),
                _DocCommentTile(
                  item: _comments[index],
                  isLoadingReplies:
                      _loadingChildrenCommentId == _comments[index].commentId,
                  onTapLoadMoreReplies: _comments[index].canLoadMoreChildren
                      ? () => _loadChildren(_comments[index])
                      : null,
                ),
              ],
              if (_hasMore || _isLoadingMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: _isLoadingMore
                        ? const CupertinoActivityIndicator(radius: 10)
                        : const Text(
                            '继续下拉加载更多',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _DocCommentEmptyState extends StatelessWidget {
  const _DocCommentEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          '暂无评论，来抢沙发吧',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DocCommentTile extends StatelessWidget {
  const _DocCommentTile({
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
    final avatarSize = level == 0 ? 40.0 : 30.0;
    final leftInset = level == 0 ? 0.0 : 52.0;
    final replyPrefix = item.replyToUserName?.trim().isNotEmpty == true
        ? '回复 @${item.replyToUserName}：'
        : '';

    return Padding(
      padding: EdgeInsets.only(left: leftInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DocCommentAvatar(
                avatarUrl: item.user.avatarUrl,
                size: avatarSize,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.user.name,
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          formatShortVideoCommentCount(item.likeCount),
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const AppAssetIcon(
                          assetName: 'heart-outline',
                          size: 18,
                          color: Color(0xFF9CA3AF),
                          fallbackIcon: CupertinoIcons.heart,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          if (replyPrefix.isNotEmpty)
                            TextSpan(
                              text: replyPrefix,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                height: 1.55,
                              ),
                            ),
                          TextSpan(
                            text: item.content,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 17,
                              height: 1.55,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          item.publishTimeText.isEmpty ? '刚刚' : item.publishTimeText,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          '回复',
                          style: TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 13,
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
            const SizedBox(height: 12),
            for (final child in item.children)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _DocCommentTile(item: child, level: level + 1),
              ),
          ],
          if (item.canLoadMoreChildren && onTapLoadMoreReplies != null)
            Padding(
              padding: const EdgeInsets.only(left: 52, top: 10),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onTapLoadMoreReplies,
                child: isLoadingReplies
                    ? const CupertinoActivityIndicator(radius: 7)
                    : Text(
                        '查看更多回复 (${formatShortVideoCommentCount(item.replyCount)})',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DocCommentAvatar extends StatelessWidget {
  const _DocCommentAvatar({
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
        color: Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl.isEmpty
          ? AppAssetIcon(
              assetName: 'person',
              size: size * 0.52,
              color: const Color(0xFFB7BCC6),
              fallbackIcon: CupertinoIcons.person_fill,
            )
          : CustomNetworkImage(
              avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return AppAssetIcon(
                  assetName: 'person',
                  size: size * 0.52,
                  color: const Color(0xFFB7BCC6),
                  fallbackIcon: CupertinoIcons.person_fill,
                );
              },
            ),
    );
  }
}

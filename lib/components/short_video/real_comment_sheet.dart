import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/short_video/comment.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';
import 'package:oolaf_flutted/components/comment/comment_list_view.dart';
import 'package:oolaf_flutted/components/comment/comment_panel_scaffold.dart';
import 'package:oolaf_flutted/components/comment/comment_sort_selector.dart';
import 'package:oolaf_flutted/components/comment/comment_thread_controller.dart';
import 'package:oolaf_flutted/components/article/article_comment_input_sheet.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';

Future<void> showRealShortVideoCommentSheet(
  BuildContext context, {
  required ShortVideoItem item,
  bool expanded = false,
}) async {
  await showAppSheet<void>(
    context: context,
    barrierLabel: '视频评论',
    maxHeightFactor: expanded ? 0.92 : 0.72,
    backgroundColor: const Color(0xFFF7F7FA),
    edgeToEdge: true,
    builder: (_) {
      return _RealShortVideoCommentSheet(
        item: item,
        expanded: expanded,
      );
    },
  );
}

String formatShortVideoCommentCount(int count) {
  return formatCommentCount(count);
}

class _RealShortVideoCommentSheet extends StatefulWidget {
  const _RealShortVideoCommentSheet({
    required this.item,
    required this.expanded,
  });

  final ShortVideoItem item;
  final bool expanded;

  @override
  State<_RealShortVideoCommentSheet> createState() =>
      _RealShortVideoCommentSheetState();
}

class _RealShortVideoCommentSheetState
    extends State<_RealShortVideoCommentSheet> {
  final ScrollController _scrollController = ScrollController();
  late final CommentThreadController _controller;
  bool _isCollected = false;
  bool _isLiked = false;

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
    if (_controller.totalCount > 0) {
      return '${formatCommentCount(_controller.totalCount)}条评论';
    }
    final fallback = int.tryParse(widget.item.commentsCount) ?? 0;
    if (fallback > 0) {
      return '${formatCommentCount(fallback)}条评论';
    }
    return '评论';
  }

  Future<void> _openCommentInput({
    ShortVideoCommentItem? replyToComment,
  }) async {
    if (!_supportsComment) {
      return;
    }
    final submitted = await showArticleCommentInputSheet(
      context,
      request: ShortVideoCommentSubmitRequest(
        docId: widget.item.id,
        docUrl: _docUrl,
        docName: widget.item.title,
        content: '',
        docType: ShortVideoCommentDocType.phvideo,
        docThumbnail: widget.item.coverUrl,
        subName: widget.item.source,
        replyToComment: replyToComment,
      ),
    );
    if (submitted == null || !mounted) {
      return;
    }
    _controller.insertSubmittedComment(
      submitted.comment,
      parentCommentId: submitted.parentCommentId,
    );
  }

  Future<void> _openFullscreenSheet() async {
    Navigator.of(context).pop();
    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      return;
    }
    await showRealShortVideoCommentSheet(
      context,
      item: widget.item,
      expanded: true,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = CommentThreadController(
      loadPage: (sortBy, page, pageSize) {
        if (!_supportsComment) {
          return Future<ShortVideoCommentPageResult>.value(
            const ShortVideoCommentPageResult(
              comments: <ShortVideoCommentItem>[],
              totalCount: 0,
              page: 1,
              pageSize: 10,
              hasMore: false,
            ),
          );
        }
        return getShortVideoComments(
          query: ShortVideoCommentQuery(
            docUrl: _docUrl,
            page: page,
            pageSize: pageSize,
            sortBy: sortBy,
          ),
        );
      },
      loadChildren: (parent, nextPage, pageSize) {
        return getShortVideoCommentChildren(
          query: ShortVideoCommentChildrenQuery(
            docUrl: parent.docUrl,
            commentId: parent.commentId,
            page: nextPage,
            pageSize: pageSize,
          ),
        );
      },
    )..addListener(_handleControllerChanged);
    _scrollController.addListener(_handleScroll);
    _controller.loadInitial();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleControllerChanged)
      ..dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _controller.isLoading ||
        _controller.isLoadingMore ||
        !_controller.hasMore) {
      return;
    }
    if (_scrollController.position.extentAfter > 240) {
      return;
    }
    _controller.loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return CommentPanelScaffold(
      header: _CommentSheetHeader(
        title: widget.item.title,
        commentsCountText: _titleText,
        sortLabel: _controller.sortBy.label,
        expanded: widget.expanded,
        onTapSort: () {
          showCommentSortActionSheet(
            context,
            onSelected: _controller.changeSort,
          );
        },
        onTapExpand: widget.expanded ? null : _openFullscreenSheet,
        onTapClose: () => Navigator.of(context).pop(),
      ),
      content: _controller.isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 12))
          : !_supportsComment || _controller.comments.isEmpty
              ? const CommentListEmptyState()
              : CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    CupertinoSliverRefreshControl(onRefresh: _controller.loadInitial),
                    SliverToBoxAdapter(
                      child: CommentListView(
                        comments: _controller.comments,
                        style: CommentListItemStyle.phvideo,
                        loadingReplyCommentId: _controller.loadingChildrenCommentId,
                        onTapReply: (comment) => _openCommentInput(
                          replyToComment: comment,
                        ),
                        onTapLoadMoreReplies: _controller.loadChildrenOf,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Center(
                          child: _controller.isLoadingMore
                              ? const CupertinoActivityIndicator(radius: 10)
                              : Text(
                                  _controller.hasMore ? '继续下拉加载更多' : '没有更多评论了',
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
      bottomBar: _CommentSheetBottomBar(
        isCollected: _isCollected,
        isLiked: _isLiked,
        onTapPlaceholder: _openCommentInput,
        onTapCollect: () {
          setState(() {
            _isCollected = !_isCollected;
          });
        },
        onTapLike: () {
          setState(() {
            _isLiked = !_isLiked;
          });
        },
      ),
    );
  }
}

class _CommentSheetHeader extends StatelessWidget {
  const _CommentSheetHeader({
    required this.title,
    required this.commentsCountText,
    required this.sortLabel,
    required this.expanded,
    required this.onTapSort,
    required this.onTapClose,
    this.onTapExpand,
  });

  final String title;
  final String commentsCountText;
  final String sortLabel;
  final bool expanded;
  final VoidCallback onTapSort;
  final VoidCallback onTapClose;
  final VoidCallback? onTapExpand;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: '大家都在搜: ',
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: title,
                        style: const TextStyle(
                          color: Color(0xFF406599),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(32, 32),
                onPressed: onTapExpand,
                child: AppAssetIcon(
                  assetName: 'expand-outline',
                  size: 20,
                  color: onTapExpand == null
                      ? const Color(0xFFC7C7CC)
                      : const Color(0xFF5C6270),
                  fallbackIcon: expanded
                      ? CupertinoIcons.arrow_up_left_arrow_down_right
                      : CupertinoIcons.fullscreen,
                ),
              ),
              const SizedBox(width: 6),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(32, 32),
                onPressed: onTapClose,
                child: const AppAssetIcon(
                  assetName: 'close',
                  size: 20,
                  color: Color(0xFF5C6270),
                  fallbackIcon: CupertinoIcons.xmark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Spacer(),
              CommentSortSelector(
                label: sortLabel,
                onTap: onTapSort,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentSheetBottomBar extends StatelessWidget {
  const _CommentSheetBottomBar({
    required this.isCollected,
    required this.isLiked,
    required this.onTapPlaceholder,
    required this.onTapCollect,
    required this.onTapLike,
  });

  final bool isCollected;
  final bool isLiked;
  final VoidCallback onTapPlaceholder;
  final VoidCallback onTapCollect;
  final VoidCallback onTapLike;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7FA),
        border: Border(
          top: BorderSide(color: Color(0xFFE8EAF0)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapPlaceholder,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(19),
                ),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '期待你的评论',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _BottomActionIcon(
            assetName: isCollected ? 'star' : 'star-outline',
            fallbackIcon: isCollected ? CupertinoIcons.star_fill : CupertinoIcons.star,
            onTap: onTapCollect,
          ),
          _BottomActionIcon(
            assetName: isLiked ? 'heart' : 'heart-outline',
            fallbackIcon: isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            onTap: onTapLike,
          ),
        ],
      ),
    );
  }
}

class _BottomActionIcon extends StatelessWidget {
  const _BottomActionIcon({
    required this.assetName,
    required this.fallbackIcon,
    required this.onTap,
  });

  final String assetName;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(28, 28),
        onPressed: onTap,
        child: AppAssetIcon(
          assetName: assetName,
          size: 24,
          color: const Color(0xFF1C1C1E),
          fallbackIcon: fallbackIcon,
        ),
      ),
    );
  }
}

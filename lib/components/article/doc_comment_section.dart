import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/short_video/comment.dart';
import 'package:oolaf_flutted/components/comment/comment_list_view.dart';
import 'package:oolaf_flutted/components/comment/comment_panel_scaffold.dart';
import 'package:oolaf_flutted/components/comment/comment_sort_selector.dart';
import 'package:oolaf_flutted/components/comment/comment_thread_controller.dart';

class DocCommentSection extends StatefulWidget {
  const DocCommentSection({
    super.key,
    required this.docId,
    required this.initialCommentsCount,
    required this.scrollController,
    this.sectionKey,
    this.onCommentsCountChanged,
    this.onTapReply,
  });

  final String docId;
  final String initialCommentsCount;
  final ScrollController scrollController;
  final Key? sectionKey;
  final ValueChanged<int>? onCommentsCountChanged;
  final ValueChanged<ShortVideoCommentItem>? onTapReply;

  @override
  State<DocCommentSection> createState() => _DocCommentSectionState();
}

class _DocCommentSectionState extends State<DocCommentSection> {
  late final CommentThreadController _controller;

  String get _titleText {
    if (_controller.totalCount > 0) {
      return '${formatCommentCount(_controller.totalCount)}条评论';
    }
    final fallback = int.tryParse(widget.initialCommentsCount) ?? 0;
    if (fallback > 0) {
      return '${formatCommentCount(fallback)}条评论';
    }
    return '评论';
  }

  @override
  void initState() {
    super.initState();
    _controller = CommentThreadController(
      loadPage: (sortBy, page, pageSize) {
        return getShortVideoComments(
          query: ShortVideoCommentQuery(
            docUrl: widget.docId,
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
    widget.scrollController.addListener(_handleScroll);
    _controller.loadInitial();
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
    _controller
      ..removeListener(_handleControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }
    widget.onCommentsCountChanged?.call(_controller.totalCount);
    setState(() {});
  }

  void _handleScroll() {
    if (!widget.scrollController.hasClients ||
        _controller.isLoading ||
        _controller.isLoadingMore ||
        !_controller.hasMore) {
      return;
    }
    if (widget.scrollController.position.extentAfter > 240) {
      return;
    }
    _controller.loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return CommentPanelScaffold(
      panelKey: widget.sectionKey,
      expandContent: false,
      crossAxisAlignment: CrossAxisAlignment.start,
      header: Column(
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
              CommentSortSelector(
                label: _controller.sortBy == ShortVideoCommentSortBy.hot ? '按热度' : '按时间',
                onTap: () {
                  showCommentSortActionSheet(
                    context,
                    onSelected: _controller.changeSort,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
      content: _controller.isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CupertinoActivityIndicator(radius: 12),
              ),
            )
          : _controller.comments.isEmpty
              ? const CommentListEmptyState(compact: true)
              : Column(
                  children: [
                    CommentListView(
                      comments: _controller.comments,
                      style: CommentListItemStyle.doc,
                      itemSpacing: 18,
                      loadingReplyCommentId: _controller.loadingChildrenCommentId,
                      onTapReply: widget.onTapReply,
                      onTapLoadMoreReplies: _controller.loadChildrenOf,
                    ),
                    if (_controller.hasMore || _controller.isLoadingMore)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: _controller.isLoadingMore
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
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:oolaf_flutted/api/short_video/comment.dart';

typedef CommentPageLoader = Future<ShortVideoCommentPageResult> Function(
  ShortVideoCommentSortBy sortBy,
  int page,
  int pageSize,
);

typedef CommentChildrenLoader = Future<List<ShortVideoCommentItem>> Function(
  ShortVideoCommentItem parent,
  int nextPage,
  int pageSize,
);

class CommentThreadController extends ChangeNotifier {
  CommentThreadController({
    required CommentPageLoader loadPage,
    required CommentChildrenLoader loadChildren,
    this.pageSize = 10,
    this.childrenPageSize = 4,
    ShortVideoCommentSortBy initialSortBy = ShortVideoCommentSortBy.hot,
  })  : _loadPage = loadPage,
        _loadChildren = loadChildren,
        _sortBy = initialSortBy;

  final CommentPageLoader _loadPage;
  final CommentChildrenLoader _loadChildren;
  final int pageSize;
  final int childrenPageSize;

  ShortVideoCommentSortBy _sortBy;
  List<ShortVideoCommentItem> _comments = const <ShortVideoCommentItem>[];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  int _totalCount = 0;
  String? _loadingChildrenCommentId;

  ShortVideoCommentSortBy get sortBy => _sortBy;
  List<ShortVideoCommentItem> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  int get page => _page;
  int get totalCount => _totalCount;
  String? get loadingChildrenCommentId => _loadingChildrenCommentId;

  void prependComment(ShortVideoCommentItem item) {
    _comments = <ShortVideoCommentItem>[
      item,
      ..._comments.where((existing) => existing.commentId != item.commentId),
    ];
    _totalCount += 1;
    notifyListeners();
  }

  void insertSubmittedComment(
    ShortVideoCommentItem item, {
    String? parentCommentId,
  }) {
    if (parentCommentId == null || parentCommentId.isEmpty) {
      prependComment(item);
      return;
    }

    var inserted = false;
    _comments = _comments.map((comment) {
      if (comment.commentId != parentCommentId) {
        return comment;
      }
      inserted = true;
      final nextChildren = <ShortVideoCommentItem>[
        item,
        ...comment.children.where(
          (child) => child.commentId != item.commentId,
        ),
      ];
      return comment.copyWith(
        children: nextChildren,
        childrenPage: nextChildren.isEmpty ? 0 : 1,
        replyCount: comment.replyCount + 1,
        canLoadMoreChildren: false,
      );
    }).toList(growable: false);

    if (!inserted) {
      prependComment(item);
      return;
    }
    notifyListeners();
  }

  Future<void> loadInitial() async {
    _isLoading = true;
    _isLoadingMore = false;
    _page = 1;
    notifyListeners();

    final result = await _loadPage(_sortBy, 1, pageSize);
    _comments = result.comments;
    _totalCount = result.totalCount;
    _hasMore = result.hasMore;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeSort(ShortVideoCommentSortBy nextSortBy) async {
    if (_sortBy == nextSortBy || _isLoading) {
      return;
    }
    _sortBy = nextSortBy;
    notifyListeners();
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _page + 1;
    final result = await _loadPage(_sortBy, nextPage, pageSize);
    _page = nextPage;
    _comments = <ShortVideoCommentItem>[
      ..._comments,
      ...result.comments,
    ];
    _totalCount = result.totalCount > 0 ? result.totalCount : _totalCount;
    _hasMore = result.hasMore && result.comments.isNotEmpty;
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadChildrenOf(ShortVideoCommentItem parent) async {
    if (_loadingChildrenCommentId == parent.commentId) {
      return;
    }

    _loadingChildrenCommentId = parent.commentId;
    notifyListeners();

    final nextPage = parent.childrenPage + 1;
    final children = await _loadChildren(parent, nextPage, childrenPageSize);
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
    notifyListeners();
  }
}

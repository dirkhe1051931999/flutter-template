import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/components/search_view/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_status_view.dart';
import 'package:oolaf_flutted/utils/hupu_search_history_persistence.dart';

class HupuSearchPage extends StatefulWidget {
  const HupuSearchPage({
    super.key,
    this.initialKeyword = '',
  });

  final String initialKeyword;

  @override
  State<HupuSearchPage> createState() => _HupuSearchPageState();
}

class _HupuSearchPageState extends State<HupuSearchPage> {
  static const String _allTabKey = 'all';
  static const String _usersTabKey = 'users';

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<SearchHistoryItem> _histories = const <SearchHistoryItem>[];
  List<SearchSuggestionItem> _hotKeywords = const <SearchSuggestionItem>[];

  bool _isLoadingHome = true;
  bool _isSearching = false;
  String? _homeErrorMessage;
  String? _searchErrorMessage;
  String _activeTabKey = _allTabKey;
  String _currentKeyword = '';

  List<HupuSearchPostItem> _postItems = const <HupuSearchPostItem>[];
  List<HupuSearchUserItem> _userItems = const <HupuSearchUserItem>[];
  int _postPage = 1;
  int _userPage = 1;
  bool _hasMorePosts = false;
  bool _hasMoreUsers = false;
  bool _isLoadingMorePosts = false;
  bool _isLoadingMoreUsers = false;

  bool get _isShowingResults => _currentKeyword.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialKeyword.trim();
    _bootstrap();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await Future.wait<void>([
      _loadHistory(),
      _loadHotKeywords(),
    ]);
    if (!mounted) {
      return;
    }
    if (widget.initialKeyword.trim().isNotEmpty) {
      await _submitSearch(widget.initialKeyword);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  Future<void> _loadHistory() async {
    final items = await HupuSearchHistoryPersistence.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _histories = items
          .map((item) => SearchHistoryItem(keyword: item))
          .toList(growable: false);
    });
  }

  Future<void> _loadHotKeywords() async {
    setState(() {
      _isLoadingHome = true;
      _homeErrorMessage = null;
    });

    try {
      final items = await getHupuSearchHotKeywords();
      if (!mounted) {
        return;
      }
      setState(() {
        _hotKeywords = items
            .asMap()
            .entries
            .map(
              (entry) => SearchSuggestionItem(
                id: '${entry.key}_${entry.value.itemId}',
                keyword: entry.value.displayText,
                badgeText: entry.value.isRecommend ? '荐' : null,
                isHighlight: entry.key < 3,
              ),
            )
            .toList(growable: false);
        _isLoadingHome = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _homeErrorMessage = error.toString();
        _isLoadingHome = false;
      });
    }
  }

  Future<void> _submitSearch(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty || _isSearching) {
      return;
    }

    _focusNode.unfocus();
    FocusScope.of(context).unfocus();
    _controller.text = trimmed;
    _controller.selection = TextSelection.collapsed(offset: trimmed.length);

    setState(() {
      _isSearching = true;
      _searchErrorMessage = null;
      _activeTabKey = _allTabKey;
    });

    try {
      final response = await searchHupuAll(keyword: trimmed);
      await HupuSearchHistoryPersistence.add(trimmed);
      if (!mounted) {
        return;
      }
      setState(() {
        _currentKeyword = trimmed;
        _postItems = response.posts;
        _userItems = response.users;
        _postPage = 1;
        _userPage = 1;
        _hasMorePosts = response.hasMorePosts;
        _hasMoreUsers = response.hasMoreUsers;
      });
      await _loadHistory();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searchErrorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _removeHistory(String keyword) async {
    await HupuSearchHistoryPersistence.remove(keyword);
    await _loadHistory();
  }

  Future<void> _clearHistory() async {
    await HupuSearchHistoryPersistence.clearAll();
    await _loadHistory();
  }

  void _tapKeyword(String keyword) {
    unawaited(_submitSearch(keyword));
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMorePosts || !_hasMorePosts || _currentKeyword.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingMorePosts = true;
    });

    try {
      final nextPage = _postPage + 1;
      final response = await searchHupuPosts(
        keyword: _currentKeyword,
        page: nextPage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _postItems = _mergePostItems(_postItems, response.items);
        _postPage = nextPage;
        _hasMorePosts = response.hasNextPage && response.items.isNotEmpty;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searchErrorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMorePosts = false;
        });
      }
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMoreUsers || !_hasMoreUsers || _currentKeyword.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingMoreUsers = true;
    });

    try {
      final nextPage = _userPage + 1;
      final response = await searchHupuUsers(
        keyword: _currentKeyword,
        page: nextPage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _userItems = _mergeUserItems(_userItems, response.items);
        _userPage = nextPage;
        _hasMoreUsers = response.hasNextPage && response.items.isNotEmpty;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searchErrorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMoreUsers = false;
        });
      }
    }
  }

  Future<void> _openPostDetail(HupuSearchPostItem item) async {
    if (item.id.isEmpty) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuPostDetailPage(
          tid: item.id,
          fid: item.fid,
          initialTitle: item.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isShowingResults) {
      if (_isLoadingHome) {
        return const CupertinoPageScaffold(
          child: Center(
            child: CupertinoActivityIndicator(radius: 14),
          ),
        );
      }

      if (_homeErrorMessage != null && _hotKeywords.isEmpty) {
        return CupertinoPageScaffold(
          child: SafeArea(
            child: HupuStatusView(
              message: '搜索页加载失败',
              detail: _homeErrorMessage,
              onRetry: _loadHotKeywords,
            ),
          ),
        );
      }

      return SharedSearchHomeView(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: '搜索虎扑内容、用户',
        histories: _histories,
        suggestions: _hotKeywords,
        onSubmit: _submitSearch,
        onTapHistory: _tapKeyword,
        onDeleteHistory: _removeHistory,
        onClearHistory: _clearHistory,
        onTapSuggestion: _tapKeyword,
      );
    }

    const tabs = <SearchTabItem>[
      SearchTabItem(key: _allTabKey, title: '综合'),
      SearchTabItem(key: _usersTabKey, title: '用户'),
    ];

    return SharedSearchResultShell(
      controller: _controller,
      focusNode: _focusNode,
      placeholder: '搜索虎扑内容、用户',
      onSubmit: _submitSearch,
      tabs: tabs,
      activeTabKey: _activeTabKey,
      onChangeTab: (value) {
        setState(() {
          _activeTabKey = value;
        });
      },
      tabBuilder: (context, tab) {
        if (_isSearching) {
          return const Center(
            child: CupertinoActivityIndicator(radius: 14),
          );
        }
        if (_searchErrorMessage != null &&
            _postItems.isEmpty &&
            _userItems.isEmpty) {
          return HupuStatusView(
            message: '搜索失败',
            detail: _searchErrorMessage,
            onRetry: () => _submitSearch(_currentKeyword),
          );
        }
        if (tab.key == _usersTabKey) {
          return _HupuSearchUserList(
            items: _userItems,
            hasMore: _hasMoreUsers,
            isLoadingMore: _isLoadingMoreUsers,
            onLoadMore: _loadMoreUsers,
          );
        }
        return _HupuSearchPostList(
          items: _postItems,
          hasMore: _hasMorePosts,
          isLoadingMore: _isLoadingMorePosts,
          onTapItem: _openPostDetail,
          onLoadMore: _loadMorePosts,
        );
      },
    );
  }
}

class _HupuSearchPostList extends StatefulWidget {
  const _HupuSearchPostList({
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onTapItem,
    required this.onLoadMore,
  });

  final List<HupuSearchPostItem> items;
  final bool hasMore;
  final bool isLoadingMore;
  final ValueChanged<HupuSearchPostItem> onTapItem;
  final Future<void> Function() onLoadMore;

  @override
  State<_HupuSearchPostList> createState() => _HupuSearchPostListState();
}

class _HupuSearchPostListState extends State<_HupuSearchPostList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
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
        widget.isLoadingMore ||
        !widget.hasMore ||
        _scrollController.position.extentAfter > 360) {
      return;
    }
    unawaited(widget.onLoadMore());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
        child: Text(
          '暂无搜索结果',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      itemCount: widget.items.length + 1,
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return _SearchLoadMoreFooter(
            hasMore: widget.hasMore,
            isLoading: widget.isLoadingMore,
          );
        }

        final item = widget.items[index];
        return GestureDetector(
          onTap: () => widget.onTapItem(item),
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.trim().isEmpty ? '无标题帖子' : item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF202127),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      if (item.content.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF5F6570),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ClipOval(
                            child: CustomNetworkImage(
                              item.header,
                              width: 24,
                              height: 24,
                              skeletonBorderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.username.trim().isEmpty ? '虎扑用户' : item.username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${item.forumName}  ${item.addTimeDisplay}  亮${item.lights}  回${item.replies}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF9AA0AA),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.hasImage) ...[
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        CustomNetworkImage(
                          item.previewImage,
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                          skeletonBorderRadius: BorderRadius.circular(12),
                        ),
                        if (item.movie)
                          Positioned(
                            right: 6,
                            bottom: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xB2000000),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                '视频',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HupuSearchUserList extends StatefulWidget {
  const _HupuSearchUserList({
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final List<HupuSearchUserItem> items;
  final bool hasMore;
  final bool isLoadingMore;
  final Future<void> Function() onLoadMore;

  @override
  State<_HupuSearchUserList> createState() => _HupuSearchUserListState();
}

class _HupuSearchUserListState extends State<_HupuSearchUserList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
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
        widget.isLoadingMore ||
        !widget.hasMore ||
        _scrollController.position.extentAfter > 360) {
      return;
    }
    unawaited(widget.onLoadMore());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
        child: Text(
          '暂无用户结果',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      itemCount: widget.items.length + 1,
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return _SearchLoadMoreFooter(
            hasMore: widget.hasMore,
            isLoading: widget.isLoadingMore,
          );
        }

        final HupuSearchUserItem currentItem = widget.items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipOval(
                child: CustomNetworkImage(
                  currentItem.header,
                  width: 52,
                  height: 52,
                  skeletonBorderRadius: BorderRadius.circular(26),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentItem.username.trim().isEmpty
                          ? '虎扑用户'
                          : currentItem.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF202127),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentItem.userInfo.trim().isEmpty
                          ? '推荐${currentItem.recNum}  亮了${currentItem.lights}  粉丝${currentItem.fans}'
                          : currentItem.userInfo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF7B818C),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE5484D)),
                ),
                child: Text(
                  currentItem.relationStatus == 1 ? '已关注' : '关注',
                  style: TextStyle(
                    color: currentItem.relationStatus == 1
                        ? const Color(0xFF9AA0AA)
                        : const Color(0xFFE5484D),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchLoadMoreFooter extends StatelessWidget {
  const _SearchLoadMoreFooter({
    required this.hasMore,
    required this.isLoading,
  });

  final bool hasMore;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CupertinoActivityIndicator(radius: 10),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          hasMore ? '继续上拉加载更多' : '没有更多了',
          style: const TextStyle(
            color: Color(0xFF9AA0AA),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

List<HupuSearchPostItem> _mergePostItems(
  List<HupuSearchPostItem> current,
  List<HupuSearchPostItem> incoming,
) {
  final merged = List<HupuSearchPostItem>.from(current);
  final ids = current.map((item) => item.id).toSet();
  for (final item in incoming) {
    if (item.id.isEmpty || ids.contains(item.id)) {
      continue;
    }
    ids.add(item.id);
    merged.add(item);
  }
  return merged;
}

List<HupuSearchUserItem> _mergeUserItems(
  List<HupuSearchUserItem> current,
  List<HupuSearchUserItem> incoming,
) {
  final merged = List<HupuSearchUserItem>.from(current);
  final ids = current.map((item) => item.id).toSet();
  for (final item in incoming) {
    if (item.id.isEmpty || ids.contains(item.id)) {
      continue;
    }
    ids.add(item.id);
    merged.add(item);
  }
  return merged;
}

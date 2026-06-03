import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/app_search/app_search_types.dart';
import 'package:oolaf_flutted/components/app_search/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/components/search_view/home.dart';
import 'package:oolaf_flutted/components/search_view/types.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';
import 'package:oolaf_flutted/pages/hupu/recommend-tabs/hot-tag-detail-page.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_status_view.dart';
import 'package:oolaf_flutted/utils/hupu_search_history_persistence.dart';
import 'package:oolaf_flutted/utils/hupu_rich_text.dart';

const String _hupuSearchAllTabKey = 'all';
const String _hupuSearchUsersTabKey = 'users';

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
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<SearchHistoryItem> _histories = const <SearchHistoryItem>[];
  List<SearchSuggestionItem> _hotKeywords = const <SearchSuggestionItem>[];

  bool _isLoadingHome = true;
  bool _isSearching = false;
  String? _homeErrorMessage;
  String? _searchErrorMessage;
  String _activeTabKey = _hupuSearchAllTabKey;
  String _currentKeyword = '';

  HupuSearchPostSection _postSection = HupuSearchPostSection.fromSection(null);
  HupuSearchUserSection _userSection = HupuSearchUserSection.fromSection(null);
  HupuSearchTopicSection _topicSection =
      HupuSearchTopicSection.fromSection(null);
  HupuSearchMatchSection _matchSection =
      HupuSearchMatchSection.fromSection(null);

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

    setState(() {
      _isSearching = true;
      _searchErrorMessage = null;
      _activeTabKey = _hupuSearchAllTabKey;
    });

    try {
      final response = await searchHupuAll(keyword: trimmed);
      await HupuSearchHistoryPersistence.add(trimmed);
      if (!mounted) {
        return;
      }
      setState(() {
        _currentKeyword = trimmed;
        _postSection = response.postSection;
        _userSection = response.userSection;
        _topicSection = response.topicSection;
        _matchSection = response.matchSection;
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
        _postSection = HupuSearchPostSection(
          title: _postSection.title,
          moreTitle: _postSection.moreTitle,
          items: _mergePostItems(_postSection.items, response.items),
          totalPage: response.totalPage,
          hasNextPage: response.hasNextPage && response.items.isNotEmpty,
        );
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
        _userSection = HupuSearchUserSection(
          title: _userSection.title,
          moreTitle: _userSection.moreTitle,
          items: _mergeUserItems(_userSection.items, response.items),
          totalPage: response.totalPage,
          hasNextPage: response.hasNextPage && response.items.isNotEmpty,
        );
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

  Future<void> _openPostMorePage() async {
    if (_currentKeyword.trim().isEmpty) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuSearchPostMorePage(
          keyword: _currentKeyword,
          initialTitle: _postSection.title,
        ),
      ),
    );
  }

  Future<void> _openTopicMorePage() async {
    if (_currentKeyword.trim().isEmpty) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuSearchTopicMorePage(
          keyword: _currentKeyword,
          initialTitle: _topicSection.title,
        ),
      ),
    );
  }

  Future<void> _openUserMorePage() async {
    if (_currentKeyword.trim().isEmpty) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuSearchUserMorePage(
          keyword: _currentKeyword,
          initialTitle: _userSection.title,
        ),
      ),
    );
  }

  Future<void> _openTopicDetail(HupuSearchTopicItem item) async {
    final tagId = int.tryParse(item.id) ?? 0;
    if (tagId <= 0) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuHotTagDetailPage(
          tagId: tagId,
          initialTitle: decodeHupuHtmlText(item.name),
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
        headerTrailing: _SearchActionButton(
          onTap: () => _submitSearch(_controller.text),
        ),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: false,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _HupuSearchHeader(
              controller: _controller,
              focusNode: _focusNode,
              onSubmit: _submitSearch,
            ),
            _HupuSearchTabs(
              activeTabKey: _activeTabKey,
              onChangeTab: (value) {
                setState(() {
                  _activeTabKey = value;
                });
              },
            ),
            Expanded(child: _buildResultBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBody() {
    if (_isSearching) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    if (_searchErrorMessage != null &&
        _postSection.items.isEmpty &&
        _userSection.items.isEmpty &&
        _topicSection.items.isEmpty &&
        _matchSection.items.isEmpty) {
      return HupuStatusView(
        message: '搜索失败',
        detail: _searchErrorMessage,
        onRetry: () => _submitSearch(_currentKeyword),
      );
    }

    if (_activeTabKey == _hupuSearchUsersTabKey) {
      return _HupuSearchResultList(
        child: _HupuUserSection(
          section: _userSection,
          isLoadingMore: _isLoadingMoreUsers,
          hasMore: _hasMoreUsers,
          onLoadMore: _loadMoreUsers,
          onTapMore: _openUserMorePage,
        ),
      );
    }

    final hasContent = _postSection.items.isNotEmpty ||
        _userSection.items.isNotEmpty ||
        _topicSection.items.isNotEmpty ||
        _matchSection.items.isNotEmpty;

    if (!hasContent) {
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

    return _HupuSearchResultList(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HupuPostSection(
            section: _postSection,
            isLoadingMore: _isLoadingMorePosts,
            hasMore: _hasMorePosts,
            onTapItem: _openPostDetail,
            onLoadMore: _loadMorePosts,
            onTapMore: _openPostMorePage,
          ),
          if (_topicSection.items.isNotEmpty)
            _HupuTopicSection(
              section: _topicSection,
              onTapMore: _openTopicMorePage,
              onTapItem: _openTopicDetail,
            ),
          if (_userSection.items.isNotEmpty)
            _HupuUserSection(
              section: _userSection,
              onTapMore: _openUserMorePage,
            ),
          if (_matchSection.items.isNotEmpty)
            _HupuMatchSection(section: _matchSection),
        ],
      ),
    );
  }
}

class _HupuSearchHeader extends StatelessWidget {
  const _HupuSearchHeader({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Future<void> Function(String keyword) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(6, 6, 8, 6),
      child: Row(
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            minimumSize: Size.zero,
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Icon(
              CupertinoIcons.back,
              size: 20,
              color: Color(0xFF202127),
            ),
          ),
          Expanded(
            child: AppSearch(
              controller: controller,
              focusNode: focusNode,
              shape: AppSearchShape.round,
              placeholder: '搜索虎扑内容、用户',
              background: const Color(0xFFF7F8FA),
              showAction: false,
              outerPadding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
              fieldPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              borderRadius: 20,
              fieldBorderRadius: 18,
              onSubmitted: (value) => onSubmit(value),
              onSearch: (value) => onSubmit(value),
              onActionTap: () => onSubmit(controller.text),
            ),
          ),
          _SearchActionButton(
            onTap: () => onSubmit(controller.text),
          ),
        ],
      ),
    );
  }
}

class _SearchActionButton extends StatelessWidget {
  const _SearchActionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.only(left: 8, right: 2),
      minimumSize: Size.zero,
      onPressed: onTap,
      child: const Text(
        '搜索',
        style: TextStyle(
          color: CupertinoColors.activeBlue,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HupuSearchTabs extends StatelessWidget {
  const _HupuSearchTabs({
    required this.activeTabKey,
    required this.onChangeTab,
  });

  final String activeTabKey;
  final ValueChanged<String> onChangeTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      color: CupertinoColors.white,
      child: Row(
        children: [
          _HupuTabItem(
            title: '综合',
            isActive: activeTabKey == _hupuSearchAllTabKey,
            onTap: () => onChangeTab(_hupuSearchAllTabKey),
          ),
          _HupuTabItem(
            title: '用户',
            isActive: activeTabKey == _hupuSearchUsersTabKey,
            onTap: () => onChangeTab(_hupuSearchUsersTabKey),
          ),
        ],
      ),
    );
  }
}

class _HupuTabItem extends StatelessWidget {
  const _HupuTabItem({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color:
                    isActive ? const Color(0xFF202127) : const Color(0xFF8E8E93),
                fontSize: 17,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 7),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 28,
              height: 3,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE9252E)
                    : CupertinoColors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HupuSearchResultList extends StatelessWidget {
  const _HupuSearchResultList({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        child,
      ],
    );
  }
}

class _HupuSectionHeader extends StatelessWidget {
  const _HupuSectionHeader({
    required this.title,
    required this.moreTitle,
    this.onTapMore,
  });

  final String title;
  final String moreTitle;
  final VoidCallback? onTapMore;

  @override
  Widget build(BuildContext context) {
    final displayMoreTitle = moreTitle.trim().isEmpty ? '查看更多' : moreTitle;
    return Container(
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapMore ?? () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  Text(
                    displayMoreTitle,
                    style: const TextStyle(
                      color: Color(0xFF9AA0AA),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    CupertinoIcons.right_chevron,
                    size: 14,
                    color: Color(0xFFB0B6C0),
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

class _HupuPostSection extends StatelessWidget {
  const _HupuPostSection({
    required this.section,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onTapItem,
    required this.onLoadMore,
    required this.onTapMore,
  });

  final HupuSearchPostSection section;
  final bool isLoadingMore;
  final bool hasMore;
  final ValueChanged<HupuSearchPostItem> onTapItem;
  final Future<void> Function() onLoadMore;
  final VoidCallback onTapMore;

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return _LoadMoreSection(
      onLoadMore: onLoadMore,
      canLoadMore: hasMore && !isLoadingMore,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HupuSectionHeader(
            title: section.title,
            moreTitle: section.moreTitle,
            onTapMore: onTapMore,
          ),
          ...section.items.map(
            (item) => _HupuPostCard(
              item: item,
              onTap: () => onTapItem(item),
            ),
          ),
          if (isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CupertinoActivityIndicator(radius: 10),
              ),
            ),
        ],
      ),
    );
  }
}

class _HupuPostCard extends StatelessWidget {
  const _HupuPostCard({
    required this.item,
    required this.onTap,
  });

  final HupuSearchPostItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HupuInlineHighlightText(
                        text: item.title.trim().isEmpty ? '无标题帖子' : item.title,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Color(0xFF202127),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          height: 1.28,
                        ),
                      ),
                      if (item.content.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _HupuInlineHighlightText(
                          text: item.content,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Color(0xFF9096A0),
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (item.hasImage) ...[
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: CustomNetworkImage(
                      item.previewImage,
                      width: 118,
                      height: 76,
                      fit: BoxFit.cover,
                      skeletonBorderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.replies}回复/${item.recNum}推荐',
                    style: const TextStyle(
                      color: Color(0xFF8F96A3),
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  item.forumName,
                  style: const TextStyle(
                    color: Color(0xFF8F96A3),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _normalizeDateLabel(item.addTimeDisplay),
                  style: const TextStyle(
                    color: Color(0xFF8F96A3),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Container(
              height: 1,
              color: const Color(0xFFF0F1F4),
            ),
          ],
        ),
      ),
    );
  }
}

class _HupuTopicSection extends StatelessWidget {
  const _HupuTopicSection({
    required this.section,
    required this.onTapMore,
    required this.onTapItem,
  });

  final HupuSearchTopicSection section;
  final VoidCallback onTapMore;
  final ValueChanged<HupuSearchTopicItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _HupuSectionHeader(
          title: section.title,
          moreTitle: section.moreTitle,
          onTapMore: onTapMore,
        ),
        ...section.items.map(
          (item) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTapItem(item),
            child: Container(
              color: CupertinoColors.white,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HupuInlineHighlightText(
                              text: '#${item.name} #',
                              maxLines: 2,
                              style: const TextStyle(
                                color: Color(0xFF202127),
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                height: 1.28,
                              ),
                            ),
                            if (item.info.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                item.info,
                                style: const TextStyle(
                                  color: Color(0xFF8F96A3),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: CustomNetworkImage(
                          item.icon,
                          width: 116,
                          height: 74,
                          fit: BoxFit.cover,
                          skeletonBorderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: 1,
                    color: const Color(0xFFF0F1F4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HupuUserSection extends StatelessWidget {
  const _HupuUserSection({
    required this.section,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onTapMore,
  });

  final HupuSearchUserSection section;
  final bool isLoadingMore;
  final bool hasMore;
  final Future<void> Function()? onLoadMore;
  final VoidCallback? onTapMore;

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HupuSectionHeader(
          title: section.title,
          moreTitle: section.moreTitle,
          onTapMore: onTapMore,
        ),
        ...section.items.map(
          (item) => Container(
            color: CupertinoColors.white,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: CustomNetworkImage(
                        item.header,
                        width: 42,
                        height: 42,
                        skeletonBorderRadius: BorderRadius.circular(21),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HupuInlineHighlightText(
                            text: item.username.trim().isEmpty
                                ? '虎扑用户'
                                : item.username,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Color(0xFF202127),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.userInfo.trim().isEmpty
                                ? '被推荐${item.recNum} 被点亮${item.lights} 被${item.fans}人关注'
                                : item.userInfo,
                            style: const TextStyle(
                              color: Color(0xFF8F96A3),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      color: const Color(0xFFFF1E2D),
                      child: const Text(
                        '+ 关注',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: const Color(0xFFF0F1F4),
                ),
              ],
            ),
          ),
        ),
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CupertinoActivityIndicator(radius: 10),
            ),
          ),
      ],
    );

    if (onLoadMore == null) {
      return content;
    }

    return _LoadMoreSection(
      onLoadMore: onLoadMore!,
      canLoadMore: hasMore && !isLoadingMore,
      child: content,
    );
  }
}

class _HupuMatchSection extends StatelessWidget {
  const _HupuMatchSection({required this.section});

  final HupuSearchMatchSection section;

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _HupuSectionHeader(
          title: section.title,
          moreTitle: section.moreTitle,
        ),
        ...section.items.map(
          (day) => Container(
            color: CupertinoColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFFF5F5F7),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Text(
                    day.dayBlock,
                    style: const TextStyle(
                      color: Color(0xFF7A808C),
                      fontSize: 15,
                    ),
                  ),
                ),
                ...day.matches.map((match) => _HupuMatchCard(match: match)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HupuMatchCard extends StatelessWidget {
  const _HupuMatchCard({required this.match});

  final HupuSearchMatchItem match;

  @override
  Widget build(BuildContext context) {
    final playerScore = match.playerScore;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  match.matchTime,
                  style: const TextStyle(
                    color: Color(0xFF202127),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    _HupuMatchTeamLine(
                      logoUrl: match.homeTeamLogo,
                      teamName: match.homeTeamName,
                      score: match.homeScoreString,
                    ),
                    const SizedBox(height: 10),
                    _HupuMatchTeamLine(
                      logoUrl: match.awayTeamLogo,
                      teamName: match.awayTeamName,
                      score: match.awayScoreString,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 82,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFF0F1F4)),
                ),
                child: Column(
                  children: [
                    Text(
                      match.matchStatusChinese,
                      style: const TextStyle(
                        color: Color(0xFF202127),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (match.pv.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        match.pv,
                        style: const TextStyle(
                          color: Color(0xFF8F96A3),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (playerScore != null) ...[
            const SizedBox(height: 10),
            Container(
              color: const Color(0xFFFFF8E8),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CustomNetworkImage(
                      playerScore.playerLogo,
                      width: 42,
                      height: 42,
                      skeletonBorderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playerScore.playerName,
                          style: const TextStyle(
                            color: Color(0xFF202127),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (playerScore.hotComment.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            playerScore.hotComment,
                            style: const TextStyle(
                              color: Color(0xFFFF7A00),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        playerScore.playerScore.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFF00A7D6),
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (playerScore.playerScoreCount.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          playerScore.playerScoreCount,
                          style: const TextStyle(
                            color: Color(0xFF8F96A3),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HupuMatchTeamLine extends StatelessWidget {
  const _HupuMatchTeamLine({
    required this.logoUrl,
    required this.teamName,
    required this.score,
  });

  final String logoUrl;
  final String teamName;
  final String score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomNetworkImage(
          logoUrl,
          width: 22,
          height: 22,
          skeletonBorderRadius: BorderRadius.circular(11),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            teamName,
            style: const TextStyle(
              color: Color(0xFF202127),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          score,
          style: const TextStyle(
            color: Color(0xFF202127),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _LoadMoreSection extends StatefulWidget {
  const _LoadMoreSection({
    required this.child,
    required this.onLoadMore,
    required this.canLoadMore,
  });

  final Widget child;
  final Future<void> Function() onLoadMore;
  final bool canLoadMore;

  @override
  State<_LoadMoreSection> createState() => _LoadMoreSectionState();
}

class _LoadMoreSectionState extends State<_LoadMoreSection> {
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
        !widget.canLoadMore ||
        _scrollController.position.extentAfter > 360) {
      return;
    }
    unawaited(widget.onLoadMore());
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: _scrollController,
      child: widget.child,
    );
  }
}

class HupuSearchPostMorePage extends StatefulWidget {
  const HupuSearchPostMorePage({
    super.key,
    required this.keyword,
    this.initialTitle = '帖子',
  });

  final String keyword;
  final String initialTitle;

  @override
  State<HupuSearchPostMorePage> createState() => _HupuSearchPostMorePageState();
}

class _HupuSearchPostMorePageState extends State<HupuSearchPostMorePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String _activeSort = 'general';
  List<HupuSearchPostSortItem> _sortItems = const <HupuSearchPostSortItem>[];
  HupuSearchPostSection _section = HupuSearchPostSection.fromSection(null);
  int _page = 1;

  bool get _hasMore => _section.hasNextPage;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.keyword;
    _scrollController.addListener(_handleScroll);
    _loadPosts(reset: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadPosts({
    required bool reset,
    String? nextSort,
  }) async {
    final targetSort = nextSort ?? _activeSort;
    final nextPage = reset ? 1 : (_page + 1);

    setState(() {
      if (reset) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _errorMessage = null;
    });

    try {
      final response = await searchHupuPostList(
        keyword: widget.keyword,
        page: nextPage,
        postSort: targetSort,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _activeSort = targetSort;
        _sortItems = response.sortItems.isEmpty
            ? const <HupuSearchPostSortItem>[
                HupuSearchPostSortItem(name: '全部', postSort: 'general'),
                HupuSearchPostSortItem(name: '最新', postSort: 'createtime'),
                HupuSearchPostSortItem(name: '最热', postSort: 'reply'),
              ]
            : response.sortItems;
        _section = HupuSearchPostSection(
          title: response.section.title.trim().isEmpty
              ? widget.initialTitle
              : response.section.title,
          moreTitle: response.section.moreTitle,
          items: reset
              ? response.section.items
              : _mergePostItems(_section.items, response.section.items),
          totalPage: response.section.totalPage,
          hasNextPage:
              response.section.hasNextPage && response.section.items.isNotEmpty,
        );
        _page = nextPage;
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
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        !_hasMore ||
        _scrollController.position.extentAfter > 320) {
      return;
    }
    unawaited(_loadPosts(reset: false));
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
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _HupuSearchHeader(
              controller: _controller,
              focusNode: _focusNode,
              onSubmit: (_) async {},
            ),
            Container(
              color: CupertinoColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _sortItems.map((item) {
                  final isActive = item.postSort == _activeSort;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (item.postSort == _activeSort) {
                        return;
                      }
                      unawaited(_loadPosts(reset: true, nextSort: item.postSort));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 28, top: 10, bottom: 9),
                      child: Text(
                        item.name,
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF202127)
                              : const Color(0xFF8E8E93),
                          fontSize: 17,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    if (_errorMessage != null && _section.items.isEmpty) {
      return HupuStatusView(
        message: '帖子加载失败',
        detail: _errorMessage,
        onRetry: () => _loadPosts(reset: true),
      );
    }

    if (_section.items.isEmpty) {
      return const Center(
        child: Text(
          '暂无帖子结果',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _section.items.length + 1,
      itemBuilder: (context, index) {
        if (index == _section.items.length) {
          if (_isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CupertinoActivityIndicator(radius: 10),
              ),
            );
          }
          return const SizedBox(height: 12);
        }
        return _HupuPostCard(
          item: _section.items[index],
          onTap: () => _openPostDetail(_section.items[index]),
        );
      },
    );
  }
}

class HupuSearchTopicMorePage extends StatefulWidget {
  const HupuSearchTopicMorePage({
    super.key,
    required this.keyword,
    this.initialTitle = '话题',
  });

  final String keyword;
  final String initialTitle;

  @override
  State<HupuSearchTopicMorePage> createState() =>
      _HupuSearchTopicMorePageState();
}

class _HupuSearchTopicMorePageState extends State<HupuSearchTopicMorePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  HupuSearchTopicSection _section = HupuSearchTopicSection.fromSection(null);
  int _page = 1;

  bool get _hasMore => _section.hasNextPage;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.keyword;
    _scrollController.addListener(_handleScroll);
    _loadTopics(reset: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadTopics({required bool reset}) async {
    final nextPage = reset ? 1 : (_page + 1);

    setState(() {
      if (reset) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _errorMessage = null;
    });

    try {
      final response = await searchHupuTopicList(
        keyword: widget.keyword,
        page: nextPage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _section = HupuSearchTopicSection(
          title: response.section.title.trim().isEmpty
              ? widget.initialTitle
              : response.section.title,
          moreTitle: response.section.moreTitle,
          items: reset
              ? response.section.items
              : _mergeTopicItems(_section.items, response.section.items),
          totalPage: response.section.totalPage,
          hasNextPage:
              response.section.hasNextPage && response.section.items.isNotEmpty,
        );
        _page = nextPage;
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
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        !_hasMore ||
        _scrollController.position.extentAfter > 320) {
      return;
    }
    unawaited(_loadTopics(reset: false));
  }

  Future<void> _openTopicDetail(HupuSearchTopicItem item) async {
    final tagId = int.tryParse(item.id) ?? 0;
    if (tagId <= 0) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuHotTagDetailPage(
          tagId: tagId,
          initialTitle: decodeHupuHtmlText(item.name),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _HupuSearchHeader(
              controller: _controller,
              focusNode: _focusNode,
              onSubmit: (_) async {},
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    if (_errorMessage != null && _section.items.isEmpty) {
      return HupuStatusView(
        message: '话题加载失败',
        detail: _errorMessage,
        onRetry: () => _loadTopics(reset: true),
      );
    }

    if (_section.items.isEmpty) {
      return const Center(
        child: Text(
          '暂无话题结果',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _section.items.length + 1,
      itemBuilder: (context, index) {
        if (index == _section.items.length) {
          if (_isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CupertinoActivityIndicator(radius: 10),
              ),
            );
          }
          return const SizedBox(height: 12);
        }

        final item = _section.items[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openTopicDetail(item),
          child: Container(
            color: CupertinoColors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HupuInlineHighlightText(
                            text: '#${item.name} #',
                            maxLines: 2,
                            style: const TextStyle(
                              color: Color(0xFF202127),
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              height: 1.28,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.info.trim().isEmpty ? '${item.discussNum}讨论' : item.info,
                            style: const TextStyle(
                              color: Color(0xFF8F96A3),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: CustomNetworkImage(
                        item.icon,
                        width: 116,
                        height: 74,
                        fit: BoxFit.cover,
                        skeletonBorderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  height: 1,
                  color: const Color(0xFFF0F1F4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HupuSearchUserMorePage extends StatefulWidget {
  const HupuSearchUserMorePage({
    super.key,
    required this.keyword,
    this.initialTitle = '用户',
  });

  final String keyword;
  final String initialTitle;

  @override
  State<HupuSearchUserMorePage> createState() => _HupuSearchUserMorePageState();
}

class _HupuSearchUserMorePageState extends State<HupuSearchUserMorePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  HupuSearchUserSection _section = HupuSearchUserSection.fromSection(null);
  int _page = 1;

  bool get _hasMore => _section.hasNextPage;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.keyword;
    _scrollController.addListener(_handleScroll);
    _loadUsers(reset: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadUsers({required bool reset}) async {
    final nextPage = reset ? 1 : (_page + 1);

    setState(() {
      if (reset) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _errorMessage = null;
    });

    try {
      final response = await searchHupuUserList(
        keyword: widget.keyword,
        page: nextPage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _section = HupuSearchUserSection(
          title: response.section.title.trim().isEmpty
              ? widget.initialTitle
              : response.section.title,
          moreTitle: response.section.moreTitle,
          items: reset
              ? response.section.items
              : _mergeUserItems(_section.items, response.section.items),
          totalPage: response.section.totalPage,
          hasNextPage:
              response.section.hasNextPage && response.section.items.isNotEmpty,
        );
        _page = nextPage;
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
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        !_hasMore ||
        _scrollController.position.extentAfter > 320) {
      return;
    }
    unawaited(_loadUsers(reset: false));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _HupuSearchHeader(
              controller: _controller,
              focusNode: _focusNode,
              onSubmit: (_) async {},
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    if (_errorMessage != null && _section.items.isEmpty) {
      return HupuStatusView(
        message: '用户加载失败',
        detail: _errorMessage,
        onRetry: () => _loadUsers(reset: true),
      );
    }

    if (_section.items.isEmpty) {
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
      itemCount: _section.items.length + 1,
      itemBuilder: (context, index) {
        if (index == _section.items.length) {
          if (_isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CupertinoActivityIndicator(radius: 10),
              ),
            );
          }
          return const SizedBox(height: 12);
        }

        final item = _section.items[index];
        return Container(
          color: CupertinoColors.white,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            children: [
              Row(
                children: [
                  ClipOval(
                    child: CustomNetworkImage(
                      item.header,
                      width: 42,
                      height: 42,
                      skeletonBorderRadius: BorderRadius.circular(21),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HupuInlineHighlightText(
                          text: item.username.trim().isEmpty
                              ? '虎扑用户'
                              : item.username,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Color(0xFF202127),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.userInfo.trim().isEmpty
                              ? '被推荐${item.recNum} 被点亮${item.lights} 被${item.fans}人关注'
                              : item.userInfo,
                          style: const TextStyle(
                            color: Color(0xFF8F96A3),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    color: const Color(0xFFFF1E2D),
                    child: const Text(
                      '+ 关注',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: const Color(0xFFF0F1F4),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HupuInlineHighlightText extends StatelessWidget {
  const _HupuInlineHighlightText({
    required this.text,
    required this.style,
    this.maxLines,
  });

  final String text;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: style,
        children: buildHupuHighlightSpans(text, style),
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

List<HupuSearchTopicItem> _mergeTopicItems(
  List<HupuSearchTopicItem> current,
  List<HupuSearchTopicItem> incoming,
) {
  final merged = List<HupuSearchTopicItem>.from(current);
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

String _normalizeDateLabel(String value) {
  final trimmed = value.trim();
  if (trimmed.contains('-')) {
    return trimmed;
  }
  if (trimmed.contains('分钟前') || trimmed.contains('小时前')) {
    return trimmed;
  }
  return trimmed;
}

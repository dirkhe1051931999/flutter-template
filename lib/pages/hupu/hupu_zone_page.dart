import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/app_sidebar/app_sidebar_types.dart';
import 'package:oolaf_flutted/components/app_sidebar/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_search_page.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_status_view.dart';

class HupuZonePage extends StatefulWidget {
  const HupuZonePage({super.key});

  @override
  State<HupuZonePage> createState() => _HupuZonePageState();
}

class _HupuZonePageState extends State<HupuZonePage> {
  List<HupuTopicCategory> _categories = const <HupuTopicCategory>[];
  bool _isLoading = true;
  String? _errorMessage;
  int _activeCategoryIndex = 0;
  final ScrollController _topicGridScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _topicGridScrollController.dispose();
    super.dispose();
  }

  List<AppSidebarItemData> get _sidebarItems {
    return _categories
        .map(
          (category) => AppSidebarItemData(
            title: category.name,
          ),
        )
        .toList(growable: false);
  }

  void _scrollTopicGridToTop() {
    if (!_topicGridScrollController.hasClients) {
      return;
    }
    _topicGridScrollController.jumpTo(0);
  }

  void _handleCategoryChange(int index) {
    if (index == _activeCategoryIndex) {
      _scrollTopicGridToTop();
      return;
    }

    setState(() {
      _activeCategoryIndex = index;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollTopicGridToTop();
    });
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await getHupuTopicCategories();
      if (!mounted) {
        return;
      }

      setState(() {
        _categories = response.categories;
        _activeCategoryIndex = 0;
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

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7FA),
      ),
      child: Column(
        children: [
          _HupuZoneHeader(
            onTapSearch: () {
              Navigator.of(context).push<void>(
                CupertinoPageRoute<void>(
                  builder: (_) => const HupuSearchPage(),
                ),
              );
            },
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    if (_categories.isEmpty) {
      return HupuStatusView(
        message: _errorMessage == null ? '暂无分类' : '加载失败',
        detail: _errorMessage,
        onRetry: _fetchCategories,
      );
    }

    final safeIndex = _activeCategoryIndex.clamp(0, _categories.length - 1);
    final activeCategory = _categories[safeIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSidebar(
            items: _sidebarItems,
            activeKey: safeIndex,
            width: 96,
            activeColor: const Color(0xFFE93B3D),
            backgroundColor: const Color(0xFFF1F3F7),
            onChange: _handleCategoryChange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _HupuZoneContentPanel(
              category: activeCategory,
              scrollController: _topicGridScrollController,
            ),
          ),
        ],
      ),
    );
  }
}

class _HupuZoneHeader extends StatelessWidget {
  const _HupuZoneHeader({
    required this.onTapSearch,
  });

  final VoidCallback onTapSearch;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xF2FFFFFF),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF111827).withValues(alpha: 0.06),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              const Text(
                '虎扑',
                style: TextStyle(
                  color: Color(0xFFE31B23),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '专区',
                  style: TextStyle(
                    color: Color(0xFF202127),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(32, 32),
                onPressed: onTapSearch,
                child: const Icon(
                  CupertinoIcons.search,
                  size: 24,
                  color: Color(0xFF202127),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HupuZoneContentPanel extends StatelessWidget {
  const _HupuZoneContentPanel({
    required this.category,
    required this.scrollController,
  });

  final HupuTopicCategory category;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HupuZoneLoginBanner(
              categoryName: category.name,
            ),
            const SizedBox(height: 16),
            Text(
              category.name,
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${category.topics.length} 个话题分区',
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 132,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 138,
                ),
                itemCount: category.topics.length,
                itemBuilder: (context, index) {
                  final topic = category.topics[index];
                  return _HupuTopicGridItem(topic: topic);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HupuZoneLoginBanner extends StatelessWidget {
  const _HupuZoneLoginBanner({
    required this.categoryName,
  });

  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '登录账号，查看你加入的专区',
                    style: TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '当前分类：$categoryName',
                    style: const TextStyle(
                      color: Color(0xFFB0B3BB),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              minimumSize: Size.zero,
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFFFFFFF),
              onPressed: () {},
              child: const Text(
                '立即登录',
                style: TextStyle(
                  color: Color(0xFFE93B3D),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HupuTopicGridItem extends StatelessWidget {
  const _HupuTopicGridItem({
    required this.topic,
  });

  final HupuTopicItem topic;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEEF1F6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CustomNetworkImage(
                topic.logo,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                skeletonBorderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    topic.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    topic.countText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFB0B3BB),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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

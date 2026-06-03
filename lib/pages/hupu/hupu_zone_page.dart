import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
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

  void _scrollTopicGridToTop() {
    if (!_topicGridScrollController.hasClients) {
      return;
    }
    _topicGridScrollController.jumpTo(0);
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
    return ColoredBox(
      color: Colors.white,
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

    return Row(
      children: [
        Container(
          width: 88,
          color: const Color(0xFFF7F8FB),
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isActive = index == safeIndex;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
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
                },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: isActive
                            ? const Color(0xFFE93B3D)
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF202127)
                          : const Color(0xFF7F838C),
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HupuZoneLoginBanner(
                  categoryName: activeCategory.name,
                ),
                const SizedBox(height: 12),
                Text(
                  activeCategory.name,
                  style: const TextStyle(
                    color: Color(0xFF202127),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    controller: _topicGridScrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: activeCategory.topics.length,
                    itemBuilder: (context, index) {
                      final topic = activeCategory.topics[index];
                      return _HupuTopicGridItem(topic: topic);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F1F4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2, right: 14),
            child: Text(
              '虎扑',
              style: TextStyle(
                color: Color(0xFFE31B23),
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '专区',
                style: TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTapSearch,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                CupertinoIcons.search,
                size: 22,
                color: Color(0xFF202127),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(8),
      ),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '当前分类：$categoryName',
                  style: const TextStyle(
                    color: Color(0xFFB0B3BB),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE93B3D)),
            ),
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
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CustomNetworkImage(
            topic.logo,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            skeletonBorderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          topic.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF202127),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          topic.countText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFB0B3BB),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

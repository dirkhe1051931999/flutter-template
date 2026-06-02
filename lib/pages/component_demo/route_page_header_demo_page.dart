import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';
import 'package:oolaf_flutted/components/route_page_header/index.dart';
import 'package:oolaf_flutted/layouts/app_wrap/index.dart';

class RoutePageHeaderDemoPage extends StatelessWidget {
  const RoutePageHeaderDemoPage({super.key});

  static const String _avatarUrl = 'https://picsum.photos/id/1005/200/200';

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Route Page Header',
      widget: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _DemoCard(
            title: '作为导航栏使用',
            subtitle: '直接挂到 CupertinoPageScaffold.navigationBar',
            child: RoutePageHeader(
              title: '帖子详情',
              subtitle: '标题居中，不遮内容',
              onBack: () {
                AppToast.showText('这里只是示意，不执行返回');
              },
            ),
          ),
          const SizedBox(height: 14),
          _DemoCard(
            title: '头像标题样式',
            subtitle: '适合作者页、频道页、资料页',
            child: RoutePageHeader(
              title: 'Allen Iverson',
              subtitle: '76ers legend',
              avatarUrl: _avatarUrl,
              onBack: () {
                AppToast.showText('头像标题样式');
              },
            ),
          ),
          const SizedBox(height: 14),
          _DemoCard(
            title: '操作区扩展',
            subtitle: '跟随按钮、更多按钮、自定义 trailing',
            child: Column(
              children: [
                RoutePageHeader(
                  title: '频道详情',
                  subtitle: 'follow + more',
                  onBack: () {
                    AppToast.showText('follow + more');
                  },
                  showFollowButton: true,
                  showMoreButton: true,
                  onTapFollow: () {
                    AppToast.showText('点击了关注');
                  },
                  onTapMore: () {
                    AppToast.showText('点击了更多');
                  },
                ),
                const SizedBox(height: 10),
                RoutePageHeader(
                  title: '自定义 trailing',
                  subtitle: '比如状态标签或切换器',
                  onBack: () {
                    AppToast.showText('自定义 trailing');
                  },
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE9E6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Live',
                      style: TextStyle(
                        color: Color(0xFFE5484D),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF8F96A3),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: CupertinoColors.white,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

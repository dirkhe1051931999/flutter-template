import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_swipe_cell/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class AppSwipeCellDemoPage extends StatelessWidget {
  const AppSwipeCellDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant SwipeCell，提供左右滑出操作区，适合消息和待办列表。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础示例',
          subtitle: '支持 left / right actions，滑动后可触发收藏、置顶、删除等操作。',
          child: AppSwipeCell(
            leftActions: [
              AppSwipeCellAction(
                text: '收藏',
                color: const Color(0xFF0EA5E9),
                onTap: () => AppToast.showText('收藏'),
              ),
            ],
            rightActions: [
              AppSwipeCellAction(
                text: '置顶',
                color: const Color(0xFF7C3AED),
                onTap: () => AppToast.showText('置顶'),
              ),
              AppSwipeCellAction(
                text: '删除',
                onTap: () => AppToast.showText('删除'),
              ),
            ],
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xCCFFFFFF),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0x12000000)),
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '下午 3:00 和设计团队同步交互细节',
                            style: TextStyle(
                              color: Color(0xFF202127),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '向左或向右滑动可触发不同操作',
                            style: TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_left_slash_chevron_right,
                      size: 18,
                      color: Color(0xFF98A2B3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({
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
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    const items = [
      '支持左右两侧 actions，自定义宽度、颜色和点击回调。',
      '适合消息中心、任务列表、商品收藏和聊天会话滑动操作。',
      '比 Dismissible 更接近 Vant SwipeCell 的交互语义。',
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

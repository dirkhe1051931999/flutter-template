import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_swipe/app_swipe_types.dart';
import 'package:oolaf_flutted/components/app_swipe/index.dart';

class AppSwipeDemoPage extends StatelessWidget {
  const AppSwipeDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: const [
        _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Swipe，提供轮播、自动播放、指示器和多卡片视窗。',
          child: _FeatureList(),
        ),
        SizedBox(height: 14),
        _DemoSection(
          title: '基础轮播',
          subtitle: '支持 autoplay、loop、指示器位置。',
          child: AppSwipe(
            autoplay: true,
            height: 180,
            children: [
              _SwipeCard(color: Color(0xFF2563EB), title: 'Banner 01'),
              _SwipeCard(color: Color(0xFF0EA5E9), title: 'Banner 02'),
              _SwipeCard(color: Color(0xFF7C3AED), title: 'Banner 03'),
            ],
          ),
        ),
        SizedBox(height: 14),
        _DemoSection(
          title: '多卡片视窗',
          subtitle: '适合活动卡片、推荐位和内容流预览。',
          child: SizedBox(
            height: 160,
            child: AppSwipe(
              viewportFraction: 0.88,
              showIndicators: true,
              indicatorPosition: AppSwipeIndicatorPosition.right,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: _SwipeCard(color: Color(0xFFF59E0B), title: 'Coffee Drop'),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: _SwipeCard(color: Color(0xFF16A34A), title: 'Green Pack'),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: _SwipeCard(color: Color(0xFFE5484D), title: 'Weekend Sale'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SwipeCard extends StatelessWidget {
  const _SwipeCard({
    required this.color,
    required this.title,
  });

  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.76),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            const Text(
              '支持自动播放、循环和自定义视窗比例',
              style: TextStyle(
                color: Color(0xE6FFFFFF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
      '支持 autoplay、loop、duration、指示器位置和 viewportFraction。',
      '适合 banner、推荐位、活动卡片和图文轮播场景。',
      'demo 里覆盖了标准横幅和多卡片预览两种形式。',
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

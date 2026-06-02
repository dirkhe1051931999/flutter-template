import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_text_ellipsis/app_text_ellipsis_types.dart';
import 'package:oolaf_flutted/components/app_text_ellipsis/index.dart';

class AppTextEllipsisDemoPage extends StatelessWidget {
  const AppTextEllipsisDemoPage({super.key});

  static const _longText =
      'TextEllipsis 适合处理资讯摘要、商品描述和用户简介这类长文本场景。这个版本参考 Vant，支持按行数截断、展开收起和前后中三种省略位置，整体保持更接近 iOS 26 的轻盈卡片感。';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: const [
        _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant TextEllipsis，补齐多行省略、展开收起和不同内容截断位置。',
          child: _FeatureList(),
        ),
        SizedBox(height: 14),
        _DemoSection(
          title: '基础用法',
          subtitle: '默认按尾部省略，点击展开后可以查看完整内容。',
          child: AppTextEllipsis(
            text: _longText,
            rows: 2,
          ),
        ),
        SizedBox(height: 14),
        _DemoSection(
          title: '中间省略',
          subtitle: '适合文件路径、订单号或 Token 等头尾都重要的内容。',
          child: AppTextEllipsis(
            text: 'flutter-template/components/profile/detail/ios-26-experimental-preview/page-content',
            rows: 1,
            contentPosition: AppTextEllipsisContentPosition.middle,
          ),
        ),
        SizedBox(height: 14),
        _DemoSection(
          title: '头部省略',
          subtitle: '适合展示末尾更重要的信息，比如完整路径末级或版本后缀。',
          child: AppTextEllipsis(
            text: 'https://assets.example.com/static/campaign/summer-2026/final-landing-mobile-banner.png',
            rows: 1,
            contentPosition: AppTextEllipsisContentPosition.start,
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
      '支持 rows、展开收起文案、自定义省略号和 start / middle / end 三种截断位置。',
      '适合摘要、路径、资源地址、订单号和简介等长度不稳定的文案展示。',
      'demo 里覆盖基础多行、头部省略和中间省略三类高频场景。',
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

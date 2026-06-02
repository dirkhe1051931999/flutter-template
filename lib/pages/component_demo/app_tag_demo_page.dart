import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_tag/app_tag_types.dart';
import 'package:oolaf_flutted/components/app_tag/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class AppTagDemoPage extends StatelessWidget {
  const AppTagDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Tag，补齐类型、空心、圆角、标记和可关闭等常用能力。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        const _DemoSection(
          title: '基础用法',
          subtitle: '支持 default / primary / success / warning / danger。',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppTag(text: 'Default'),
              AppTag(text: 'Primary', type: AppTagType.primary),
              AppTag(text: 'Success', type: AppTagType.success),
              AppTag(text: 'Warning', type: AppTagType.warning),
              AppTag(text: 'Danger', type: AppTagType.danger),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '样式变体',
          subtitle: '支持 plain、round、mark、large、closeable。',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              const AppTag(
                text: 'Plain',
                type: AppTagType.primary,
                plain: true,
              ),
              const AppTag(
                text: 'Round',
                type: AppTagType.success,
                round: true,
              ),
              const AppTag(
                text: 'Mark',
                type: AppTagType.warning,
                mark: true,
              ),
              const AppTag(
                text: 'Large',
                type: AppTagType.danger,
                size: AppTagSize.large,
              ),
              AppTag(
                text: 'Closeable',
                type: AppTagType.primary,
                closeable: true,
                onClose: () => AppToast.showText('tag close'),
              ),
            ],
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
      '支持类型、空心、圆角、标记、尺寸和可关闭。',
      '适合状态标签、活动角标、筛选条件和库存/优惠说明。',
      'demo 里覆盖了最常用的样式变体。',
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

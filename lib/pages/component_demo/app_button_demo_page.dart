import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_button/app_button_types.dart';
import 'package:oolaf_flutted/components/app_button/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class AppButtonDemoPage extends StatelessWidget {
  const AppButtonDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Button，统一基础示例页里的触发按钮样式与参数模型。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础示例',
          subtitle: '支持 type、size、plain、loading、disabled、round、block。',
          child: Column(
            children: [
              AppButton(
                block: true,
                onPressed: () => AppToast.showText('primary'),
                child: const Text('Primary Button'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      type: AppButtonType.success,
                      onPressed: () => AppToast.showText('success'),
                      child: const Text('Success'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      type: AppButtonType.warning,
                      onPressed: () => AppToast.showText('warning'),
                      child: const Text('Warning'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      type: AppButtonType.danger,
                      plain: true,
                      onPressed: () => AppToast.showText('danger plain'),
                      child: const Text('Danger Plain'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      type: AppButtonType.primary,
                      loading: true,
                      onPressed: () {},
                      child: const Text('Loading'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  AppButton(
                    size: AppButtonSize.small,
                    round: true,
                    onPressed: () => AppToast.showText('small'),
                    child: const Text('Small'),
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    size: AppButtonSize.mini,
                    type: AppButtonType.defaultType,
                    plain: true,
                    onPressed: () => AppToast.showText('mini'),
                    child: const Text('Mini'),
                  ),
                ],
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
      '支持 default/primary/success/warning/danger、large/normal/small/mini。',
      '支持 plain、round、square、loading、disabled、block，足够覆盖基础示例页触发按钮。',
      '目标是统一 demo 区域按钮视觉，而不是替换导航、分段控件或系统开关。',
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

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_steps/app_steps_types.dart';
import 'package:oolaf_flutted/components/app_steps/index.dart';

class AppStepsDemoPage extends StatefulWidget {
  const AppStepsDemoPage({super.key});

  @override
  State<AppStepsDemoPage> createState() => _AppStepsDemoPageState();
}

class _AppStepsDemoPageState extends State<AppStepsDemoPage> {
  int _active = 1;

  static const steps = [
    AppStepItem(title: '下单', description: '创建订单'),
    AppStepItem(title: '支付', description: '支付成功'),
    AppStepItem(title: '发货', description: '商家出库'),
    AppStepItem(title: '完成', description: '交易完成'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Steps，支持横向和纵向步骤流，适合订单、流程、引导场景。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '横向步骤条',
          subtitle: '支持 active 状态切换，适合订单进度和流程导航。',
          child: Column(
            children: [
              AppSteps(
                steps: steps,
                active: _active,
              ),
              const SizedBox(height: 14),
              CupertinoSlidingSegmentedControl<int>(
                groupValue: _active,
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('0'),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('1'),
                  ),
                  2: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('2'),
                  ),
                  3: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('3'),
                  ),
                },
                onValueChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _active = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _DemoSection(
          title: '纵向步骤条',
          subtitle: '适合展示配送流、审批流或教学步骤。',
          child: AppSteps(
            steps: steps,
            active: 2,
            direction: AppStepsDirection.vertical,
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
      '支持 horizontal / vertical、active、finish / process / waiting。',
      '适合订单进度、流程导航、审批流和 onboarding。',
      'demo 里同时覆盖横向和纵向两种高频场景。',
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

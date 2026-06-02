import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_radio/app_radio_types.dart';
import 'package:oolaf_flutted/components/app_radio/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class AppRadioDemoPage extends StatefulWidget {
  const AppRadioDemoPage({super.key});

  @override
  State<AppRadioDemoPage> createState() => _AppRadioDemoPageState();
}

class _AppRadioDemoPageState extends State<AppRadioDemoPage> {
  AppRadioShape _shape = AppRadioShape.round;
  AppRadioLabelPosition _labelPosition = AppRadioLabelPosition.right;
  String? _delivery = 'express';
  String? _theme = 'glass';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Radio / RadioGroup，保留单选语义并改成 iOS 风格。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础示例',
          subtitle: '支持 shape、label-position、checked-color、disabled 和 group 绑定。',
          child: Column(
            children: [
              CupertinoSlidingSegmentedControl<AppRadioShape>(
                groupValue: _shape,
                children: const {
                  AppRadioShape.round: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('round'),
                  ),
                  AppRadioShape.square: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('square'),
                  ),
                },
                onValueChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _shape = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              CupertinoSlidingSegmentedControl<AppRadioLabelPosition>(
                groupValue: _labelPosition,
                children: const {
                  AppRadioLabelPosition.right: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('right'),
                  ),
                  AppRadioLabelPosition.left: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('left'),
                  ),
                },
                onValueChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _labelPosition = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              AppRadioGroup<String>(
                value: _delivery,
                shape: _shape,
                labelPosition: _labelPosition,
                checkedColor: const Color(0xFF2563EB),
                onChanged: (value) {
                  setState(() {
                    _delivery = value;
                  });
                },
                children: const [
                  AppRadio<String>(
                    name: 'express',
                    title: '极速送达',
                    subtitle: '30 分钟内送达，适合即时场景',
                  ),
                  AppRadio<String>(
                    name: 'scheduled',
                    title: '预约配送',
                    subtitle: '可选择上午、下午或晚间时段',
                  ),
                  AppRadio<String>(
                    name: 'pickup',
                    title: '到店自取',
                    subtitle: '适合咖啡、面包和轻量订单',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: 'Example',
          subtitle: '一个更偏视觉主题选择的单选示例，适合作为设置页入口。',
          child: AppRadioGroup<String>(
            value: _theme,
            direction: AppRadioDirection.horizontal,
            checkedColor: const Color(0xFF0EA5E9),
            onChanged: (value) {
              setState(() {
                _theme = value;
              });
              AppToast.showText('主题切换为 $value');
            },
            children: const [
              SizedBox(
                width: 150,
                child: AppRadio<String>(
                  name: 'glass',
                  title: 'Glass',
                  subtitle: '浅玻璃与薄阴影',
                ),
              ),
              SizedBox(
                width: 150,
                child: AppRadio<String>(
                  name: 'plain',
                  title: 'Plain',
                  subtitle: '更克制、更轻量',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '当前状态',
          subtitle: '页面只维护选中的 value，符合 RadioGroup 的单值心智模型。',
          child: _ResultCard(
            delivery: _delivery,
            theme: _theme,
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
      '支持单项和 RadioGroup 两种模式，group 通过单值 value 统一控制。',
      '支持 round / square、left / right、checkedColor、disabled 和横竖布局。',
      '视觉上用柔和外圈和内点反馈，保持单选控件更接近 iOS 的轻量质感。',
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

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.delivery,
    required this.theme,
  });

  final String? delivery;
  final String? theme;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('delivery', delivery ?? '-'),
      ('theme', theme ?? '-'),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          children: rows
              .map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          row.$1,
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          row.$2,
                          style: const TextStyle(
                            color: Color(0xFF202127),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

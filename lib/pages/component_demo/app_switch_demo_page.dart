import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_switch/index.dart';

class AppSwitchDemoPage extends StatefulWidget {
  const AppSwitchDemoPage({super.key});

  @override
  State<AppSwitchDemoPage> createState() => _AppSwitchDemoPageState();
}

class _AppSwitchDemoPageState extends State<AppSwitchDemoPage> {
  bool _value = true;
  bool _loading = false;
  bool _disabled = false;
  double _size = 30;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Switch，基于 CupertinoSwitch 做了参数层和状态层封装。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础示例',
          subtitle: '支持 active/inactive、disabled、loading、size 等常见参数。',
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '消息提醒',
                      style: TextStyle(
                        color: Color(0xFF202127),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AppSwitch(
                    value: _value,
                    loading: _loading,
                    disabled: _disabled,
                    size: _size,
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SwitchRow(
                label: 'loading',
                value: _loading,
                onChanged: (value) {
                  setState(() {
                    _loading = value;
                  });
                },
              ),
              _SwitchRow(
                label: 'disabled',
                value: _disabled,
                onChanged: (value) {
                  setState(() {
                    _disabled = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              CupertinoSlidingSegmentedControl<double>(
                groupValue: _size,
                children: {
                  26: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('26'),
                  ),
                  30: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('30'),
                  ),
                  36: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('36'),
                  ),
                },
                onValueChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _size = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: 'Example',
          subtitle: '偏设置页的信息开关布局，适合系统设置、通知设置、隐私偏好。',
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Activities',
                          style: TextStyle(
                            color: Color(0xFF202127),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '在锁屏和灵动岛持续显示实时动态',
                          style: TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSwitch(
                    value: _value,
                    activeColor: const Color(0xFF0EA5E9),
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                      });
                    },
                  ),
                ],
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
      '支持 value、size、loading、disabled、activeColor、inactiveColor 等高频参数。',
      '依然走 CupertinoSwitch 的原生交互，但补上 Vant 风格的状态模型与 demo 结构。',
      '适合作为设置页、通知页、隐私页里的轻量开关组件。',
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

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

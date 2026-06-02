import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_checkbox/app_checkbox_types.dart';
import 'package:oolaf_flutted/components/app_checkbox/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class AppCheckboxDemoPage extends StatefulWidget {
  const AppCheckboxDemoPage({super.key});

  @override
  State<AppCheckboxDemoPage> createState() => _AppCheckboxDemoPageState();
}

class _AppCheckboxDemoPageState extends State<AppCheckboxDemoPage> {
  bool _singleChecked = true;
  AppCheckShape _shape = AppCheckShape.round;
  AppCheckLabelPosition _labelPosition = AppCheckLabelPosition.right;
  List<String> _selectedTags = ['swift'];
  List<String> _limitedTags = ['news'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Checkbox，提供单项与 group 两种用法，视觉上偏 iOS 26。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础示例',
          subtitle: '支持 shape、label-position、checked-color、disabled、group 绑定。',
          child: Column(
            children: [
              AppCheckbox<String>(
                name: 'single',
                value: _singleChecked,
                shape: _shape,
                labelPosition: _labelPosition,
                title: '接收推送通知',
                subtitle: '单项模式下通过 value + onChanged 控制',
                onChanged: (value) {
                  setState(() {
                    _singleChecked = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              CupertinoSlidingSegmentedControl<AppCheckShape>(
                groupValue: _shape,
                children: const {
                  AppCheckShape.round: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('round'),
                  ),
                  AppCheckShape.square: Padding(
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
              CupertinoSlidingSegmentedControl<AppCheckLabelPosition>(
                groupValue: _labelPosition,
                children: const {
                  AppCheckLabelPosition.right: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('right'),
                  ),
                  AppCheckLabelPosition.left: Padding(
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
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: 'Group 示例',
          subtitle: '类似 Vant CheckboxGroup，页面只维护结构化选中数组。',
          child: AppCheckboxGroup<String>(
            values: _selectedTags,
            shape: _shape,
            labelPosition: _labelPosition,
            checkedColor: const Color(0xFF0EA5E9),
            onChanged: (values) {
              setState(() {
                _selectedTags = values;
              });
            },
            children: const [
              AppCheckbox<String>(
                name: 'swift',
                title: 'SwiftUI',
                subtitle: '更偏 Apple 平台生态',
              ),
              AppCheckbox<String>(
                name: 'design',
                title: 'Design System',
                subtitle: '视觉语言、组件规范与交互一致性',
              ),
              AppCheckbox<String>(
                name: 'live',
                title: 'Live Activities',
                subtitle: '适合通知、赛事、外卖等动态场景',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '限制选择',
          subtitle: '支持 max，超过上限后不再继续勾选，交互上接近 Vant。',
          child: AppCheckboxGroup<String>(
            values: _limitedTags,
            max: 2,
            shape: AppCheckShape.square,
            checkedColor: const Color(0xFF7C3AED),
            onChanged: (values) {
              setState(() {
                _limitedTags = values;
              });
              AppToast.showText('已选择 ${values.length}/2');
            },
            children: const [
              AppCheckbox<String>(name: 'news', title: '新闻'),
              AppCheckbox<String>(name: 'sports', title: '体育'),
              AppCheckbox<String>(name: 'music', title: '音乐'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '当前状态',
          subtitle: '方便直接观察单项、group 和 max 选择结果。',
          child: _ResultCard(
            singleChecked: _singleChecked,
            selectedTags: _selectedTags,
            limitedTags: _limitedTags,
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
      '支持单项和 group 两种模式，group 通过 name + values 进行勾选管理。',
      '支持 round / square、left / right、checkedColor、disabled、max 等常见参数。',
      '默认采用轻玻璃感卡片和柔和高亮，更接近 iOS 而不是 Material 勾选框。',
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
    required this.singleChecked,
    required this.selectedTags,
    required this.limitedTags,
  });

  final bool singleChecked;
  final List<String> selectedTags;
  final List<String> limitedTags;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('single', '$singleChecked'),
      ('group', selectedTags.join(', ')),
      ('max=2', limitedTags.join(', ')),
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
                          row.$2.isEmpty ? '-' : row.$2,
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

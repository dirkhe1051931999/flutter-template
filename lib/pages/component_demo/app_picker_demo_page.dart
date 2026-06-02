import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_picker/app_picker_types.dart';
import 'package:oolaf_flutted/components/app_picker/index.dart';

class AppPickerDemoPage extends StatefulWidget {
  const AppPickerDemoPage({super.key});

  @override
  State<AppPickerDemoPage> createState() => _AppPickerDemoPageState();
}

class _AppPickerDemoPageState extends State<AppPickerDemoPage> {
  AppPickerMode _mode = AppPickerMode.single;
  AppPickerResult _result = const AppPickerResult(
    values: <String>[],
    texts: <String>[],
  );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Picker，统一放在 App Sheet 内展示单列、多列和树形级联。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '模式切换',
          subtitle: 'single 对应单列，multiple 对应多列并列，cascade 对应树形联动。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoSlidingSegmentedControl<AppPickerMode>(
                groupValue: _mode,
                children: const {
                  AppPickerMode.single: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text('single'),
                  ),
                  AppPickerMode.multiple: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text('multiple'),
                  ),
                  AppPickerMode.cascade: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text('cascade'),
                  ),
                },
                onValueChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _mode = value;
                    _result = const AppPickerResult(
                      values: <String>[],
                      texts: <String>[],
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              _ActionButton(
                label: '打开 Picker',
                onPressed: _openPicker,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '结果展示',
          subtitle: '返回结构化的 values 和 texts，页面只消费强类型结果。',
          child: _ResultCard(
            mode: _mode,
            result: _result,
          ),
        ),
      ],
    );
  }

  Future<void> _openPicker() async {
    final result = await switch (_mode) {
      AppPickerMode.single => showAppPickerSheet(
          context: context,
          title: '单列选择',
          mode: AppPickerMode.single,
          options: _singleOptions,
          initialValues: _result.values,
        ),
      AppPickerMode.multiple => showAppPickerSheet(
          context: context,
          title: '多列选择',
          mode: AppPickerMode.multiple,
          columns: _multipleColumns,
          initialValues: _result.values,
        ),
      AppPickerMode.cascade => showAppPickerSheet(
          context: context,
          title: '树形级联',
          mode: AppPickerMode.cascade,
          cascadeOptions: _cascadeOptions,
          initialValues: _result.values,
        ),
    };

    if (result == null) {
      return;
    }
    setState(() {
      _result = result;
    });
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
      '单列模式适合一组枚举值，例如状态、性别、排序方式。',
      '多列模式适合并列维度组合，例如日期片段、库存规格或筛选条件。',
      '树形级联模式按父子关系逐级展开，行为对齐 Vant 的 cascade。',
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(
      padding: const EdgeInsets.symmetric(vertical: 14),
      borderRadius: BorderRadius.circular(18),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.mode,
    required this.result,
  });

  final AppPickerMode mode;
  final AppPickerResult result;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('模式', mode.name),
      ('文本', result.texts.isEmpty ? '-' : result.texts.join(' / ')),
      ('值', result.values.isEmpty ? '-' : result.values.join(' / ')),
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
                        width: 56,
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
                            height: 1.4,
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

const _singleOptions = <AppPickerOption>[
  AppPickerOption(text: '杭州', value: 'hangzhou'),
  AppPickerOption(text: '宁波', value: 'ningbo'),
  AppPickerOption(text: '温州', value: 'wenzhou'),
  AppPickerOption(text: '嘉兴', value: 'jiaxing'),
];

const _multipleColumns = <AppPickerColumn>[
  AppPickerColumn(
    key: '年份',
    options: [
      AppPickerOption(text: '2024', value: '2024'),
      AppPickerOption(text: '2025', value: '2025'),
      AppPickerOption(text: '2026', value: '2026'),
    ],
  ),
  AppPickerColumn(
    key: '季度',
    options: [
      AppPickerOption(text: 'Q1', value: 'q1'),
      AppPickerOption(text: 'Q2', value: 'q2'),
      AppPickerOption(text: 'Q3', value: 'q3'),
      AppPickerOption(text: 'Q4', value: 'q4'),
    ],
  ),
  AppPickerColumn(
    key: '状态',
    options: [
      AppPickerOption(text: '预售', value: 'presale'),
      AppPickerOption(text: '在售', value: 'onsale'),
      AppPickerOption(text: '售罄', value: 'soldout'),
    ],
  ),
];

const _cascadeOptions = <AppPickerOption>[
  AppPickerOption(
    text: '浙江',
    value: 'zhejiang',
    children: [
      AppPickerOption(
        text: '杭州',
        value: 'hangzhou',
        children: [
          AppPickerOption(text: '西湖区', value: 'xihu'),
          AppPickerOption(text: '滨江区', value: 'binjiang'),
          AppPickerOption(text: '余杭区', value: 'yuhang'),
        ],
      ),
      AppPickerOption(
        text: '宁波',
        value: 'ningbo',
        children: [
          AppPickerOption(text: '海曙区', value: 'haishu'),
          AppPickerOption(text: '鄞州区', value: 'yinzhou'),
        ],
      ),
    ],
  ),
  AppPickerOption(
    text: '江苏',
    value: 'jiangsu',
    children: [
      AppPickerOption(
        text: '南京',
        value: 'nanjing',
        children: [
          AppPickerOption(text: '鼓楼区', value: 'gulou'),
          AppPickerOption(text: '建邺区', value: 'jianye'),
        ],
      ),
      AppPickerOption(
        text: '苏州',
        value: 'suzhou',
        children: [
          AppPickerOption(text: '工业园区', value: 'sip'),
          AppPickerOption(text: '姑苏区', value: 'gusu'),
        ],
      ),
    ],
  ),
];

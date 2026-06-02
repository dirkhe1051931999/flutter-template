import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_date_picker/app_date_picker_types.dart';
import 'package:oolaf_flutted/components/app_date_picker/app_date_picker_utils.dart';
import 'package:oolaf_flutted/components/app_date_picker/index.dart';

class AppDatePickerDemoPage extends StatefulWidget {
  const AppDatePickerDemoPage({super.key});

  @override
  State<AppDatePickerDemoPage> createState() => _AppDatePickerDemoPageState();
}

class _AppDatePickerDemoPageState extends State<AppDatePickerDemoPage> {
  List<AppDatePickerColumnType> _columnsType = const [
    AppDatePickerColumnType.year,
    AppDatePickerColumnType.month,
  ];
  AppDatePickerValue _value = const AppDatePickerValue();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant DatePicker，当前版本固定放在 App Sheet 内展示。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '列组合',
          subtitle: '支持 year、month、year-month、month-day 四种常用组合。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SegmentTitle(label: 'columnsType'),
              const SizedBox(height: 10),
              CupertinoSlidingSegmentedControl<String>(
                groupValue: _columnsKey,
                children: const {
                  'year': Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text('year'),
                  ),
                  'month': Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text('month'),
                  ),
                  'year-month': Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text('year-month'),
                  ),
                  'month-day': Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text('month-day'),
                  ),
                },
                onValueChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _columnsType = _columnsForKey(value);
                    _value = const AppDatePickerValue();
                  });
                },
              ),
              const SizedBox(height: 16),
              _ActionButton(
                label: '打开日期选择',
                onPressed: () async {
                  final result = await showAppDatePickerSheet(
                    context: context,
                    title: 'App Date Picker',
                    columnsType: _columnsType,
                    initialValue: _value,
                    minYear: 2000,
                    maxYear: 2035,
                  );
                  if (result == null) {
                    return;
                  }
                  setState(() {
                    _value = result;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '结果展示',
          subtitle: '根据列类型返回结构化的 year / month / day 值。',
          child: _ResultCard(
            columnsType: _columnsType,
            value: _value,
          ),
        ),
      ],
    );
  }

  String get _columnsKey {
    if (_columnsType.length == 1 &&
        _columnsType.first == AppDatePickerColumnType.year) {
      return 'year';
    }
    if (_columnsType.length == 1 &&
        _columnsType.first == AppDatePickerColumnType.month) {
      return 'month';
    }
    if (_columnsType.length == 2 &&
        _columnsType[0] == AppDatePickerColumnType.year &&
        _columnsType[1] == AppDatePickerColumnType.month) {
      return 'year-month';
    }
    return 'month-day';
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
      '组件固定运行在 App Sheet 内，使用列滚动选择交互。',
      '支持 `year`、`month`、`year-month`、`month-day` 四种列组合。',
      '返回结构化的 `AppDatePickerValue`，而不是原始字符串。',
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

class _SegmentTitle extends StatelessWidget {
  const _SegmentTitle({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF667085),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
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
    required this.columnsType,
    required this.value,
  });

  final List<AppDatePickerColumnType> columnsType;
  final AppDatePickerValue value;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('列类型', columnsType.map((item) => item.name).join(' / ')),
      ('结果', AppDatePickerUtils.summaryText(columnsType, value)),
      ('year', value.year?.toString() ?? '-'),
      ('month', value.month?.toString() ?? '-'),
      ('day', value.day?.toString() ?? '-'),
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
                        width: 64,
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

List<AppDatePickerColumnType> _columnsForKey(String key) {
  return switch (key) {
    'year' => const [AppDatePickerColumnType.year],
    'month' => const [AppDatePickerColumnType.month],
    'year-month' => const [
        AppDatePickerColumnType.year,
        AppDatePickerColumnType.month,
      ],
    _ => const [
        AppDatePickerColumnType.month,
        AppDatePickerColumnType.day,
      ],
  };
}

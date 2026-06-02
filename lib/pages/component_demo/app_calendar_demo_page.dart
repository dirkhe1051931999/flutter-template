import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_calendar/app_calendar_types.dart';
import 'package:oolaf_flutted/components/app_calendar/app_calendar_utils.dart';
import 'package:oolaf_flutted/components/app_calendar/index.dart';

class AppCalendarDemoPage extends StatefulWidget {
  const AppCalendarDemoPage({super.key});

  @override
  State<AppCalendarDemoPage> createState() => _AppCalendarDemoPageState();
}

class _AppCalendarDemoPageState extends State<AppCalendarDemoPage> {
  AppCalendarSelectionMode _selectionMode = AppCalendarSelectionMode.single;
  AppCalendarSwitchMode _switchMode = AppCalendarSwitchMode.none;
  AppCalendarSelection _selection = const AppCalendarSelection();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Calendar，当前版本固定放在 App Sheet 内展示。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '模式切换',
          subtitle:
              '支持 single / multiple / range，以及 none / month / year-month。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SegmentTitle(label: '选择模式'),
              const SizedBox(height: 10),
              CupertinoSlidingSegmentedControl<AppCalendarSelectionMode>(
                groupValue: _selectionMode,
                children: const {
                  AppCalendarSelectionMode.single: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('single'),
                  ),
                  AppCalendarSelectionMode.multiple: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('multiple'),
                  ),
                  AppCalendarSelectionMode.range: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('range'),
                  ),
                },
                onValueChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectionMode = value;
                    _selection = const AppCalendarSelection();
                  });
                },
              ),
              const SizedBox(height: 16),
              const _SegmentTitle(label: '切换模式'),
              const SizedBox(height: 10),
              CupertinoSlidingSegmentedControl<AppCalendarSwitchMode>(
                groupValue: _switchMode,
                children: const {
                  AppCalendarSwitchMode.none: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('none'),
                  ),
                  AppCalendarSwitchMode.month: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('month'),
                  ),
                  AppCalendarSwitchMode.yearMonth: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('year-month'),
                  ),
                },
                onValueChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _switchMode = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _ActionButton(
                label: '打开日历',
                onPressed: () async {
                  final result = await showAppCalendarSheet(
                    context: context,
                    title: 'App Calendar',
                    selectionMode: _selectionMode,
                    switchMode: _switchMode,
                    initialSelection: _selection,
                    minDate: DateTime(2026, 1, 1),
                    maxDate: DateTime(2026, 12, 31),
                  );
                  if (result == null) {
                    return;
                  }
                  setState(() {
                    _selection = result;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '结果展示',
          subtitle: '返回值按模式区分，页面层只消费结构化结果。',
          child: _ResultCard(
            selectionMode: _selectionMode,
            switchMode: _switchMode,
            selection: _selection,
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
      '组件固定运行在 App Sheet 内，视觉和交互动线与现有弹层保持一致。',
      '支持 single、multiple、range 三种选择模式。',
      '支持 none、month、year-month 三种月份切换模式。',
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
    required this.selectionMode,
    required this.switchMode,
    required this.selection,
  });

  final AppCalendarSelectionMode selectionMode;
  final AppCalendarSwitchMode switchMode;
  final AppCalendarSelection selection;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('选择模式', selectionMode.name),
      ('切换模式', switchMode.name),
      ('结果', _selectionText()),
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

  String _selectionText() {
    return switch (selectionMode) {
      AppCalendarSelectionMode.single => selection.singleDate == null
          ? '-'
          : AppCalendarUtils.formatDayLabel(selection.singleDate!),
      AppCalendarSelectionMode.multiple => selection.multipleDates.isEmpty
          ? '-'
          : selection.multipleDates
              .map(AppCalendarUtils.formatDayLabel)
              .join('、'),
      AppCalendarSelectionMode.range => selection.rangeStart == null &&
              selection.rangeEnd == null
          ? '-'
          : selection.rangeStart != null && selection.rangeEnd != null
              ? '${AppCalendarUtils.formatDayLabel(selection.rangeStart!)} - ${AppCalendarUtils.formatDayLabel(selection.rangeEnd!)}'
              : '${AppCalendarUtils.formatDayLabel(selection.rangeStart!)} - 待选择',
    };
  }
}

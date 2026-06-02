import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_calendar/app_calendar_types.dart';
import 'package:oolaf_flutted/components/app_calendar/app_calendar_utils.dart';

class AppCalendarPreviewCard extends StatelessWidget {
  const AppCalendarPreviewCard({
    super.key,
    required this.selectionMode,
    required this.selection,
  });

  final AppCalendarSelectionMode selectionMode;
  final AppCalendarSelection selection;

  @override
  Widget build(BuildContext context) {
    final summary = _summaryText();
    final chips = _buildChips();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFDFEFF),
            Color(0xFFF2F6FF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前选择',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips
                  .map((item) => _PreviewChip(label: item))
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }

  String _summaryText() {
    return switch (selectionMode) {
      AppCalendarSelectionMode.single => selection.singleDate == null
          ? '请选择一个日期'
          : AppCalendarUtils.formatDayLabel(selection.singleDate!),
      AppCalendarSelectionMode.multiple => selection.multipleDates.isEmpty
          ? '请选择多个日期'
          : '已选 ${selection.multipleDates.length} 天',
      AppCalendarSelectionMode.range => selection.rangeStart == null &&
              selection.rangeEnd == null
          ? '请选择日期区间'
          : selection.rangeStart != null && selection.rangeEnd != null
              ? '${AppCalendarUtils.formatDayLabel(selection.rangeStart!)} - ${AppCalendarUtils.formatDayLabel(selection.rangeEnd!)}'
              : '${AppCalendarUtils.formatDayLabel(selection.rangeStart!)} - 待选择',
    };
  }

  List<String> _buildChips() {
    return switch (selectionMode) {
      AppCalendarSelectionMode.single => [
          selection.singleDate == null
              ? '单选'
              : AppCalendarUtils.formatDayLabel(selection.singleDate!),
        ],
      AppCalendarSelectionMode.multiple => selection.multipleDates.isEmpty
          ? ['多选', '支持点选切换']
          : selection.multipleDates
              .take(4)
              .map(AppCalendarUtils.formatDayLabel)
              .toList(growable: false),
      AppCalendarSelectionMode.range => [
          if (selection.rangeStart != null)
            AppCalendarUtils.formatDayLabel(selection.rangeStart!),
          if (selection.rangeEnd != null)
            AppCalendarUtils.formatDayLabel(selection.rangeEnd!),
          if (selection.rangeStart == null && selection.rangeEnd == null) '区间',
        ],
    };
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x15000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475467),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

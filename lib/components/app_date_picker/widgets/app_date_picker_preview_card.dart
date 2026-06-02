import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_date_picker/app_date_picker_types.dart';
import 'package:oolaf_flutted/components/app_date_picker/app_date_picker_utils.dart';

class AppDatePickerPreviewCard extends StatelessWidget {
  const AppDatePickerPreviewCard({
    super.key,
    required this.columnsType,
    required this.value,
  });

  final List<AppDatePickerColumnType> columnsType;
  final AppDatePickerValue value;

  @override
  Widget build(BuildContext context) {
    final summary = AppDatePickerUtils.summaryText(columnsType, value);
    final chips = columnsType
        .map(
          (type) => switch (type) {
            AppDatePickerColumnType.year =>
              value.year == null ? '年份' : '${value.year}年',
            AppDatePickerColumnType.month =>
              value.month == null ? '月份' : '${value.month}月',
            AppDatePickerColumnType.day =>
              value.day == null ? '日期' : '${value.day}日',
          },
        )
        .toList(growable: false);

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

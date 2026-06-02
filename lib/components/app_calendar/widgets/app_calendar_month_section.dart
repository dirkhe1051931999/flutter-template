import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_calendar/app_calendar_types.dart';
import 'package:oolaf_flutted/components/app_calendar/app_calendar_utils.dart';

class AppCalendarMonthSection extends StatelessWidget {
  const AppCalendarMonthSection({
    super.key,
    required this.month,
    required this.selectionMode,
    required this.selection,
    required this.minDate,
    required this.maxDate,
    required this.onDayTap,
    this.showMonthLabel = true,
  });

  final DateTime month;
  final AppCalendarSelectionMode selectionMode;
  final AppCalendarSelection selection;
  final DateTime minDate;
  final DateTime maxDate;
  final ValueChanged<DateTime> onDayTap;
  final bool showMonthLabel;

  @override
  Widget build(BuildContext context) {
    final days = _buildCells();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xB8FFFFFF),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showMonthLabel) ...[
              Text(
                AppCalendarUtils.formatMonthLabel(month),
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
            ],
            const _WeekdayRow(),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 6,
                mainAxisSpacing: 8,
                childAspectRatio: 0.86,
              ),
              itemBuilder: (context, index) {
                final date = days[index];
                if (date == null) {
                  return const SizedBox.shrink();
                }

                final safeDate = AppCalendarUtils.dateOnly(date);
                final isDisabled =
                    AppCalendarUtils.isBeforeDay(safeDate, minDate) ||
                        AppCalendarUtils.isAfterDay(safeDate, maxDate);
                final isToday =
                    AppCalendarUtils.isSameDay(safeDate, DateTime.now());
                final isSelected = _isSelected(safeDate);
                final isRangeEdge = _isRangeEdge(safeDate);
                final isInRange = _isInRange(safeDate);

                final backgroundColor =
                    switch ((isSelected, isRangeEdge, isInRange)) {
                  (true, _, _) => const Color(0xFF111827),
                  (_, true, _) => const Color(0xFF111827),
                  (_, _, true) => const Color(0xFFE5EEFF),
                  _ => const Color(0xFFF7F8FC),
                };

                final textColor = isDisabled
                    ? const Color(0xFFCBD2DD)
                    : (isSelected || isRangeEdge)
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF111827);

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: isDisabled ? null : () => onDayTap(safeDate),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(
                        isRangeEdge ? 18 : 16,
                      ),
                      border: isToday && !isSelected && !isRangeEdge
                          ? Border.all(color: const Color(0xFF93C5FD))
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${safeDate.day}',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: isSelected || isRangeEdge || isToday
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isToday ? '今天' : '',
                          style: TextStyle(
                            color: textColor.withValues(
                              alpha: isToday ? 1 : 0,
                            ),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime?> _buildCells() {
    final firstDay = DateTime(month.year, month.month, 1);
    final startWeekday = firstDay.weekday % 7;
    final totalDays = DateTime(month.year, month.month + 1, 0).day;
    final result = List<DateTime?>.filled(startWeekday, null, growable: true);

    for (var day = 1; day <= totalDays; day++) {
      result.add(DateTime(month.year, month.month, day));
    }
    return result;
  }

  bool _isSelected(DateTime value) {
    return switch (selectionMode) {
      AppCalendarSelectionMode.single =>
        AppCalendarUtils.isSameDay(selection.singleDate, value),
      AppCalendarSelectionMode.multiple => selection.multipleDates
          .any((item) => AppCalendarUtils.isSameDay(item, value)),
      AppCalendarSelectionMode.range => false,
    };
  }

  bool _isRangeEdge(DateTime value) {
    if (selectionMode != AppCalendarSelectionMode.range) {
      return false;
    }
    return AppCalendarUtils.isSameDay(selection.rangeStart, value) ||
        AppCalendarUtils.isSameDay(selection.rangeEnd, value);
  }

  bool _isInRange(DateTime value) {
    if (selectionMode != AppCalendarSelectionMode.range ||
        selection.rangeStart == null ||
        selection.rangeEnd == null) {
      return false;
    }
    return AppCalendarUtils.isWithinRange(
      value,
      start: selection.rangeStart!,
      end: selection.rangeEnd!,
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    const labels = ['日', '一', '二', '三', '四', '五', '六'];
    return Row(
      children: labels
          .map(
            (item) => Expanded(
              child: Center(
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

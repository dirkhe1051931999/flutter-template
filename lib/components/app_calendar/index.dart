import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_calendar/app_calendar_types.dart';
import 'package:oolaf_flutted/components/app_calendar/app_calendar_utils.dart';
import 'package:oolaf_flutted/components/app_calendar/widgets/app_calendar_header.dart';
import 'package:oolaf_flutted/components/app_calendar/widgets/app_calendar_month_section.dart';
import 'package:oolaf_flutted/components/app_calendar/widgets/app_calendar_preview_card.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';

Future<AppCalendarSelection?> showAppCalendarSheet({
  required BuildContext context,
  required AppCalendarSelectionMode selectionMode,
  required AppCalendarSwitchMode switchMode,
  AppCalendarSelection initialSelection = const AppCalendarSelection(),
  DateTime? minDate,
  DateTime? maxDate,
  String title = '选择日期',
}) {
  final now = DateTime.now();
  final safeMinDate = AppCalendarUtils.dateOnly(
    minDate ?? DateTime(now.year, 1, 1),
  );
  final safeMaxDate = AppCalendarUtils.dateOnly(
    maxDate ?? DateTime(now.year, 12, 31),
  );

  return showAppSheet<AppCalendarSelection>(
    context: context,
    edgeToEdge: true,
    enableBlur: true,
    showHandle: false,
    backgroundColor: const Color(0xFFF4F7FD),
    maxHeightFactor: 0.88,
    builder: (_) {
      return AppCalendarSheet(
        title: title,
        selectionMode: selectionMode,
        switchMode: switchMode,
        initialSelection: initialSelection,
        minDate: safeMinDate,
        maxDate: safeMaxDate,
      );
    },
  );
}

class AppCalendarSheet extends StatefulWidget {
  const AppCalendarSheet({
    super.key,
    required this.title,
    required this.selectionMode,
    required this.switchMode,
    required this.initialSelection,
    required this.minDate,
    required this.maxDate,
  });

  final String title;
  final AppCalendarSelectionMode selectionMode;
  final AppCalendarSwitchMode switchMode;
  final AppCalendarSelection initialSelection;
  final DateTime minDate;
  final DateTime maxDate;

  @override
  State<AppCalendarSheet> createState() => _AppCalendarSheetState();
}

class _AppCalendarSheetState extends State<AppCalendarSheet> {
  late AppCalendarSelection _selection;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _selection = _normalizeSelection(widget.initialSelection);
    _visibleMonth = _initialVisibleMonth();
  }

  bool get _canConfirm {
    return switch (widget.selectionMode) {
      AppCalendarSelectionMode.single => _selection.singleDate != null,
      AppCalendarSelectionMode.multiple => _selection.multipleDates.isNotEmpty,
      AppCalendarSelectionMode.range =>
        _selection.rangeStart != null && _selection.rangeEnd != null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final months = AppCalendarUtils.buildMonths(
      minDate: widget.minDate,
      maxDate: widget.maxDate,
    );

    return Column(
      children: [
        Container(
          width: 42,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFD4DAE5),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 12),
        AppCalendarHeader(
          title: widget.title,
          subtitle: _headerSubtitle(),
          switchMode: widget.switchMode,
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: () => Navigator.of(context).pop(_selection),
          confirmEnabled: _canConfirm,
          onPreviousMonth: () => _shiftMonth(-1),
          onNextMonth: () => _shiftMonth(1),
          onPreviousYear: () => _shiftMonth(-12),
          onNextYear: () => _shiftMonth(12),
          canGoPreviousMonth: _canShiftMonth(-1),
          canGoNextMonth: _canShiftMonth(1),
          canGoPreviousYear: _canShiftMonth(-12),
          canGoNextYear: _canShiftMonth(12),
        ),
        const SizedBox(height: 16),
        AppCalendarPreviewCard(
          selectionMode: widget.selectionMode,
          selection: _selection,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: widget.switchMode == AppCalendarSwitchMode.none
              ? ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: months.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return AppCalendarMonthSection(
                      month: months[index],
                      selectionMode: widget.selectionMode,
                      selection: _selection,
                      minDate: widget.minDate,
                      maxDate: widget.maxDate,
                      onDayTap: _handleDayTap,
                    );
                  },
                )
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    AppCalendarMonthSection(
                      month: _visibleMonth,
                      selectionMode: widget.selectionMode,
                      selection: _selection,
                      minDate: widget.minDate,
                      maxDate: widget.maxDate,
                      onDayTap: _handleDayTap,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  String _headerSubtitle() {
    return switch (widget.switchMode) {
      AppCalendarSwitchMode.none => '平铺展示所有月份',
      AppCalendarSwitchMode.month =>
        '按月切换 ${AppCalendarUtils.formatMonthLabel(_visibleMonth)}',
      AppCalendarSwitchMode.yearMonth =>
        '按年按月切换 ${AppCalendarUtils.formatMonthLabel(_visibleMonth)}',
    };
  }

  AppCalendarSelection _normalizeSelection(AppCalendarSelection selection) {
    return AppCalendarSelection(
      singleDate: selection.singleDate == null
          ? null
          : AppCalendarUtils.dateOnly(selection.singleDate!),
      multipleDates: selection.multipleDates
          .map(AppCalendarUtils.dateOnly)
          .where(_isSelectableDay)
          .toList(growable: false),
      rangeStart: selection.rangeStart == null
          ? null
          : AppCalendarUtils.dateOnly(selection.rangeStart!),
      rangeEnd: selection.rangeEnd == null
          ? null
          : AppCalendarUtils.dateOnly(selection.rangeEnd!),
    );
  }

  DateTime _initialVisibleMonth() {
    final focusDate = switch (widget.selectionMode) {
      AppCalendarSelectionMode.single =>
        _selection.singleDate ?? DateTime.now(),
      AppCalendarSelectionMode.multiple => _selection.multipleDates.isNotEmpty
          ? _selection.multipleDates.first
          : DateTime.now(),
      AppCalendarSelectionMode.range => _selection.rangeStart ?? DateTime.now(),
    };

    return AppCalendarUtils.clampMonth(
      focusDate,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
    );
  }

  bool _isSelectableDay(DateTime value) {
    return !AppCalendarUtils.isBeforeDay(value, widget.minDate) &&
        !AppCalendarUtils.isAfterDay(value, widget.maxDate);
  }

  void _shiftMonth(int offset) {
    final next = AppCalendarUtils.clampMonth(
      AppCalendarUtils.addMonths(_visibleMonth, offset),
      minDate: widget.minDate,
      maxDate: widget.maxDate,
    );
    if (AppCalendarUtils.isSameMonth(next, _visibleMonth)) {
      return;
    }
    setState(() {
      _visibleMonth = next;
    });
  }

  bool _canShiftMonth(int offset) {
    final next = AppCalendarUtils.addMonths(_visibleMonth, offset);
    final clamped = AppCalendarUtils.clampMonth(
      next,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
    );
    return !AppCalendarUtils.isSameMonth(clamped, _visibleMonth);
  }

  void _handleDayTap(DateTime value) {
    setState(() {
      _selection = switch (widget.selectionMode) {
        AppCalendarSelectionMode.single => AppCalendarSelection(
            singleDate: value,
          ),
        AppCalendarSelectionMode.multiple => _toggleMultipleDate(value),
        AppCalendarSelectionMode.range => _toggleRangeDate(value),
      };
    });
  }

  AppCalendarSelection _toggleMultipleDate(DateTime value) {
    final dates = [..._selection.multipleDates];
    final existingIndex = dates.indexWhere(
      (item) => AppCalendarUtils.isSameDay(item, value),
    );
    if (existingIndex >= 0) {
      dates.removeAt(existingIndex);
    } else {
      dates.add(value);
      dates.sort();
    }
    return AppCalendarSelection(multipleDates: dates);
  }

  AppCalendarSelection _toggleRangeDate(DateTime value) {
    final start = _selection.rangeStart;
    final end = _selection.rangeEnd;

    if (start == null || end != null) {
      return AppCalendarSelection(rangeStart: value);
    }

    if (AppCalendarUtils.isBeforeDay(value, start)) {
      return AppCalendarSelection(rangeStart: value);
    }

    return AppCalendarSelection(
      rangeStart: start,
      rangeEnd: value,
    );
  }
}

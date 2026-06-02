enum AppCalendarSelectionMode { single, multiple, range }

enum AppCalendarSwitchMode { none, month, yearMonth }

class AppCalendarSelection {
  const AppCalendarSelection({
    this.singleDate,
    this.multipleDates = const <DateTime>[],
    this.rangeStart,
    this.rangeEnd,
  });

  final DateTime? singleDate;
  final List<DateTime> multipleDates;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  bool get isEmpty =>
      singleDate == null &&
      multipleDates.isEmpty &&
      rangeStart == null &&
      rangeEnd == null;

  AppCalendarSelection copyWith({
    DateTime? singleDate,
    List<DateTime>? multipleDates,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    bool clearSingleDate = false,
    bool clearMultipleDates = false,
    bool clearRangeStart = false,
    bool clearRangeEnd = false,
  }) {
    return AppCalendarSelection(
      singleDate: clearSingleDate ? null : singleDate ?? this.singleDate,
      multipleDates: clearMultipleDates
          ? const <DateTime>[]
          : multipleDates ?? this.multipleDates,
      rangeStart: clearRangeStart ? null : rangeStart ?? this.rangeStart,
      rangeEnd: clearRangeEnd ? null : rangeEnd ?? this.rangeEnd,
    );
  }
}

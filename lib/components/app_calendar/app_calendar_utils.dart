import 'package:intl/intl.dart';

class AppCalendarUtils {
  AppCalendarUtils._();

  static DateTime dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static DateTime monthOnly(DateTime value) {
    return DateTime(value.year, value.month);
  }

  static DateTime addMonths(DateTime value, int months) {
    return DateTime(value.year, value.month + months, 1);
  }

  static DateTime clampMonth(
    DateTime value, {
    required DateTime minDate,
    required DateTime maxDate,
  }) {
    final month = monthOnly(value);
    final minMonth = monthOnly(minDate);
    final maxMonth = monthOnly(maxDate);

    if (month.isBefore(minMonth)) {
      return minMonth;
    }
    if (month.isAfter(maxMonth)) {
      return maxMonth;
    }
    return month;
  }

  static bool isSameDay(DateTime? left, DateTime? right) {
    if (left == null || right == null) {
      return false;
    }
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  static bool isSameMonth(DateTime left, DateTime right) {
    return left.year == right.year && left.month == right.month;
  }

  static bool isBeforeDay(DateTime left, DateTime right) {
    return dateOnly(left).isBefore(dateOnly(right));
  }

  static bool isAfterDay(DateTime left, DateTime right) {
    return dateOnly(left).isAfter(dateOnly(right));
  }

  static bool isWithinRange(
    DateTime target, {
    required DateTime start,
    required DateTime end,
  }) {
    final safeTarget = dateOnly(target);
    final safeStart = dateOnly(start);
    final safeEnd = dateOnly(end);
    return !safeTarget.isBefore(safeStart) && !safeTarget.isAfter(safeEnd);
  }

  static String formatMonthLabel(DateTime value) {
    return DateFormat('yyyy年MM月').format(value);
  }

  static String formatYearLabel(DateTime value) {
    return DateFormat('yyyy年').format(value);
  }

  static String formatDayLabel(DateTime value) {
    return DateFormat('MM月dd日').format(value);
  }

  static List<DateTime> buildMonths({
    required DateTime minDate,
    required DateTime maxDate,
  }) {
    final result = <DateTime>[];
    var cursor = monthOnly(minDate);
    final last = monthOnly(maxDate);
    while (!cursor.isAfter(last)) {
      result.add(cursor);
      cursor = addMonths(cursor, 1);
    }
    return result;
  }
}

import 'package:oolaf_flutted/components/app_date_picker/app_date_picker_types.dart';

class AppDatePickerUtils {
  AppDatePickerUtils._();

  static int daysInMonth({
    required int year,
    required int month,
  }) {
    return DateTime(year, month + 1, 0).day;
  }

  static String columnLabel(AppDatePickerColumnType type) {
    return switch (type) {
      AppDatePickerColumnType.year => '年份',
      AppDatePickerColumnType.month => '月份',
      AppDatePickerColumnType.day => '日期',
    };
  }

  static String itemLabel(AppDatePickerColumnType type, int value) {
    return switch (type) {
      AppDatePickerColumnType.year => '$value年',
      AppDatePickerColumnType.month => '$value月',
      AppDatePickerColumnType.day => '$value日',
    };
  }

  static String summaryText(
    List<AppDatePickerColumnType> columnsType,
    AppDatePickerValue value,
  ) {
    final items = <String>[];
    for (final type in columnsType) {
      switch (type) {
        case AppDatePickerColumnType.year:
          if (value.year != null) {
            items.add('${value.year}年');
          }
        case AppDatePickerColumnType.month:
          if (value.month != null) {
            items.add('${value.month}月');
          }
        case AppDatePickerColumnType.day:
          if (value.day != null) {
            items.add('${value.day}日');
          }
      }
    }
    return items.isEmpty ? '请选择日期' : items.join(' / ');
  }
}

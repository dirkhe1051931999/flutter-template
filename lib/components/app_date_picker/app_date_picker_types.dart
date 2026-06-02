enum AppDatePickerColumnType { year, month, day }

class AppDatePickerValue {
  const AppDatePickerValue({
    this.year,
    this.month,
    this.day,
  });

  final int? year;
  final int? month;
  final int? day;

  AppDatePickerValue copyWith({
    int? year,
    int? month,
    int? day,
    bool clearYear = false,
    bool clearMonth = false,
    bool clearDay = false,
  }) {
    return AppDatePickerValue(
      year: clearYear ? null : year ?? this.year,
      month: clearMonth ? null : month ?? this.month,
      day: clearDay ? null : day ?? this.day,
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_date_picker/app_date_picker_types.dart';
import 'package:oolaf_flutted/components/app_date_picker/app_date_picker_utils.dart';
import 'package:oolaf_flutted/components/app_date_picker/widgets/app_date_picker_column.dart';
import 'package:oolaf_flutted/components/app_date_picker/widgets/app_date_picker_header.dart';
import 'package:oolaf_flutted/components/app_date_picker/widgets/app_date_picker_preview_card.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';

Future<AppDatePickerValue?> showAppDatePickerSheet({
  required BuildContext context,
  required List<AppDatePickerColumnType> columnsType,
  AppDatePickerValue initialValue = const AppDatePickerValue(),
  int minYear = 2000,
  int maxYear = 2035,
  String title = '选择日期',
}) {
  return showAppSheet<AppDatePickerValue>(
    context: context,
    edgeToEdge: true,
    enableBlur: true,
    showHandle: false,
    backgroundColor: const Color(0xFFF4F7FD),
    maxHeightFactor: 0.76,
    builder: (_) {
      return AppDatePickerSheet(
        title: title,
        columnsType: columnsType,
        initialValue: initialValue,
        minYear: minYear,
        maxYear: maxYear,
      );
    },
  );
}

class AppDatePickerSheet extends StatefulWidget {
  const AppDatePickerSheet({
    super.key,
    required this.title,
    required this.columnsType,
    required this.initialValue,
    required this.minYear,
    required this.maxYear,
  });

  final String title;
  final List<AppDatePickerColumnType> columnsType;
  final AppDatePickerValue initialValue;
  final int minYear;
  final int maxYear;

  @override
  State<AppDatePickerSheet> createState() => _AppDatePickerSheetState();
}

class _AppDatePickerSheetState extends State<AppDatePickerSheet> {
  late AppDatePickerValue _value;

  @override
  void initState() {
    super.initState();
    _value = _normalizeValue(widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
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
        AppDatePickerHeader(
          title: widget.title,
          subtitle: _subtitle(),
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: () => Navigator.of(context).pop(_value),
        ),
        const SizedBox(height: 16),
        AppDatePickerPreviewCard(
          columnsType: widget.columnsType,
          value: _value,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0;
                  index < widget.columnsType.length;
                  index++) ...[
                if (index > 0) const SizedBox(width: 8),
                AppDatePickerColumn(
                  type: widget.columnsType[index],
                  values: _valuesFor(widget.columnsType[index]),
                  selectedValue: _selectedValueFor(widget.columnsType[index]),
                  onSelected: (value) =>
                      _handleSelected(widget.columnsType[index], value),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _subtitle() {
    final types = widget.columnsType.map((item) => item.name).join(' / ');
    return 'App Sheet 内日期选择器，当前列：$types';
  }

  AppDatePickerValue _normalizeValue(AppDatePickerValue value) {
    final now = DateTime.now();
    final hasYear = widget.columnsType.contains(AppDatePickerColumnType.year);
    final hasMonth = widget.columnsType.contains(AppDatePickerColumnType.month);
    final hasDay = widget.columnsType.contains(AppDatePickerColumnType.day);

    final year = hasYear
        ? (value.year ?? now.year).clamp(widget.minYear, widget.maxYear)
        : (value.year ?? now.year).clamp(widget.minYear, widget.maxYear);
    final month = hasMonth
        ? (value.month ?? now.month).clamp(1, 12)
        : (value.month ?? now.month).clamp(1, 12);
    final maxDays = AppDatePickerUtils.daysInMonth(year: year, month: month);
    final day = hasDay ? (value.day ?? now.day).clamp(1, maxDays) : null;

    return AppDatePickerValue(
      year: hasYear || hasDay ? year : null,
      month: hasMonth || hasDay ? month : null,
      day: day,
    );
  }

  List<int> _valuesFor(AppDatePickerColumnType type) {
    return switch (type) {
      AppDatePickerColumnType.year => [
          for (var year = widget.minYear; year <= widget.maxYear; year++) year,
        ],
      AppDatePickerColumnType.month => [
          for (var month = 1; month <= 12; month++) month,
        ],
      AppDatePickerColumnType.day => [
          for (var day = 1;
              day <=
                  AppDatePickerUtils.daysInMonth(
                    year: _value.year ?? DateTime.now().year,
                    month: _value.month ?? DateTime.now().month,
                  );
              day++)
            day,
        ],
    };
  }

  int _selectedValueFor(AppDatePickerColumnType type) {
    return switch (type) {
      AppDatePickerColumnType.year => _value.year ?? DateTime.now().year,
      AppDatePickerColumnType.month => _value.month ?? DateTime.now().month,
      AppDatePickerColumnType.day => _value.day ?? DateTime.now().day,
    };
  }

  void _handleSelected(AppDatePickerColumnType type, int value) {
    setState(() {
      switch (type) {
        case AppDatePickerColumnType.year:
          _value = _value.copyWith(year: value);
        case AppDatePickerColumnType.month:
          _value = _value.copyWith(month: value);
        case AppDatePickerColumnType.day:
          _value = _value.copyWith(day: value);
      }

      final maxDays = AppDatePickerUtils.daysInMonth(
        year: _value.year ?? DateTime.now().year,
        month: _value.month ?? DateTime.now().month,
      );
      if (_value.day != null && _value.day! > maxDays) {
        _value = _value.copyWith(day: maxDays);
      }
    });
  }
}

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_picker/app_picker_types.dart';
import 'package:oolaf_flutted/components/app_picker/widgets/app_picker_column.dart';
import 'package:oolaf_flutted/components/app_picker/widgets/app_picker_header.dart';
import 'package:oolaf_flutted/components/app_picker/widgets/app_picker_preview_card.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';

Future<AppPickerResult?> showAppPickerSheet({
  required BuildContext context,
  required String title,
  AppPickerMode mode = AppPickerMode.single,
  List<AppPickerOption> options = const <AppPickerOption>[],
  List<AppPickerColumn> columns = const <AppPickerColumn>[],
  List<AppPickerOption> cascadeOptions = const <AppPickerOption>[],
  List<String> initialValues = const <String>[],
}) {
  return showAppSheet<AppPickerResult>(
    context: context,
    edgeToEdge: true,
    enableBlur: true,
    showHandle: false,
    backgroundColor: const Color(0xFFF4F7FD),
    maxHeightFactor: 0.78,
    builder: (_) {
      return AppPickerSheet(
        title: title,
        mode: mode,
        options: options,
        columns: columns,
        cascadeOptions: cascadeOptions,
        initialValues: initialValues,
      );
    },
  );
}

class AppPickerSheet extends StatefulWidget {
  const AppPickerSheet({
    super.key,
    required this.title,
    required this.mode,
    required this.options,
    required this.columns,
    required this.cascadeOptions,
    required this.initialValues,
  });

  final String title;
  final AppPickerMode mode;
  final List<AppPickerOption> options;
  final List<AppPickerColumn> columns;
  final List<AppPickerOption> cascadeOptions;
  final List<String> initialValues;

  @override
  State<AppPickerSheet> createState() => _AppPickerSheetState();
}

class _AppPickerSheetState extends State<AppPickerSheet> {
  late List<String> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = _buildInitialValues();
  }

  @override
  Widget build(BuildContext context) {
    final displayColumns = _buildDisplayColumns();
    final result = _buildResult(displayColumns);

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
        AppPickerHeader(
          title: widget.title,
          subtitle: _subtitle(displayColumns.length),
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: () => Navigator.of(context).pop(result),
        ),
        const SizedBox(height: 16),
        AppPickerPreviewCard(result: result),
        const SizedBox(height: 14),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < displayColumns.length; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                AppPickerColumnView(
                  label: displayColumns[index].label,
                  options: displayColumns[index].options,
                  selectedValue: _selectedValues[index],
                  onSelected: (value) => _handleSelected(index, value),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _subtitle(int columnCount) {
    final modeLabel = switch (widget.mode) {
      AppPickerMode.single => '单列',
      AppPickerMode.multiple => '多列',
      AppPickerMode.cascade => '树形级联',
    };
    return '$modeLabel Picker，当前 $columnCount 列';
  }

  List<String> _buildInitialValues() {
    final columns = _buildDisplayColumnsFrom(widget.initialValues);
    if (columns.isEmpty) {
      return const <String>[];
    }
    return [
      for (var index = 0; index < columns.length; index++)
        _safeValue(
          options: columns[index].options,
          preferred: index < widget.initialValues.length
              ? widget.initialValues[index]
              : null,
        ),
    ];
  }

  List<_PickerDisplayColumn> _buildDisplayColumns() {
    return _buildDisplayColumnsFrom(_selectedValues);
  }

  List<_PickerDisplayColumn> _buildDisplayColumnsFrom(List<String> selected) {
    return switch (widget.mode) {
      AppPickerMode.single => [
          _PickerDisplayColumn(
            label: '选项',
            options: widget.options,
          ),
        ],
      AppPickerMode.multiple => [
          for (final column in widget.columns)
            _PickerDisplayColumn(
              label: column.key,
              options: column.options,
            ),
        ],
      AppPickerMode.cascade => _buildCascadeColumns(selected),
    };
  }

  List<_PickerDisplayColumn> _buildCascadeColumns(List<String> selected) {
    final displayColumns = <_PickerDisplayColumn>[];
    var currentOptions = widget.cascadeOptions;
    var depth = 0;

    while (currentOptions.isNotEmpty) {
      displayColumns.add(
        _PickerDisplayColumn(
          label: _cascadeLabel(depth),
          options: currentOptions,
        ),
      );

      final preferred = depth < selected.length ? selected[depth] : null;
      final resolved = _safeValue(
        options: currentOptions,
        preferred: preferred,
      );
      final current =
          currentOptions.firstWhere((item) => item.value == resolved);
      currentOptions = current.children;
      depth += 1;
    }

    return displayColumns;
  }

  String _cascadeLabel(int depth) {
    const labels = ['一级', '二级', '三级', '四级', '五级'];
    if (depth < labels.length) {
      return labels[depth];
    }
    return '第${depth + 1}级';
  }

  String _safeValue({
    required List<AppPickerOption> options,
    required String? preferred,
  }) {
    if (options.isEmpty) {
      return '';
    }
    final matched = options.where((item) => item.value == preferred);
    if (matched.isNotEmpty) {
      return matched.first.value;
    }
    return options.first.value;
  }

  AppPickerResult _buildResult(List<_PickerDisplayColumn> columns) {
    final values = <String>[];
    final texts = <String>[];

    for (var index = 0; index < columns.length; index++) {
      final options = columns[index].options;
      if (options.isEmpty) {
        continue;
      }
      final value = _safeValue(
        options: options,
        preferred:
            index < _selectedValues.length ? _selectedValues[index] : null,
      );
      final option = options.firstWhere((item) => item.value == value);
      values.add(option.value);
      texts.add(option.text);
    }

    return AppPickerResult(
      values: values,
      texts: texts,
    );
  }

  void _handleSelected(int columnIndex, String value) {
    setState(() {
      final nextValues = List<String>.from(_selectedValues);
      if (columnIndex < nextValues.length) {
        nextValues[columnIndex] = value;
      } else {
        nextValues.add(value);
      }

      if (widget.mode == AppPickerMode.cascade &&
          columnIndex + 1 < nextValues.length) {
        nextValues.removeRange(columnIndex + 1, nextValues.length);
      }

      final columns = _buildDisplayColumnsFrom(nextValues);
      _selectedValues = [
        for (var index = 0; index < columns.length; index++)
          _safeValue(
            options: columns[index].options,
            preferred: index < nextValues.length ? nextValues[index] : null,
          ),
      ];
    });
  }
}

class _PickerDisplayColumn {
  const _PickerDisplayColumn({
    required this.label,
    required this.options,
  });

  final String label;
  final List<AppPickerOption> options;
}

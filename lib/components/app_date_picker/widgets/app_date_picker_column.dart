import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_date_picker/app_date_picker_types.dart';
import 'package:oolaf_flutted/components/app_date_picker/app_date_picker_utils.dart';

class AppDatePickerColumn extends StatelessWidget {
  const AppDatePickerColumn({
    super.key,
    required this.type,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  final AppDatePickerColumnType type;
  final List<int> values;
  final int selectedValue;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        values.indexOf(selectedValue).clamp(0, values.length - 1);
    final controller = FixedExtentScrollController(initialItem: selectedIndex);

    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xB8FFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x12000000)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Text(
                AppDatePickerUtils.columnLabel(type),
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: controller,
                itemExtent: 42,
                useMagnifier: true,
                magnification: 1.08,
                onSelectedItemChanged: (index) {
                  onSelected(values[index]);
                },
                children: values
                    .map(
                      (item) => Center(
                        child: Text(
                          AppDatePickerUtils.itemLabel(type, item),
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

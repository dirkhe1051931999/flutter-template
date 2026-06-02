import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_picker/app_picker_types.dart';

class AppPickerColumnView extends StatelessWidget {
  const AppPickerColumnView({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final List<AppPickerOption> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final safeIndex = _selectedIndex();
    final controller = FixedExtentScrollController(initialItem: safeIndex);

    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x12000000)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: CupertinoPicker(
                  scrollController: controller,
                  itemExtent: 42,
                  magnification: 1.05,
                  useMagnifier: true,
                  squeeze: 1.18,
                  selectionOverlay: Container(
                    decoration: BoxDecoration(
                      color: const Color(0x132563EB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onSelectedItemChanged: (index) {
                    if (index < 0 || index >= options.length) {
                      return;
                    }
                    onSelected(options[index].value);
                  },
                  children: options
                      .map(
                        (option) => Center(
                          child: Text(
                            option.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  int _selectedIndex() {
    if (options.isEmpty) {
      return 0;
    }
    final index = options.indexWhere((item) => item.value == selectedValue);
    if (index >= 0) {
      return index;
    }
    return 0;
  }
}

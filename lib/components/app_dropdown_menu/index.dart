import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';

class AppDropdownOption<T> {
  const AppDropdownOption({
    required this.text,
    required this.value,
  });

  final String text;
  final T value;
}

class AppDropdownMenuItem<T> {
  const AppDropdownMenuItem({
    required this.value,
    required this.options,
    required this.onChanged,
    this.title,
    this.disabled = false,
  });

  final T value;
  final List<AppDropdownOption<T>> options;
  final ValueChanged<T> onChanged;
  final String? title;
  final bool disabled;
}

class AppDropdownMenu extends StatelessWidget {
  const AppDropdownMenu({
    super.key,
    required this.items,
    this.activeColor = const Color(0xFF2563EB),
    this.backgroundColor = const Color(0xCCFFFFFF),
  });

  final List<AppDropdownMenuItem<dynamic>> items;
  final Color activeColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Row(
        children: List<Widget>.generate(items.length, (index) {
          final item = items[index];
          final selected = item.options.where((option) => option.value == item.value).firstOrNull;
          final label = item.title ?? selected?.text ?? '';

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: item.disabled
                  ? null
                  : () async {
                      final selectedIndex = await showAppSheet<int>(
                        context: context,
                        position: AppSheetPosition.top,
                        enableBlur: true,
                        backgroundColor: const Color(0xFFF8FAFD),
                        builder: (_) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List<Widget>.generate(item.options.length, (optionIndex) {
                              final option = item.options[optionIndex];
                              final active = option.value == item.value;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: optionIndex == item.options.length - 1 ? 0 : 10,
                                ),
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(optionIndex),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: const Color(0xCCFFFFFF),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: active
                                            ? activeColor.withValues(alpha: 0.22)
                                            : const Color(0x12000000),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              option.text,
                                              style: TextStyle(
                                                color: active ? activeColor : const Color(0xFF202127),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (active)
                                            Icon(
                                              CupertinoIcons.check_mark,
                                              size: 18,
                                              color: activeColor,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      );

                      if (selectedIndex == null) {
                        return;
                      }
                      item.onChanged(item.options[selectedIndex].value);
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: item.disabled ? const Color(0xFFB6BDC9) : const Color(0xFF202127),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      CupertinoIcons.chevron_down,
                      size: 14,
                      color: item.disabled ? const Color(0xFFB6BDC9) : const Color(0xFF667085),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

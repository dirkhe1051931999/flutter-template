import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/area_pick/area_pick_asset_loader.dart';
import 'package:oolaf_flutted/components/area_pick/widgets/area_pick_sheet.dart';
import 'package:oolaf_flutted/model/area/area_item.dart';

class AreaPickField extends StatefulWidget {
  const AreaPickField({
    super.key,
    this.value = AreaSelection.empty,
    this.onChanged,
    this.title = '地区选择',
    this.placeholder = '请选择省 / 市 / 区县 / 乡镇',
    this.helperText,
    this.enabled = true,
    this.levelCount = 4,
  });

  final AreaSelection value;
  final ValueChanged<AreaSelection>? onChanged;
  final String title;
  final String placeholder;
  final String? helperText;
  final bool enabled;
  final int levelCount;

  @override
  State<AreaPickField> createState() => _AreaPickFieldState();
}

class _AreaPickFieldState extends State<AreaPickField> {
  bool _loading = false;

  Future<void> _openPicker() async {
    if (!widget.enabled || _loading) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final items = await AreaPickAssetLoader.load();
      if (!mounted) {
        return;
      }

      final result = await showCupertinoModalPopup<AreaSelection>(
        context: context,
        barrierColor: const Color(0x4A0B1020),
        builder: (context) {
          return AreaPickSheet(
            items: items,
            initialSelection: widget.value,
            levelCount: widget.levelCount,
          );
        },
      );

      if (result != null) {
        widget.onChanged?.call(result);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = !widget.value.isEmpty;
    final safeLevelCount = widget.levelCount.clamp(2, 4);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openPicker,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: widget.enabled ? 1 : 0.5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFDFEFF),
                Color(0xFFF2F5FB),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0x14000000)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: _loading
                            ? const CupertinoActivityIndicator(radius: 9)
                            : const Icon(
                                CupertinoIcons.chevron_forward,
                                size: 18,
                                color: Color(0xFF667085),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  hasValue
                      ? widget.value.displayTextUpTo(safeLevelCount)
                      : widget.placeholder,
                  style: TextStyle(
                    color: hasValue
                        ? const Color(0xFF1F2937)
                        : const Color(0xFF98A2B3),
                    fontSize: 15,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                if (widget.helperText != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    widget.helperText!,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

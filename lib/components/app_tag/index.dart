import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_tag/app_tag_types.dart';

class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.text,
    this.type = AppTagType.defaultType,
    this.size = AppTagSize.medium,
    this.plain = false,
    this.round = false,
    this.mark = false,
    this.closeable = false,
    this.onClose,
    this.color,
    this.textColor,
  });

  final String text;
  final AppTagType type;
  final AppTagSize size;
  final bool plain;
  final bool round;
  final bool mark;
  final bool closeable;
  final VoidCallback? onClose;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? _resolveColor();
    final foreground = textColor ?? (plain ? themeColor : const Color(0xFFFFFFFF));
    final radius = mark
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          )
        : BorderRadius.circular(round ? 999 : 12);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: plain ? const Color(0x00FFFFFF) : themeColor,
        borderRadius: radius,
        border: Border.all(
          color: themeColor.withValues(alpha: plain ? 0.88 : 0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size == AppTagSize.large ? 10 : 8,
          vertical: size == AppTagSize.large ? 6 : 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: foreground,
                fontSize: size == AppTagSize.large ? 13 : 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (closeable) ...[
              const SizedBox(width: 6),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: Icon(
                  CupertinoIcons.clear_thick,
                  size: 12,
                  color: foreground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _resolveColor() {
    return switch (type) {
      AppTagType.defaultType => const Color(0xFF98A2B3),
      AppTagType.primary => const Color(0xFF2563EB),
      AppTagType.success => const Color(0xFF16A34A),
      AppTagType.warning => const Color(0xFFF59E0B),
      AppTagType.danger => const Color(0xFFE5484D),
    };
  }
}

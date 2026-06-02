import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_button/app_button_types.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.normal,
    this.plain = false,
    this.hairline = false,
    this.disabled = false,
    this.loading = false,
    this.round = false,
    this.square = false,
    this.block = false,
    this.icon,
    this.color,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonType type;
  final AppButtonSize size;
  final bool plain;
  final bool hairline;
  final bool disabled;
  final bool loading;
  final bool round;
  final bool square;
  final bool block;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? _resolveThemeColor();
    final backgroundColor = plain ? const Color(0x00FFFFFF) : themeColor;
    final foregroundColor = plain ? themeColor : const Color(0xFFFFFFFF);
    final borderRadius = square
        ? BorderRadius.circular(12)
        : BorderRadius.circular(round ? 999 : _radiusForSize());
    final enabled = !disabled && !loading && onPressed != null;

    final content = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          CupertinoActivityIndicator(
            color: foregroundColor,
          )
        else if (icon != null)
          Icon(
            icon,
            size: _iconSize(),
            color: foregroundColor,
          ),
        if (loading || icon != null) const SizedBox(width: 8),
        DefaultTextStyle(
          style: TextStyle(
            color: foregroundColor,
            fontSize: _fontSize(),
            fontWeight: FontWeight.w700,
          ),
          child: child,
        ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onPressed : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: Border.all(
              color: themeColor.withValues(alpha: plain ? 0.8 : 0.18),
              width: hairline ? 0.5 : 1,
            ),
            boxShadow: plain
                ? null
                : [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: _height(),
              minWidth: block ? double.infinity : 0,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _horizontalPadding(),
                vertical: _verticalPadding(),
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  Color _resolveThemeColor() {
    return switch (type) {
      AppButtonType.defaultType => const Color(0xFFF2F4F7),
      AppButtonType.primary => const Color(0xFF2563EB),
      AppButtonType.success => const Color(0xFF16A34A),
      AppButtonType.warning => const Color(0xFFF59E0B),
      AppButtonType.danger => const Color(0xFFE5484D),
    };
  }

  double _height() {
    return switch (size) {
      AppButtonSize.large => 50,
      AppButtonSize.normal => 46,
      AppButtonSize.small => 38,
      AppButtonSize.mini => 30,
    };
  }

  double _radiusForSize() {
    return switch (size) {
      AppButtonSize.large => 20,
      AppButtonSize.normal => 18,
      AppButtonSize.small => 14,
      AppButtonSize.mini => 12,
    };
  }

  double _fontSize() {
    return switch (size) {
      AppButtonSize.large => 16,
      AppButtonSize.normal => 15,
      AppButtonSize.small => 14,
      AppButtonSize.mini => 13,
    };
  }

  double _iconSize() {
    return switch (size) {
      AppButtonSize.large => 18,
      AppButtonSize.normal => 17,
      AppButtonSize.small => 16,
      AppButtonSize.mini => 14,
    };
  }

  double _horizontalPadding() {
    return switch (size) {
      AppButtonSize.large => 20,
      AppButtonSize.normal => 18,
      AppButtonSize.small => 14,
      AppButtonSize.mini => 12,
    };
  }

  double _verticalPadding() {
    return switch (size) {
      AppButtonSize.large => 14,
      AppButtonSize.normal => 12,
      AppButtonSize.small => 10,
      AppButtonSize.mini => 7,
    };
  }
}

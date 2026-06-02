import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_checkbox/app_checkbox_types.dart';
import 'package:oolaf_flutted/components/app_radio/app_radio_types.dart';

class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
    required this.children,
    this.disabled = false,
    this.iconSize = 22,
    this.checkedColor = const Color(0xFF2563EB),
    this.direction = AppRadioDirection.vertical,
    this.labelPosition = AppRadioLabelPosition.right,
    this.shape = AppRadioShape.round,
    this.spacing = 12,
  });

  final T? value;
  final ValueChanged<T> onChanged;
  final List<Widget> children;
  final bool disabled;
  final double iconSize;
  final Color checkedColor;
  final AppRadioDirection direction;
  final AppRadioLabelPosition labelPosition;
  final AppRadioShape shape;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return _AppRadioGroupScope<T>(
      value: value,
      onChanged: onChanged,
      disabled: disabled,
      iconSize: iconSize,
      checkedColor: checkedColor,
      labelPosition: labelPosition,
      shape: shape,
      child: direction == AppRadioDirection.vertical
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _withSpacing(children, spacing, Axis.vertical),
            )
          : Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: children,
            ),
    );
  }
}

class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    super.key,
    required this.name,
    this.value = false,
    this.onChanged,
    this.disabled = false,
    this.iconSize = 22,
    this.checkedColor = const Color(0xFF2563EB),
    this.shape = AppRadioShape.round,
    this.labelPosition = AppRadioLabelPosition.right,
    this.title,
    this.subtitle,
    this.child,
    this.bindGroup = true,
  });

  final T name;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool disabled;
  final double iconSize;
  final Color checkedColor;
  final AppRadioShape shape;
  final AppRadioLabelPosition labelPosition;
  final String? title;
  final String? subtitle;
  final Widget? child;
  final bool bindGroup;

  @override
  Widget build(BuildContext context) {
    final group = bindGroup ? _AppRadioGroupScope.maybeOf<T>(context) : null;
    final effectiveDisabled = disabled || (group?.disabled ?? false);
    final effectiveIconSize = group?.iconSize ?? iconSize;
    final effectiveCheckedColor = group?.checkedColor ?? checkedColor;
    final effectiveShape = group?.shape ?? shape;
    final effectiveLabelPosition = group?.labelPosition ?? labelPosition;
    final checked = group == null ? value : group.value == name;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: effectiveDisabled
          ? null
          : () {
              if (group != null) {
                group.select(name);
                return;
              }
              onChanged?.call(true);
            },
      child: Opacity(
        opacity: effectiveDisabled ? 0.56 : 1,
        child: child ??
            _AppRadioTile(
              title: title,
              subtitle: subtitle,
              checked: checked,
              disabled: effectiveDisabled,
              iconSize: effectiveIconSize,
              checkedColor: effectiveCheckedColor,
              shape: effectiveShape,
              labelPosition: effectiveLabelPosition,
              iconBuilder: (size, isChecked, color, itemShape) {
                final dotSize = size * 0.42;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(
                      appCheckRadius(itemShape, size),
                    ),
                    border: Border.all(
                      color: isChecked ? color : const Color(0xFFB8C0CC),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      width: isChecked ? dotSize : 0,
                      height: isChecked ? dotSize : 0,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(
                          appCheckRadius(itemShape, dotSize),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}

class _AppRadioTile extends StatelessWidget {
  const _AppRadioTile({
    required this.title,
    required this.subtitle,
    required this.checked,
    required this.disabled,
    required this.iconSize,
    required this.checkedColor,
    required this.shape,
    required this.labelPosition,
    required this.iconBuilder,
  });

  final String? title;
  final String? subtitle;
  final bool checked;
  final bool disabled;
  final double iconSize;
  final Color checkedColor;
  final AppRadioShape shape;
  final AppRadioLabelPosition labelPosition;
  final Widget Function(
    double size,
    bool checked,
    Color color,
    AppCheckShape shape,
  ) iconBuilder;

  @override
  Widget build(BuildContext context) {
    final icon = iconBuilder(iconSize, checked, checkedColor, shape);
    final text = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty)
            Text(
              title!,
              style: TextStyle(
                color: disabled
                    ? const Color(0xFF98A2B3)
                    : const Color(0xFF202127),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: disabled
                    ? const Color(0xFFB6BDC9)
                    : const Color(0xFF667085),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: checked
              ? checkedColor.withValues(alpha: 0.22)
              : const Color(0x12000000),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: appCheckMainAxisAlignment(labelPosition),
          children: labelPosition == AppRadioLabelPosition.left
              ? [text, const SizedBox(width: 12), icon]
              : [icon, const SizedBox(width: 12), text],
        ),
      ),
    );
  }
}

class _AppRadioGroupScope<T> extends InheritedWidget {
  const _AppRadioGroupScope({
    required this.value,
    required this.onChanged,
    required this.disabled,
    required this.iconSize,
    required this.checkedColor,
    required this.labelPosition,
    required this.shape,
    required super.child,
  });

  final T? value;
  final ValueChanged<T> onChanged;
  final bool disabled;
  final double iconSize;
  final Color checkedColor;
  final AppRadioLabelPosition labelPosition;
  final AppRadioShape shape;

  static _AppRadioGroupScope<T>? maybeOf<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AppRadioGroupScope<T>>();
  }

  void select(T nextValue) {
    if (value == nextValue) {
      return;
    }
    onChanged(nextValue);
  }

  @override
  bool updateShouldNotify(covariant _AppRadioGroupScope<T> oldWidget) {
    return value != oldWidget.value ||
        disabled != oldWidget.disabled ||
        iconSize != oldWidget.iconSize ||
        checkedColor != oldWidget.checkedColor ||
        labelPosition != oldWidget.labelPosition ||
        shape != oldWidget.shape;
  }
}

List<Widget> _withSpacing(
  List<Widget> children,
  double spacing,
  Axis direction,
) {
  if (children.length < 2) {
    return children;
  }
  final result = <Widget>[];
  for (var index = 0; index < children.length; index++) {
    result.add(children[index]);
    if (index == children.length - 1) {
      continue;
    }
    result.add(
      direction == Axis.vertical
          ? SizedBox(height: spacing)
          : SizedBox(width: spacing),
    );
  }
  return result;
}

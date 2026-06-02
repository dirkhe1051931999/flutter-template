import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_checkbox/app_checkbox_types.dart';

class AppCheckboxGroup<T> extends StatelessWidget {
  const AppCheckboxGroup({
    super.key,
    required this.values,
    required this.onChanged,
    required this.children,
    this.max,
    this.disabled = false,
    this.iconSize = 22,
    this.checkedColor = const Color(0xFF2563EB),
    this.direction = AppCheckDirection.vertical,
    this.labelPosition = AppCheckLabelPosition.right,
    this.shape = AppCheckShape.round,
    this.spacing = 12,
  });

  final List<T> values;
  final ValueChanged<List<T>> onChanged;
  final List<Widget> children;
  final int? max;
  final bool disabled;
  final double iconSize;
  final Color checkedColor;
  final AppCheckDirection direction;
  final AppCheckLabelPosition labelPosition;
  final AppCheckShape shape;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return _AppCheckboxGroupScope<T>(
      values: values,
      onChanged: onChanged,
      max: max,
      disabled: disabled,
      iconSize: iconSize,
      checkedColor: checkedColor,
      labelPosition: labelPosition,
      shape: shape,
      child: direction == AppCheckDirection.vertical
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

class AppCheckbox<T> extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.name,
    this.value = false,
    this.onChanged,
    this.disabled = false,
    this.iconSize = 22,
    this.checkedColor = const Color(0xFF2563EB),
    this.shape = AppCheckShape.round,
    this.labelPosition = AppCheckLabelPosition.right,
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
  final AppCheckShape shape;
  final AppCheckLabelPosition labelPosition;
  final String? title;
  final String? subtitle;
  final Widget? child;
  final bool bindGroup;

  @override
  Widget build(BuildContext context) {
    final group = bindGroup ? _AppCheckboxGroupScope.maybeOf<T>(context) : null;
    final effectiveDisabled = disabled || (group?.disabled ?? false);
    final effectiveIconSize = group?.iconSize ?? iconSize;
    final effectiveCheckedColor = group?.checkedColor ?? checkedColor;
    final effectiveShape = group?.shape ?? shape;
    final effectiveLabelPosition = group?.labelPosition ?? labelPosition;
    final checked = group == null ? value : group.values.contains(name);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: effectiveDisabled
          ? null
          : () {
              if (group != null) {
                group.toggle(name);
                return;
              }
              onChanged?.call(!checked);
            },
      child: Opacity(
        opacity: effectiveDisabled ? 0.56 : 1,
        child: child ??
            _AppCheckTile(
              title: title,
              subtitle: subtitle,
              checked: checked,
              disabled: effectiveDisabled,
              iconSize: effectiveIconSize,
              checkedColor: effectiveCheckedColor,
              shape: effectiveShape,
              labelPosition: effectiveLabelPosition,
              iconBuilder: (size, isChecked, color, itemShape) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: isChecked ? color : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(
                      appCheckRadius(itemShape, size),
                    ),
                    border: Border.all(
                      color: isChecked ? color : const Color(0xFFB8C0CC),
                      width: 1.5,
                    ),
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: isChecked ? 1 : 0,
                    child: const Icon(
                      CupertinoIcons.check_mark,
                      size: 14,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}

class _AppCheckboxGroupScope<T> extends InheritedWidget {
  const _AppCheckboxGroupScope({
    required this.values,
    required this.onChanged,
    required this.max,
    required this.disabled,
    required this.iconSize,
    required this.checkedColor,
    required this.labelPosition,
    required this.shape,
    required super.child,
  });

  final List<T> values;
  final ValueChanged<List<T>> onChanged;
  final int? max;
  final bool disabled;
  final double iconSize;
  final Color checkedColor;
  final AppCheckLabelPosition labelPosition;
  final AppCheckShape shape;

  static _AppCheckboxGroupScope<T>? maybeOf<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AppCheckboxGroupScope<T>>();
  }

  void toggle(T name) {
    final next = [...values];
    if (next.contains(name)) {
      next.remove(name);
      onChanged(next);
      return;
    }
    if (max != null && next.length >= max!) {
      return;
    }
    next.add(name);
    onChanged(next);
  }

  @override
  bool updateShouldNotify(covariant _AppCheckboxGroupScope<T> oldWidget) {
    return values != oldWidget.values ||
        max != oldWidget.max ||
        disabled != oldWidget.disabled ||
        iconSize != oldWidget.iconSize ||
        checkedColor != oldWidget.checkedColor ||
        labelPosition != oldWidget.labelPosition ||
        shape != oldWidget.shape;
  }
}

class _AppCheckTile extends StatelessWidget {
  const _AppCheckTile({
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
  final AppCheckShape shape;
  final AppCheckLabelPosition labelPosition;
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
          children: labelPosition == AppCheckLabelPosition.left
              ? [text, const SizedBox(width: 12), icon]
              : [icon, const SizedBox(width: 12), text],
        ),
      ),
    );
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

part of 'index.dart';

class RouteBottomNavBarTile extends StatelessWidget {
  const RouteBottomNavBarTile({
    required this.item,
    required this.isActive,
    required this.style,
    required this.onTap,
    super.key,
  });

  final RouteBottomNavBarItem item;
  final bool isActive;
  final RouteBottomNavBarStyle style;
  final VoidCallback onTap;

  Color get _resolvedActiveColor => item.activeColor ?? style.activeColor;
  Color get _resolvedInactiveColor => item.inactiveColor ?? style.inactiveColor;
  RouteBottomNavBarItemState get _itemState => RouteBottomNavBarItemState(
        item: item,
        isActive: isActive,
        style: style,
      );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: item.isCenterAction
          ? _buildCenterAction(context)
          : _buildNormalItem(context),
    );
  }

  Widget _buildCenterAction(BuildContext context) {
    final child = item.centerActionChild ??
        Icon(
          item.activeIcon ?? item.icon,
          color: style.centerActionIconColor,
          size: style.centerActionIconSize,
        );
    final defaultChild = Opacity(
      opacity: item.enabled ? 1 : 0.5,
      child: Container(
        width: style.centerActionSize,
        height: style.centerActionSize,
        decoration: BoxDecoration(
          color: item.centerActionBackgroundColor ??
              style.centerActionBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
    final resolvedChild = _resolveCustomItemChild(context, defaultChild);

    return Center(
      child: _buildGestureWrapper(
        child: _wrapAnimatedSelection(child: resolvedChild),
      ),
    );
  }

  Widget _buildNormalItem(BuildContext context) {
    final color = item.enabled
        ? (isActive ? _resolvedActiveColor : _resolvedInactiveColor)
        : style.disabledColor;
    final iconData = isActive ? (item.activeIcon ?? item.icon) : item.icon;

    final defaultChild = Opacity(
      opacity: item.enabled ? 1 : 0.56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedSwitcher(
                duration: style.animationDuration,
                switchInCurve: style.animationCurve,
                switchOutCurve: style.animationCurve,
                child: Icon(
                  iconData,
                  key: ValueKey<String>(
                    '${item.key}-${isActive ? 'active' : 'inactive'}',
                  ),
                  size: style.iconSize,
                  color: color,
                ),
              ),
              if ((item.badgeText ?? '').trim().isNotEmpty)
                Positioned(
                  top: -6,
                  right: -10,
                  child: _RouteBottomNavBarBadge(
                    text: item.badgeText!.trim(),
                    style: style,
                  ),
                )
              else if (item.showDot)
                Positioned(
                  top: style.dotOffset.dy,
                  right: style.dotOffset.dx,
                  child: _RouteBottomNavBarDot(style: style),
                ),
            ],
          ),
          SizedBox(height: style.labelSpacing),
          AnimatedDefaultTextStyle(
            duration: style.animationDuration,
            curve: style.animationCurve,
            style: TextStyle(
              color: color,
              fontSize: style.labelFontSize,
              fontWeight:
                  isActive ? style.activeFontWeight : style.inactiveFontWeight,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
    final resolvedChild = _resolveCustomItemChild(context, defaultChild);

    return _buildGestureWrapper(
      child: _wrapAnimatedSelection(child: resolvedChild),
    );
  }

  Widget _resolveCustomItemChild(BuildContext context, Widget defaultChild) {
    final state = _itemState;
    if (isActive && item.selectedBuilder != null) {
      return item.selectedBuilder!(context, state, defaultChild);
    }
    if (item.itemBuilder != null) {
      return item.itemBuilder!(context, state, defaultChild);
    }
    return defaultChild;
  }

  Widget _wrapAnimatedSelection({required Widget child}) {
    if (!style.enableSelectionAnimations) {
      return child;
    }
    return AnimatedScale(
      scale: isActive ? style.activeItemScale : style.inactiveItemScale,
      duration: style.animationDuration,
      curve: style.animationCurve,
      child: child,
    );
  }

  Widget _buildGestureWrapper({required Widget child}) {
    return Semantics(
      button: true,
      enabled: item.enabled,
      label: item.semanticLabel ?? item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: item.enabled ? onTap : null,
        onLongPress: item.enabled ? item.onLongPress : null,
        onDoubleTap: item.enabled ? item.onDoubleTap : null,
        child: child,
      ),
    );
  }
}

class _RouteBottomNavBarBadge extends StatelessWidget {
  const _RouteBottomNavBarBadge({
    required this.text,
    required this.style,
  });

  final String text;
  final RouteBottomNavBarStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: style.badgeColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: style.badgeTextColor,
          fontSize: style.badgeFontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RouteBottomNavBarDot extends StatelessWidget {
  const _RouteBottomNavBarDot({
    required this.style,
  });

  final RouteBottomNavBarStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: style.dotSize,
      height: style.dotSize,
      decoration: BoxDecoration(
        color: style.badgeColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

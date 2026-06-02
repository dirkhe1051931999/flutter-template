part of 'index.dart';

class RouteBottomNavBarItem {
  const RouteBottomNavBarItem({
    required this.key,
    required this.label,
    required this.icon,
    this.activeIcon,
    this.isCenterAction = false,
    this.enabled = true,
    this.badgeText,
    this.showDot = false,
    this.semanticLabel,
    this.onLongPress,
    this.onDoubleTap,
    this.centerActionChild,
    this.centerActionBackgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.itemBuilder,
    this.selectedBuilder,
  });

  final String key;
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final bool isCenterAction;
  final bool enabled;
  final String? badgeText;
  final bool showDot;
  final String? semanticLabel;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final Widget? centerActionChild;
  final Color? centerActionBackgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final Widget Function(
    BuildContext context,
    RouteBottomNavBarItemState state,
    Widget defaultChild,
  )? itemBuilder;
  final Widget Function(
    BuildContext context,
    RouteBottomNavBarItemState state,
    Widget defaultChild,
  )? selectedBuilder;
}

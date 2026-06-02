part of 'index.dart';

class RouteBottomNavBarStyle {
  const RouteBottomNavBarStyle({
    this.height = 68,
    this.padding = const EdgeInsets.fromLTRB(8, 6, 8, 8),
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFEAEAEE),
    this.borderWidth = 1,
    this.activeColor = const Color(0xFF202127),
    this.inactiveColor = const Color(0xFF7F838C),
    this.disabledColor = const Color(0xFFBEC3CD),
    this.iconSize = 24,
    this.labelFontSize = 12,
    this.activeFontWeight = FontWeight.w600,
    this.inactiveFontWeight = FontWeight.w500,
    this.labelSpacing = 2,
    this.centerActionSize = 46,
    this.centerActionIconSize = 28,
    this.centerActionBackgroundColor = const Color(0xFFFF1D25),
    this.centerActionIconColor = Colors.white,
    this.badgeColor = const Color(0xFFE5484D),
    this.badgeTextColor = Colors.white,
    this.badgeFontSize = 10,
    this.enableSelectionAnimations = true,
    this.animationDuration = const Duration(milliseconds: 180),
    this.animationCurve = Curves.easeOutCubic,
    this.activeItemScale = 1.06,
    this.inactiveItemScale = 1.0,
    this.dotSize = 8,
    this.dotOffset = const Offset(10, -2),
    this.useCupertinoVisualDensity = false,
  });

  const RouteBottomNavBarStyle.cupertino({
    this.height = 74,
    this.padding = const EdgeInsets.fromLTRB(10, 8, 10, 10),
    this.backgroundColor = const Color(0xFFFDFDFE),
    this.borderColor = const Color(0x1F000000),
    this.borderWidth = 0.5,
    this.activeColor = const Color(0xFF111111),
    this.inactiveColor = const Color(0xFF8E8E93),
    this.disabledColor = const Color(0xFFC7C7CC),
    this.iconSize = 23,
    this.labelFontSize = 11,
    this.activeFontWeight = FontWeight.w600,
    this.inactiveFontWeight = FontWeight.w500,
    this.labelSpacing = 3,
    this.centerActionSize = 50,
    this.centerActionIconSize = 27,
    this.centerActionBackgroundColor = const Color(0xFF0A84FF),
    this.centerActionIconColor = Colors.white,
    this.badgeColor = const Color(0xFFFF3B30),
    this.badgeTextColor = Colors.white,
    this.badgeFontSize = 10,
    this.enableSelectionAnimations = true,
    this.animationDuration = const Duration(milliseconds: 180),
    this.animationCurve = Curves.easeOutCubic,
    this.activeItemScale = 1.04,
    this.inactiveItemScale = 1.0,
    this.dotSize = 8,
    this.dotOffset = const Offset(10, -2),
    this.useCupertinoVisualDensity = true,
  });

  final double height;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color activeColor;
  final Color inactiveColor;
  final Color disabledColor;
  final double iconSize;
  final double labelFontSize;
  final FontWeight activeFontWeight;
  final FontWeight inactiveFontWeight;
  final double labelSpacing;
  final double centerActionSize;
  final double centerActionIconSize;
  final Color centerActionBackgroundColor;
  final Color centerActionIconColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final double badgeFontSize;
  final bool enableSelectionAnimations;
  final Duration animationDuration;
  final Curve animationCurve;
  final double activeItemScale;
  final double inactiveItemScale;
  final double dotSize;
  final Offset dotOffset;
  final bool useCupertinoVisualDensity;
}

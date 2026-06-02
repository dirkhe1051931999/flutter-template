part of 'index.dart';

class RouteBottomNavBarItemState {
  const RouteBottomNavBarItemState({
    required this.item,
    required this.isActive,
    required this.style,
  });

  final RouteBottomNavBarItem item;
  final bool isActive;
  final RouteBottomNavBarStyle style;

  bool get isEnabled => item.enabled;
}

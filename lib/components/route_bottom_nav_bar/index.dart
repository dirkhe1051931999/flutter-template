import 'package:flutter/material.dart';

part 'route_bottom_nav_bar_item.dart';
part 'route_bottom_nav_bar_item_state.dart';
part 'route_bottom_nav_bar_style.dart';
part 'route_bottom_nav_bar_tile.dart';

class RouteBottomNavBar extends StatelessWidget {
  const RouteBottomNavBar({
    required this.items,
    required this.activeKey,
    required this.onTap,
    this.onReselect,
    this.style = const RouteBottomNavBarStyle(),
    this.respectBottomSafeArea = false,
    super.key,
  });

  final List<RouteBottomNavBarItem> items;
  final String activeKey;
  final ValueChanged<String> onTap;
  final ValueChanged<String>? onReselect;
  final RouteBottomNavBarStyle style;
  final bool respectBottomSafeArea;

  void _handleTap(RouteBottomNavBarItem item) {
    if (!item.enabled) {
      return;
    }
    if (item.key == activeKey) {
      onReselect?.call(item.key);
      return;
    }
    onTap(item.key);
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom =
        respectBottomSafeArea ? MediaQuery.of(context).padding.bottom : 0.0;
    return Container(
      height: style.height + safeAreaBottom,
      padding: EdgeInsets.only(bottom: safeAreaBottom).add(style.padding),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        border: Border(
          top: BorderSide(
            color: style.borderColor,
            width: style.borderWidth,
          ),
        ),
      ),
      child: Row(
        children: items
            .map(
              (item) => RouteBottomNavBarTile(
                item: item,
                isActive: activeKey == item.key,
                style: style,
                onTap: () => _handleTap(item),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HupuBottomNavItem {
  const HupuBottomNavItem({
    required this.key,
    required this.label,
    required this.icon,
    this.activeIcon,
    this.isCenterAction = false,
  });

  final String key;
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final bool isCenterAction;
}

class HupuBottomNav extends StatelessWidget {
  const HupuBottomNav({
    required this.items,
    required this.activeKey,
    required this.onTap,
    super.key,
  });

  final List<HupuBottomNavItem> items;
  final String activeKey;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFEAEAEE),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: items.map((item) {
          if (item.isCenterAction) {
            return Expanded(
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(item.key),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF1D25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            );
          }

          final isActive = activeKey == item.key;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(item.key),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? (item.activeIcon ?? item.icon) : item.icon,
                    size: 24,
                    color: isActive
                        ? const Color(0xFF202127)
                        : const Color(0xFF7F838C),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF202127)
                          : const Color(0xFF7F838C),
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

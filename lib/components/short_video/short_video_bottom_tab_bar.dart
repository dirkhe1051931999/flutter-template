import 'package:flutter/cupertino.dart';

class ShortVideoTabItem {
  const ShortVideoTabItem({
    required this.label,
  });

  final String label;
}

class ShortVideoBottomTabBar {
  const ShortVideoBottomTabBar._();

  static CupertinoTabBar create({
    required List<ShortVideoTabItem> items,
    required int currentIndex,
    required ValueChanged<int> onTap,
    required bool darkStyle,
  }) {
    final activeColor = darkStyle
        ? CupertinoColors.white
        : const Color(0xFF0D0D0F);
    final inactiveColor = darkStyle
        ? const Color(0x99FFFFFF)
        : const Color(0x8A3C3C43);

    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: onTap,
      height: 52,
      border: const Border(
        top: BorderSide(
          color: Color(0x26000000),
          width: 0.5,
        ),
      ),
      backgroundColor: darkStyle
          ? const Color(0xE6000000)
          : const Color(0xF2FFFFFF),
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      items: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isActive = index == currentIndex;

        return BottomNavigationBarItem(
          label: '',
          icon: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: isActive ? 16 : 15,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

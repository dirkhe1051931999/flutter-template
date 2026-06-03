import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_sidebar/app_sidebar_types.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.items,
    required this.activeKey,
    required this.onChange,
    this.width = 104,
    this.activeColor = const Color(0xFF2563EB),
    this.backgroundColor = const Color(0xFFF5F7FB),
  });

  final List<AppSidebarItemData> items;
  final int activeKey;
  final ValueChanged<int> onChange;
  final double width;
  final Color activeColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SizedBox(
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final active = index == activeKey;
              return _SidebarItem(
                item: item,
                active: active,
                activeColor: activeColor,
                onTap: item.disabled ? null : () => onChange(index),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.active,
    required this.activeColor,
    this.onTap,
  });

  final AppSidebarItemData item;
  final bool active;
  final Color activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final titleColor = item.disabled
        ? const Color(0xFFB8BFCC)
        : active
            ? const Color(0xFF202127)
            : const Color(0xFF667085);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: 4,
              height: active ? 24 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 14,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.dot)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      )
                    else if (item.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: active ? activeColor : const Color(0xFFE8ECF4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.badge!,
                          style: TextStyle(
                            color: active
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF667085),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HupuTopBar extends StatelessWidget {
  const HupuTopBar({
    required this.tabs,
    super.key,
  });

  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final isActive = index == 0;
                return Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF1F1F1F)
                          : const Color(0xFF9A9AA3),
                      fontSize: isActive ? 18 : 15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 24),
              itemCount: tabs.length,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.menu,
            size: 20,
            color: Color(0xFF7C7C84),
          ),
        ],
      ),
    );
  }
}

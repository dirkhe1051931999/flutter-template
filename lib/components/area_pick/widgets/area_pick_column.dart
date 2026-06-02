import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/model/area/area_item.dart';

class AreaPickColumn extends StatelessWidget {
  const AreaPickColumn({
    super.key,
    required this.title,
    required this.items,
    required this.selectedCode,
    required this.onSelected,
    this.placeholder = '暂无数据',
  });

  final String title;
  final List<AreaItem> items;
  final String? selectedCode;
  final ValueChanged<AreaItem> onSelected;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xB8FFFFFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x12000000)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          placeholder,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final selected = item.code == selectedCode;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onSelected(item),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF111827)
                                    : const Color(0xFFF5F7FB),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selected
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0xFF1F2937),
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

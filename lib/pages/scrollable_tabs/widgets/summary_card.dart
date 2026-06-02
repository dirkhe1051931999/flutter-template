import 'package:flutter/cupertino.dart';

class LinkedTabSummaryCard extends StatelessWidget {
  const LinkedTabSummaryCard({
    required this.currentTabLabel,
    required this.currentDescription,
    required this.refreshCount,
    required this.lastChangeSource,
    required this.onJumpToFirst,
    required this.onJumpToState,
    super.key,
  });

  final String currentTabLabel;
  final String currentDescription;
  final int refreshCount;
  final String lastChangeSource;
  final VoidCallback onJumpToFirst;
  final VoidCallback onJumpToState;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0x14E5484D),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    CupertinoIcons.square_grid_2x2,
                    color: Color(0xFFE5484D),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'linked_tab_view 全量演示',
                        style: TextStyle(
                          color: Color(0xFF1F2329),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '当前：$currentTabLabel · 最近切换：$lastChangeSource',
                        style: const TextStyle(
                          color: Color(0xFF7A8191),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              currentDescription,
              style: const TextStyle(
                color: Color(0xFF4C5563),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                InfoChip(label: '刷新次数 $refreshCount'),
                const InfoChip(label: '支持点击 / 滑动 / 程序切换'),
                const InfoChip(label: '内置下拉刷新状态机'),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                SummaryButton(
                  label: '回到精选',
                  filled: true,
                  onPressed: onJumpToFirst,
                ),
                const SizedBox(width: 10),
                SummaryButton(
                  label: '看状态页',
                  filled: false,
                  onPressed: onJumpToState,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF697181),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class SummaryButton extends StatelessWidget {
  const SummaryButton({
    required this.label,
    required this.filled,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      minimumSize: Size.zero,
      color: filled ? const Color(0xFFE5484D) : null,
      borderRadius: BorderRadius.circular(999),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: filled ? CupertinoColors.white : const Color(0xFFE5484D),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

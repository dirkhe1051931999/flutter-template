import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';

class LinkedRefreshIndicator extends StatelessWidget {
  const LinkedRefreshIndicator({
    required this.label,
    required this.accentColor,
    required this.state,
    required this.progress,
    super.key,
  });

  final String label;
  final Color accentColor;
  final LinkedTabRefreshState state;
  final double progress;

  String get _title {
    switch (state) {
      case LinkedTabRefreshState.armed:
        return '$label 准备刷新';
      case LinkedTabRefreshState.refreshing:
        return '$label 正在刷新';
      case LinkedTabRefreshState.complete:
        return '$label 已刷新';
      case LinkedTabRefreshState.idle:
      case LinkedTabRefreshState.pulling:
        return '$label 下拉刷新';
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    return Opacity(
      opacity: normalizedProgress == 0 ? 0 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: CupertinoActivityIndicator.partiallyRevealed(
                    radius: 7,
                    progress: state == LinkedTabRefreshState.refreshing
                        ? 1
                        : normalizedProgress,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _title,
                style: const TextStyle(
                  color: Color(0xFF1F2329),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

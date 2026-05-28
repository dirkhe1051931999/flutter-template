import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HupuRefreshIndicator extends StatelessWidget {
  const HupuRefreshIndicator({
    super.key,
    required this.progress,
    required this.isArmed,
    required this.isRefreshing,
  });

  final double progress;
  final bool isArmed;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final title = isRefreshing
        ? '正在刷新虎扑首页'
        : isArmed
            ? '松手立即刷新'
            : '下拉刷新';
    final subtitle = isRefreshing
        ? '加载最新帖子内容…'
        : isArmed
            ? '准备就绪'
            : '看看有没有新内容';

    return Center(
      child: Opacity(
        opacity: normalizedProgress,
        child: Transform.translate(
          offset: Offset(0, (1 - normalizedProgress) * -12),
          child: Container(
            constraints: const BoxConstraints(minWidth: 168, maxWidth: 220),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xF9FFFFFF),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: 0.88 + (normalizedProgress * 0.22),
                        child: CircularProgressIndicator(
                          value: isRefreshing ? null : normalizedProgress,
                          strokeWidth: 3,
                          color: const Color(0xFFE5484D),
                          backgroundColor: const Color(0x18E5484D),
                        ),
                      ),
                      Icon(
                        isRefreshing
                            ? CupertinoIcons.refresh_thick
                            : (isArmed
                                ? CupertinoIcons.arrow_down_circle_fill
                                : CupertinoIcons.arrow_down_circle),
                        size: 18,
                        color: const Color(0xFFE5484D),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1F2329),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

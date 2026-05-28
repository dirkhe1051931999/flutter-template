import 'dart:async';

import 'package:flutter/cupertino.dart';

enum HupuLoadMoreState {
  idle,
  loading,
  error,
  noMore,
}

class HupuLoadMoreFooter extends StatelessWidget {
  const HupuLoadMoreFooter({
    super.key,
    required this.state,
    required this.errorMessage,
    required this.onRetry,
  });

  final HupuLoadMoreState state;
  final String? errorMessage;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (state == HupuLoadMoreState.idle) {
      return const SizedBox(
        height: 44,
        child: Center(
          child: Text(
            '继续上滑，加载更多热帖',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    if (state == HupuLoadMoreState.loading) {
      return Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 9),
            SizedBox(width: 10),
            Text(
              '正在加载更多热帖…',
              style: TextStyle(
                color: Color(0xFF5B5F66),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (state == HupuLoadMoreState.error) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6F5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x1FE5484D)),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              color: Color(0xFFE5484D),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage?.isNotEmpty == true ? errorMessage! : '加载更多失败，点这里再试一次',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFB42318),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: const Color(0xFFE5484D),
              borderRadius: BorderRadius.circular(999),
              minimumSize: Size.zero,
              onPressed: () {
                unawaited(onRetry());
              },
              child: const Text(
                '重试',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox(
      height: 46,
      child: Center(
        child: Text(
          '已经到底了',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

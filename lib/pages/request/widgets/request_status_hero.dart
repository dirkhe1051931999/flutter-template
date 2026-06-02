import 'package:flutter/cupertino.dart';

class RequestStatusHero extends StatelessWidget {
  const RequestStatusHero({
    required this.total,
    required this.isLoading,
    required this.hasData,
    super.key,
  });

  final int total;
  final bool isLoading;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    final statusText = isLoading
        ? '请求中'
        : hasData
            ? '请求完成'
            : '等待触发';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xB5FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x10FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dio Request Demo',
              style: TextStyle(
                color: Color(0xFF1F2329),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '保留原来的清除和请求逻辑，重点让状态、结果和操作区更好扫读。',
              style: TextStyle(
                color: Color(0xFF77808F),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                StatusChip(label: statusText),
                StatusChip(label: 'total $total'),
                const StatusChip(label: 'GET /guestbook/list'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6A7280),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

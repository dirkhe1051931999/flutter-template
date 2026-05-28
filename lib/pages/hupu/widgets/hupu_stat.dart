import 'package:flutter/material.dart';

class HupuStat extends StatelessWidget {
  const HupuStat({
    required this.icon,
    required this.value,
    super.key,
  });

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF7F838E),
        ),
        const SizedBox(width: 4),
        Text(
          _formatCount(value),
          style: const TextStyle(
            color: Color(0xFF666977),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(count >= 100000 ? 0 : 1)}万';
    }
    return '$count';
  }
}

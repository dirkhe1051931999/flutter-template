import 'package:flutter/cupertino.dart';

class AreaPickHeader extends StatelessWidget {
  const AreaPickHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onCancel,
    required this.onConfirm,
    this.confirmEnabled = true,
  });

  final String title;
  final String subtitle;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool confirmEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size(28, 28),
          onPressed: onCancel,
          child: const Text(
            '取消',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size(28, 28),
          onPressed: confirmEnabled ? onConfirm : null,
          child: Text(
            '完成',
            style: TextStyle(
              color: confirmEnabled
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFB6BDC9),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

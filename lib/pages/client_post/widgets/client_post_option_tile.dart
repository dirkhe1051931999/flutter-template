import 'package:flutter/cupertino.dart';

class ClientPostOptionTile extends StatelessWidget {
  const ClientPostOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        height: 52,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEDEDED), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF3A3A3A)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 15),
            ),
            const SizedBox(width: 6),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Color(0xFFC8C8C8),
            ),
          ],
        ),
      ),
    );
  }
}

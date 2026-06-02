import 'package:flutter/cupertino.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({
    required this.age,
    required this.username,
    super.key,
  });

  final int age;
  final String username;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xB5FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x10FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                CupertinoIcons.person_crop_circle_fill,
                size: 32,
                color: Color(0xFF8B93A1),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username.isEmpty ? '未设置用户名' : username,
                    style: const TextStyle(
                      color: Color(0xFF1F2329),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '当前年龄 ${age < 0 ? '--' : age}',
                    style: const TextStyle(
                      color: Color(0xFF7D8695),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

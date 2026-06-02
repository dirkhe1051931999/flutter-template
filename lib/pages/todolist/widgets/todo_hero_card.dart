import 'package:flutter/cupertino.dart';

class TodoHeroCard extends StatelessWidget {
  const TodoHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xB4FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x10FFFFFF)),
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Redux TodoList',
              style: TextStyle(
                color: Color(0xFF1F2329),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '这里保留原来的增、删、清空逻辑，只把页面改成更轻的 iOS 风格，方便直接观察 store 和基础组件行为。',
              style: TextStyle(
                color: Color(0xFF77808F),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

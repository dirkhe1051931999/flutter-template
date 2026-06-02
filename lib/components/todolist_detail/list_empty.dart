import 'package:flutter/cupertino.dart';

class ListEmpytWidget extends StatelessWidget {
  const ListEmpytWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
      decoration: BoxDecoration(
        color: const Color(0xF7FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: const Column(
        children: [
          Icon(
            CupertinoIcons.square_list,
            size: 26,
            color: Color(0xFFAFB6C2),
          ),
          SizedBox(height: 10),
          Text(
            'empty',
            style: TextStyle(
              color: Color(0xFF87909F),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

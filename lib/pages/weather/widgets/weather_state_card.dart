import 'package:flutter/cupertino.dart';

class WeatherErrorCard extends StatelessWidget {
  const WeatherErrorCard({
    super.key,
    required this.errorText,
    required this.onRetry,
  });

  final String errorText;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x2EFFFFFF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '天气数据暂时加载失败',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            errorText,
            style: const TextStyle(
              color: Color(0xE6FFFFFF),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(999),
            onPressed: () {
              onRetry();
            },
            child: const Text(
              '重新加载',
              style: TextStyle(
                color: Color(0xFF2E7EF7),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherEmptyCard extends StatelessWidget {
  const WeatherEmptyCard({
    super.key,
    required this.onRetry,
  });

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      alignment: Alignment.centerLeft,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(999),
        onPressed: () {
          onRetry();
        },
        child: const Text(
          '重新获取天气',
          style: TextStyle(
            color: Color(0xFF2E7EF7),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

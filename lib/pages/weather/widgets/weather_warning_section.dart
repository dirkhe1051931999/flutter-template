import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:oolaf_flutted/model/weather/types/weather_warning.dart';

class WeatherWarningSection extends StatelessWidget {
  const WeatherWarningSection({
    super.key,
    required this.warning,
  });

  final WeatherWarningResponse warning;

  @override
  Widget build(BuildContext context) {
    if (!warning.hasAlerts) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '天气预警',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...warning.alerts.asMap().entries.map((entry) {
            return _WeatherWarningCard(
              alert: entry.value,
              isLast: entry.key == warning.alerts.length - 1,
            );
          }),
          if (warning.metadata.attributions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              warning.metadata.attributions.join(' '),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeatherWarningCard extends StatelessWidget {
  const _WeatherWarningCard({
    required this.alert,
    required this.isLast,
  });

  final WeatherWarningAlert alert;
  final bool isLast;

  String get _issuedTimeLabel {
    final issuedDateTime = alert.issuedDateTime;
    if (issuedDateTime == null) {
      return alert.issuedTime;
    }
    return DateFormat('MM/dd HH:mm').format(issuedDateTime);
  }

  String get _expireTimeLabel {
    final expireDateTime = alert.expireDateTime;
    if (expireDateTime == null) {
      return alert.expireTime;
    }
    return DateFormat('MM/dd HH:mm').format(expireDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Color.fromRGBO(
      alert.color.red,
      alert.color.green,
      alert.color.blue,
      alert.color.alpha.toDouble(),
    );

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _severityLabel(alert),
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  alert.headline.isEmpty ? '天气预警' : alert.headline,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (alert.senderName.isNotEmpty)
            Text(
              alert.senderName,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            '发布时间：$_issuedTimeLabel',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          if (alert.expireTime.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '失效时间：$_expireTimeLabel',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
          if (alert.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              alert.description,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
          if (alert.instruction.isNotEmpty) ...[
            const SizedBox(height: 10),
            _WarningBlock(
              title: '防御指南',
              content: alert.instruction,
            ),
          ],
        ],
      ),
    );
  }
}

class _WarningBlock extends StatelessWidget {
  const _WarningBlock({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

String _severityLabel(WeatherWarningAlert alert) {
  if (alert.headline.contains('红色')) {
    return '红色预警';
  }
  if (alert.headline.contains('橙色')) {
    return '橙色预警';
  }
  if (alert.headline.contains('黄色')) {
    return '黄色预警';
  }
  if (alert.headline.contains('蓝色')) {
    return '蓝色预警';
  }
  if (alert.eventType.name.isNotEmpty) {
    return '${alert.eventType.name}预警';
  }
  return '预警';
}

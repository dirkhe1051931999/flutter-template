import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:oolaf_flutted/model/weather/types/weather_indices_forecast.dart';

class WeatherIndicesSection extends StatelessWidget {
  const WeatherIndicesSection({
    super.key,
    required this.indices,
  });

  final List<WeatherIndicesForecast> indices;

  @override
  Widget build(BuildContext context) {
    if (indices.isEmpty) {
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
            '天气指数预报',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...indices.asMap().entries.map((entry) {
            return _WeatherIndicesRow(
              index: entry.key,
              forecast: entry.value,
              isLast: entry.key == indices.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _WeatherIndicesRow extends StatelessWidget {
  const _WeatherIndicesRow({
    required this.index,
    required this.forecast,
    required this.isLast,
  });

  final int index;
  final WeatherIndicesForecast forecast;
  final bool isLast;

  String get _dateLabel {
    final date = DateTime.tryParse(forecast.date);
    if (date == null) {
      return forecast.date;
    }
    return DateFormat('MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final description = forecast.text.isEmpty ? '暂无详细说明' : forecast.text;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9)),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _dateLabel,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  forecast.level.isEmpty ? '--' : forecast.level,
                  style: const TextStyle(
                    color: Color(0xFF2E7EF7),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  forecast.name,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  forecast.category.isEmpty ? '--' : forecast.category,
                  style: const TextStyle(
                    color: Color(0xFF2E7EF7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

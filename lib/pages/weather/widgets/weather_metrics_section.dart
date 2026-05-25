import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/weather/weather_icon.dart';
import 'package:oolaf_flutted/model/weather/index.dart';

class WeatherMetricsSection extends StatelessWidget {
  const WeatherMetricsSection({
    super.key,
    required this.today,
  });

  final WeatherDailyForecast today;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _WeatherMetricCard(
                title: '风力',
                value: '${today.windDirDay} ${today.windScaleDay}级',
                iconCode: '304',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WeatherMetricCard(
                title: '湿度',
                value: '${today.humidity}%',
                iconCode: '306',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WeatherMetricCard(
                title: '紫外线',
                value: today.uvIndex,
                iconCode: '100',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _WeatherMetricCard(
                title: '气压',
                value: '${today.pressure}hPa',
                iconCode: '104',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WeatherMetricCard(
                title: '能见度',
                value: '${today.vis}km',
                iconCode: '102',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WeatherMetricCard(
                title: '云量',
                value: today.cloud.isEmpty ? '--' : '${today.cloud}% ',
                iconCode: today.moonPhaseIcon.isEmpty ? '104' : today.moonPhaseIcon,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeatherMetricCard extends StatelessWidget {
  const _WeatherMetricCard({
    required this.title,
    required this.value,
    required this.iconCode,
  });

  final String title;
  final String value;
  final String iconCode;

  double get _valueFontSize {
    final compactValue = value.replaceAll(' ', '');
    if (compactValue.length >= 10) {
      return 14;
    }
    if (compactValue.length >= 8) {
      return 15;
    }
    if (compactValue.length >= 6) {
      return 16;
    }
    return 18;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 142,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          WeatherIcon(
            iconCode: iconCode,
            size: 22,
            color: const Color(0xFF2E7EF7),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: _valueFontSize,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

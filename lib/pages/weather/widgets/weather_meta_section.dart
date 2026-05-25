import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/weather/weather_icon.dart';
import 'package:oolaf_flutted/model/weather/index.dart';

class WeatherMetaSection extends StatelessWidget {
  const WeatherMetaSection({
    super.key,
    required this.weather,
    required this.today,
  });

  final WeatherDailyForecastResponse weather;
  final WeatherDailyForecast today;

  @override
  Widget build(BuildContext context) {
    final sources = weather.refer.sources.join(' / ');
    final license = weather.refer.license.join(' / ');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      padding: const EdgeInsets.all(18),
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
            '更多信息',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetaMetricCard(
                  title: '气压',
                  value: '${today.pressure}hPa',
                  iconCode: '104',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetaMetricCard(
                  title: '能见度',
                  value: '${today.vis}km',
                  iconCode: '102',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetaMetricCard(
                  title: '云量',
                  value: today.cloud.isEmpty ? '--' : '${today.cloud}%',
                  iconCode: today.moonPhaseIcon.isEmpty ? '104' : today.moonPhaseIcon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetaMetricCard(
                  title: '湿度',
                  value: '${today.humidity}%',
                  iconCode: '306',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetaMetricCard(
                  title: '月相',
                  value: today.moonPhase,
                  iconCode: today.moonPhaseIcon.isEmpty ? '804' : today.moonPhaseIcon,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetaMetricCard(
                  title: '露点/紫外线',
                  value: '${today.uvIndex}级',
                  iconCode: '100',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoLine(label: 'fxLink', value: weather.fxLink),
          _InfoLine(label: '数据来源', value: sources.isEmpty ? '--' : sources),
          _InfoLine(label: '许可说明', value: license.isEmpty ? '--' : license),
        ],
      ),
    );
  }
}

class _MetaMetricCard extends StatelessWidget {
  const _MetaMetricCard({
    required this.title,
    required this.value,
    required this.iconCode,
  });

  final String title;
  final String value;
  final String iconCode;

  bool _willOverflowSingleLine({
    required String text,
    required TextStyle style,
    required double maxWidth,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return textPainter.didExceedMaxLines || textPainter.width > maxWidth;
  }

  @override
  Widget build(BuildContext context) {
    const baseValueStyle = TextStyle(
      color: Color(0xFF111827),
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final safeValue = value.isEmpty ? '--' : value;
        final contentWidth = constraints.maxWidth - 28;
        final shouldReduceFontSize = _willOverflowSingleLine(
          text: safeValue,
          style: baseValueStyle,
          maxWidth: contentWidth,
        );

        return Container(
          height: 132,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WeatherIcon(
                iconCode: iconCode,
                size: 20,
                color: const Color(0xFF2E7EF7),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    safeValue,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: baseValueStyle.copyWith(
                      fontSize: shouldReduceFontSize ? 15 : 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

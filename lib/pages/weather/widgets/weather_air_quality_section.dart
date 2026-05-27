import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/model/weather/types/weather_air_quality.dart';

class WeatherAirQualitySection extends StatelessWidget {
  const WeatherAirQualitySection({
    super.key,
    required this.airQuality,
  });

  final WeatherAirQualityResponse airQuality;

  @override
  Widget build(BuildContext context) {
    final primaryIndex = airQuality.primaryIndex;
    final pollutants = airQuality.pollutants.take(4).toList();
    final cardColor = _resolveAqiColor(primaryIndex);

    if (primaryIndex == null && pollutants.isEmpty) {
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
            '空气质量',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (primaryIndex != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        primaryIndex.aqiDisplay.isEmpty ? '--' : primaryIndex.aqiDisplay,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          primaryIndex.name.isEmpty ? 'AQI' : primaryIndex.name,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          primaryIndex.category.isEmpty ? '--' : primaryIndex.category,
                          style: TextStyle(
                            color: cardColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          primaryIndex.primaryPollutant.name.isEmpty
                              ? '首要污染物：--'
                              : '首要污染物：${primaryIndex.primaryPollutant.name}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                        if (primaryIndex.health.effect.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            primaryIndex.health.effect,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (pollutants.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: pollutants.map((pollutant) {
                return _PollutantChip(pollutant: pollutant);
              }).toList(),
            ),
          if (primaryIndex != null &&
              primaryIndex.health.advice.generalPopulation.isNotEmpty) ...[
            const SizedBox(height: 14),
            _AdviceCard(
              title: '出行建议',
              content: primaryIndex.health.advice.generalPopulation,
            ),
          ],
        ],
      ),
    );
  }
}

class _PollutantChip extends StatelessWidget {
  const _PollutantChip({
    required this.pollutant,
  });

  final WeatherAirQualityPollutant pollutant;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pollutant.name,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pollutant.displayConcentration,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
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
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

Color _resolveAqiColor(WeatherAirQualityIndex? index) {
  if (index == null) {
    return const Color(0xFF2E7EF7);
  }

  return Color.fromRGBO(
    index.color.red,
    index.color.green,
    index.color.blue,
    index.color.alpha.toDouble(),
  );
}

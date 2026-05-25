import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:oolaf_flutted/components/weather/weather_icon.dart';
import 'package:oolaf_flutted/model/weather/index.dart';

class WeatherHeroSection extends StatelessWidget {
  const WeatherHeroSection({
    super.key,
    required this.city,
    required this.today,
    required this.updateTime,
    required this.hourlyForecasts,
    required this.onChooseCity,
  });

  final WeatherCity city;
  final WeatherDailyForecast today;
  final String updateTime;
  final List<WeatherHourlyForecast> hourlyForecasts;
  final VoidCallback onChooseCity;

  String get _displayUpdateTime {
    if (updateTime.isEmpty) {
      return '--:--';
    }
    final dateTime = DateTime.tryParse(updateTime);
    if (dateTime == null) {
      return updateTime;
    }
    return DateFormat('HH:mm').format(dateTime.toLocal());
  }

  int get _currentTemp {
    if (hourlyForecasts.isNotEmpty) {
      return int.tryParse(hourlyForecasts.first.temp) ?? 0;
    }
    return ((int.tryParse(today.tempMax) ?? 0) + (int.tryParse(today.tempMin) ?? 0)) ~/
        2;
  }

  String get _nextTwoHoursRainText {
    final nextTwoHours = hourlyForecasts.take(2).toList();
    if (nextTwoHours.isEmpty) {
      return '未来2小时暂无降雨数据';
    }

    final rainingHours = nextTwoHours.where((hour) {
      final pop = int.tryParse(hour.pop) ?? 0;
      final precip = double.tryParse(hour.precip) ?? 0;
      return pop > 0 || precip > 0;
    }).toList();

    if (rainingHours.isEmpty) {
      return '未来2小时大概率不下雨';
    }

    final maxPop = rainingHours
        .map((hour) => int.tryParse(hour.pop) ?? 0)
        .fold<int>(0, (previousValue, element) => element > previousValue ? element : previousValue);
    final totalPrecip = rainingHours
        .map((hour) => double.tryParse(hour.precip) ?? 0)
        .fold<double>(0, (previousValue, element) => previousValue + element);

    return '未来2小时可能降雨，最高概率$maxPop% · 约${totalPrecip.toStringAsFixed(1)}mm';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: onChooseCity,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x38FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      city.name,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      CupertinoIcons.chevron_down,
                      color: CupertinoColors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Text(
              '更新 $_displayUpdateTime',
              style: const TextStyle(
                color: Color(0xCCFFFFFF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${city.city} · ${city.province}',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${today.textDay} · 夜间${today.textNight} · 降水 ${today.precip}mm',
                    style: const TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$_currentTemp',
                          style: const TextStyle(
                            fontSize: 72,
                            height: 1,
                            fontWeight: FontWeight.w200,
                            color: CupertinoColors.white,
                          ),
                        ),
                        const TextSpan(
                          text: '°',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${today.tempMax}° / ${today.tempMin}°C',
                    style: const TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            WeatherIcon(
              iconCode: hourlyForecasts.isNotEmpty ? hourlyForecasts.first.icon : today.iconDay,
              size: 64,
              color: CupertinoColors.white,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0x29FFFFFF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.cloud_rain,
                color: CupertinoColors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _nextTwoHoursRainText,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

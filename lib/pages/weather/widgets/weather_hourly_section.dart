import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:oolaf_flutted/components/weather/weather_icon.dart';
import 'package:oolaf_flutted/model/weather/index.dart';

class WeatherHourlySection extends StatelessWidget {
  const WeatherHourlySection({
    super.key,
    required this.hourlyForecasts,
  });

  final List<WeatherHourlyForecast> hourlyForecasts;

  @override
  Widget build(BuildContext context) {
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
            '24小时天气',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 132,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.invertedStylus,
                },
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: hourlyForecasts.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 10);
                },
                itemBuilder: (context, index) {
                  return _HourlyForecastCard(forecast: hourlyForecasts[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyForecastCard extends StatelessWidget {
  const _HourlyForecastCard({
    required this.forecast,
  });

  final WeatherHourlyForecast forecast;

  String get _timeLabel {
    final dateTime = forecast.dateTime;
    if (dateTime == null) {
      return '--:--';
    }
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _timeLabel,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          WeatherIcon(
            iconCode: forecast.icon,
            size: 28,
            color: const Color(0xFF2E7EF7),
          ),
          Text(
            '${forecast.temp}°',
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            forecast.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:oolaf_flutted/components/weather/weather_icon.dart';
import 'package:oolaf_flutted/model/weather/index.dart';

class WeatherForecastSection extends StatelessWidget {
  const WeatherForecastSection({
    super.key,
    required this.forecasts,
    required this.activeRange,
    required this.onToggleRange,
    required this.isLoadingMore,
  });

  final List<WeatherDailyForecast> forecasts;
  final String activeRange;
  final Future<void> Function() onToggleRange;
  final bool isLoadingMore;

  String get _titleLabel {
    return '未来${activeRange.replaceAll('d', '')}天';
  }

  String get _buttonLabel {
    switch (activeRange) {
      case '3d':
        return '展开到未来7天';
      case '7d':
        return '展开到未来10天';
      case '10d':
        return '展开到未来15天';
      case '15d':
        return '展开到未来30天';
      case '30d':
        return '收起到未来3天';
      default:
        return '展开更多';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  _titleLabel,
                  style: CupertinoTheme.of(context)
                      .textTheme
                      .navLargeTitleTextStyle
                      .copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(32, 32),
                borderRadius: BorderRadius.circular(999),
                color: const Color(0xFFF0F7FF),
                onPressed: isLoadingMore ? null : onToggleRange,
                child: isLoadingMore
                    ? const CupertinoActivityIndicator(radius: 7)
                    : Text(
                        _buttonLabel,
                        style: const TextStyle(
                          color: Color(0xFF2E7EF7),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...forecasts.asMap().entries.map((entry) {
            return _WeatherForecastRow(
              index: entry.key,
              forecast: entry.value,
            );
          }),
        ],
      ),
    );
  }
}

class _WeatherForecastRow extends StatelessWidget {
  const _WeatherForecastRow({
    required this.index,
    required this.forecast,
  });

  final int index;
  final WeatherDailyForecast forecast;

  String get _dayLabel {
    if (index == 0) {
      return '今天';
    }
    if (index == 1) {
      return '明天';
    }
    final date = DateTime.tryParse(forecast.fxDate);
    if (date == null) {
      return forecast.fxDate;
    }
    const weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekDays[date.weekday - 1];
  }

  String get _dateLabel {
    final date = DateTime.tryParse(forecast.fxDate);
    if (date == null) {
      return forecast.fxDate;
    }
    return DateFormat('MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dayLabel,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dateLabel,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          WeatherIcon(
            iconCode: forecast.iconDay,
            size: 26,
            color: const Color(0xFF2E7EF7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${forecast.textDay} / ${forecast.textNight}',
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${forecast.windDirDay} ${forecast.windScaleDay}级 · 降水${forecast.precip}mm',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${forecast.tempMax}°',
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${forecast.tempMin}°',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

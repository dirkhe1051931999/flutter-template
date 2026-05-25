import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/weather/index.dart';
import 'package:oolaf_flutted/model/weather/index.dart';
import 'package:oolaf_flutted/pages/weather/weather_city_search_page.dart';
import 'package:oolaf_flutted/pages/weather/widgets/weather_forecast_section.dart';
import 'package:oolaf_flutted/pages/weather/widgets/weather_hero_section.dart';
import 'package:oolaf_flutted/pages/weather/widgets/weather_hourly_section.dart';
import 'package:oolaf_flutted/pages/weather/widgets/weather_meta_section.dart';
import 'package:oolaf_flutted/pages/weather/widgets/weather_state_card.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with SingleTickerProviderStateMixin {
  WeatherCity _activeCity = WeatherCityCatalog.xian;
  Future<WeatherDashboardData>? _weatherFuture;
  late final AnimationController _refreshAnimationController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _weatherFuture = _loadWeather(_activeCity);
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    super.dispose();
  }

  Future<WeatherDashboardData> _loadWeather(WeatherCity city) async {
    final responses = await Future.wait([
      getWeatherDailyForecast(city: city),
      getWeatherHourlyForecast(city: city),
    ]);

    final dailyResponse = responses[0] as WeatherDailyForecastResponse;
    final hourlyResponse = responses[1] as WeatherHourlyForecastResponse;

    final now = DateTime.now();
    final currentHour = DateTime(now.year, now.month, now.day, now.hour);
    final filteredHourly = hourlyResponse.hourly.where((hour) {
      final dateTime = hour.dateTime;
      if (dateTime == null) {
        return false;
      }
      return !dateTime.isBefore(currentHour);
    }).take(24).toList();

    return WeatherDashboardData(
      daily: dailyResponse,
      hourly: hourlyResponse,
      visibleHourly: filteredHourly,
    );
  }

  Future<void> _refresh() async {
    final future = _loadWeather(_activeCity);
    setState(() {
      _isRefreshing = true;
      _weatherFuture = future;
    });
    _refreshAnimationController.repeat();
    await future;
    if (!mounted) {
      return;
    }
    _refreshAnimationController.stop();
    _refreshAnimationController.reset();
    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> _openCitySearchPage() async {
    final selectedCity = await Navigator.of(context).push<WeatherCity>(
      CupertinoPageRoute(
        builder: (context) {
          return WeatherCitySearchPage(currentCity: _activeCity);
        },
      ),
    );
    if (!mounted || selectedCity == null) {
      return;
    }
    if (selectedCity.locationCode == _activeCity.locationCode) {
      return;
    }
    setState(() {
      _isRefreshing = true;
      _activeCity = selectedCity;
      _weatherFuture = _loadWeather(selectedCity);
    });
    _refreshAnimationController.repeat();
    await _weatherFuture;
    if (!mounted) {
      return;
    }
    _refreshAnimationController.stop();
    _refreshAnimationController.reset();
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      child: FutureBuilder<WeatherDashboardData>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          final dashboard = snapshot.data;
          final weather = dashboard?.daily;
          final hourly = dashboard?.visibleHourly ?? const <WeatherHourlyForecast>[];
          final today = weather?.daily.isNotEmpty == true ? weather!.daily.first : null;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                    child: Row(
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          minimumSize: const Size(32, 32),
                          onPressed: () {
                            Navigator.of(context).maybePop();
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.back,
                                color: Color(0xFF5856D6),
                                size: 20,
                              ),
                              SizedBox(width: 2),
                              Text(
                                '首页',
                                style: TextStyle(
                                  color: Color(0xFF5856D6),
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(28, 28),
                          onPressed: _isRefreshing ? null : _refresh,
                          child: RotationTransition(
                            turns: _refreshAnimationController,
                            child: Icon(
                              CupertinoIcons.refresh,
                              color: _isRefreshing
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF5856D6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2E7EF7),
                        Color(0xFF49B3FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x332E7EF7),
                        blurRadius: 28,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          dashboard == null)
                        const SizedBox(
                          height: 220,
                          child: Center(
                            child: CupertinoActivityIndicator(
                              color: CupertinoColors.white,
                            ),
                          ),
                        )
                      else if (snapshot.hasError)
                        WeatherErrorCard(
                          errorText: '${snapshot.error}',
                          onRetry: _refresh,
                        )
                      else if (today != null)
                        WeatherHeroSection(
                          city: _activeCity,
                          today: today,
                          updateTime: weather?.updateTime ?? '',
                          hourlyForecasts: hourly,
                          onChooseCity: _openCitySearchPage,
                        )
                      else
                        WeatherEmptyCard(onRetry: _refresh),
                    ],
                  ),
                ),
              ),
              if (weather != null && today != null) ...[
                if (hourly.isNotEmpty)
                  SliverToBoxAdapter(
                    child: WeatherHourlySection(hourlyForecasts: hourly),
                  ),
                SliverToBoxAdapter(
                  child: WeatherForecastSection(forecasts: weather.daily),
                ),
                SliverToBoxAdapter(
                  child: WeatherMetaSection(
                    weather: weather,
                    today: today,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class WeatherDashboardData {
  const WeatherDashboardData({
    required this.daily,
    required this.hourly,
    required this.visibleHourly,
  });

  final WeatherDailyForecastResponse daily;
  final WeatherHourlyForecastResponse hourly;
  final List<WeatherHourlyForecast> visibleHourly;
}

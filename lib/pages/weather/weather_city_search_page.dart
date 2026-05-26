import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/model/weather/index.dart';
import 'package:oolaf_flutted/repositories/weather_city_repository.dart';

class WeatherCitySearchPage extends StatefulWidget {
  const WeatherCitySearchPage({
    super.key,
    required this.currentCity,
  });

  final WeatherCity currentCity;

  @override
  State<WeatherCitySearchPage> createState() => _WeatherCitySearchPageState();
}

class _WeatherCitySearchPageState extends State<WeatherCitySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final WeatherCityRepository _cityRepository = WeatherCityRepository.instance;
  List<WeatherCity> _visibleCities = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialCities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialCities() async {
    final cities = await _cityRepository.searchCities('');
    if (!mounted) {
      return;
    }
    setState(() {
      _visibleCities = cities;
      _isLoading = false;
    });
  }

  Future<void> _handleKeywordChanged(String keyword) async {
    setState(() {
      _isLoading = true;
    });
    final cities = await _cityRepository.searchCities(keyword);
    if (!mounted) {
      return;
    }
    setState(() {
      _visibleCities = cities;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('选择城市'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: '搜索城市 / 拼音 / 行政区划',
                onChanged: _handleKeywordChanged,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _visibleCities.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 10);
                      },
                      itemBuilder: (context, index) {
                        final city = _visibleCities[index];
                        final isSelected = city.locationCode == widget.currentCity.locationCode;
                        return CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.of(context).pop(city);
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2E7EF7)
                                    : const Color(0x14000000),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        city.name,
                                        style: const TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${city.province} · ${city.city} · ${city.locationCode}',
                                        style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const AppAssetIcon(
                                    assetName: 'checkmark-circle',
                                    color: Color(0xFF2E7EF7),
                                    size: 22,
                                    fallbackIcon: CupertinoIcons.check_mark_circled_solid,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

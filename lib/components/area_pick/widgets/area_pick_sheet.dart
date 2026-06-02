import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/area_pick/widgets/area_pick_column.dart';
import 'package:oolaf_flutted/components/area_pick/widgets/area_pick_header.dart';
import 'package:oolaf_flutted/components/area_pick/widgets/area_pick_preview_card.dart';
import 'package:oolaf_flutted/model/area/area_item.dart';

class AreaPickSheet extends StatefulWidget {
  const AreaPickSheet({
    super.key,
    required this.items,
    required this.initialSelection,
    required this.levelCount,
  });

  final List<AreaItem> items;
  final AreaSelection initialSelection;
  final int levelCount;

  @override
  State<AreaPickSheet> createState() => _AreaPickSheetState();
}

class _AreaPickSheetState extends State<AreaPickSheet> {
  late AreaSelection _selection;

  @override
  void initState() {
    super.initState();
    _selection = _normalizeSelection(widget.items, widget.initialSelection);
  }

  List<AreaItem> get _provinces => widget.items;

  List<AreaItem> get _cities =>
      _selection.province?.children ?? const <AreaItem>[];

  List<AreaItem> get _counties =>
      _selection.city?.children ?? const <AreaItem>[];

  List<AreaItem> get _towns =>
      _selection.county?.children ?? const <AreaItem>[];

  int get _safeLevelCount => widget.levelCount.clamp(2, 4);

  void _selectProvince(AreaItem province) {
    final city = province.children.isNotEmpty ? province.children.first : null;
    final county =
        city?.children.isNotEmpty == true ? city!.children.first : null;
    final town =
        county?.children.isNotEmpty == true ? county!.children.first : null;

    setState(() {
      _selection = AreaSelection(
        province: province,
        city: city,
        county: county,
        town: town,
      );
    });
  }

  void _selectCity(AreaItem city) {
    final county = city.children.isNotEmpty ? city.children.first : null;
    final town =
        county?.children.isNotEmpty == true ? county!.children.first : null;

    setState(() {
      _selection = _selection.copyWith(
        city: city,
        county: county,
        town: town,
      );
    });
  }

  void _selectCounty(AreaItem county) {
    final town = county.children.isNotEmpty ? county.children.first : null;

    setState(() {
      _selection = _selection.copyWith(
        county: county,
        town: town,
      );
    });
  }

  void _selectTown(AreaItem town) {
    setState(() {
      _selection = _selection.copyWith(town: town);
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0x19000000),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xF7F9FBFF),
                    Color(0xFFF3F6FD),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, safeBottom + 14),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.78,
                    child: Column(
                      children: [
                        Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4DAE5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AreaPickHeader(
                          title: '选择地区',
                          subtitle: '参考 iOS 风格的多级联动选择器',
                          onCancel: () => Navigator.of(context).pop(),
                          onConfirm: () =>
                              Navigator.of(context).pop(_selection),
                        ),
                        const SizedBox(height: 16),
                        AreaPickPreviewCard(
                          selection: _selection,
                          levelCount: _safeLevelCount,
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AreaPickColumn(
                                title: '省份',
                                items: _provinces,
                                selectedCode: _selection.province?.code,
                                onSelected: _selectProvince,
                              ),
                              if (_safeLevelCount >= 2) ...[
                                const SizedBox(width: 8),
                                AreaPickColumn(
                                  title: '城市',
                                  items: _cities,
                                  selectedCode: _selection.city?.code,
                                  onSelected: _selectCity,
                                ),
                              ],
                              if (_safeLevelCount >= 3) ...[
                                const SizedBox(width: 8),
                                AreaPickColumn(
                                  title: '区县',
                                  items: _counties,
                                  selectedCode: _selection.county?.code,
                                  onSelected: _selectCounty,
                                ),
                              ],
                              if (_safeLevelCount >= 4) ...[
                                const SizedBox(width: 8),
                                AreaPickColumn(
                                  title: '乡镇',
                                  items: _towns,
                                  selectedCode: _selection.town?.code,
                                  onSelected: _selectTown,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AreaSelection _normalizeSelection(
    List<AreaItem> provinces,
    AreaSelection initialSelection,
  ) {
    final fallbackProvince = provinces.isNotEmpty ? provinces.first : null;
    final province = _findByCode(provinces, initialSelection.province?.code) ??
        fallbackProvince;
    final cities = province?.children ?? const <AreaItem>[];
    final fallbackCity = cities.isNotEmpty ? cities.first : null;
    final city =
        _findByCode(cities, initialSelection.city?.code) ?? fallbackCity;
    final counties = city?.children ?? const <AreaItem>[];
    final fallbackCounty = counties.isNotEmpty ? counties.first : null;
    final county =
        _findByCode(counties, initialSelection.county?.code) ?? fallbackCounty;
    final towns = county?.children ?? const <AreaItem>[];
    final fallbackTown = towns.isNotEmpty ? towns.first : null;
    final town =
        _findByCode(towns, initialSelection.town?.code) ?? fallbackTown;

    return AreaSelection(
      province: province,
      city: city,
      county: county,
      town: town,
    );
  }

  AreaItem? _findByCode(List<AreaItem> items, String? code) {
    if (code == null || code.isEmpty) {
      return null;
    }
    for (final item in items) {
      if (item.code == code) {
        return item;
      }
    }
    return null;
  }
}

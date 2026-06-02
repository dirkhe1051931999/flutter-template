import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/area_pick/index.dart';
import 'package:oolaf_flutted/model/area/area_item.dart';

class AreaPickDemoPage extends StatefulWidget {
  const AreaPickDemoPage({super.key});

  @override
  State<AreaPickDemoPage> createState() => _AreaPickDemoPageState();
}

class _AreaPickDemoPageState extends State<AreaPickDemoPage> {
  AreaSelection _selection = const AreaSelection();
  int _levelCount = 4;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '基于本地 `pcas-code.json` 的多级联动，字段和弹层拆分为独立子组件。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础用法',
          subtitle: '点击卡片拉起类似 Vant Area 的底部级联选择器，并支持控制联动级数。',
          child: Column(
            children: [
              _LevelCountSelector(
                value: _levelCount,
                onChanged: (value) {
                  setState(() {
                    _levelCount = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              AreaPickField(
                value: _selection,
                levelCount: _levelCount,
                placeholder: _placeholderForLevelCount(_levelCount),
                helperText:
                    '已选择 code: ${_selection.codeUpTo(_levelCount) ?? '-'}',
                onChanged: (value) {
                  setState(() {
                    _selection = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '结果展示',
          subtitle: '页面只消费强类型结果，不直接使用原始 JSON。',
          child: _ResultCard(
            selection: _selection,
            levelCount: _levelCount,
          ),
        ),
      ],
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF8F96A3),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    const items = [
      '支持 2 到 4 级联动，切换上级时自动联动下级。',
      '选中结果回传 `AreaSelection`，页面层只拿强类型对象。',
      '资源读取带缓存，首次加载后复用内存数据。',
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.selection,
    required this.levelCount,
  });

  final AreaSelection selection;
  final int levelCount;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('省份', selection.province?.name ?? '-'),
      if (levelCount >= 2) ('城市', selection.city?.name ?? '-'),
      if (levelCount >= 3) ('区县', selection.county?.name ?? '-'),
      if (levelCount >= 4) ('乡镇', selection.town?.name ?? '-'),
      ('编码', selection.codeUpTo(levelCount) ?? '-'),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          children: rows
              .map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 52,
                        child: Text(
                          row.$1,
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          row.$2,
                          style: const TextStyle(
                            color: Color(0xFF202127),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _LevelCountSelector extends StatelessWidget {
  const _LevelCountSelector({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '联动级数',
          style: TextStyle(
            color: Color(0xFF667085),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        CupertinoSlidingSegmentedControl<int>(
          groupValue: value,
          children: const {
            2: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text('省市'),
            ),
            3: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text('省市区'),
            ),
            4: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text('省市区镇'),
            ),
          },
          onValueChanged: (next) {
            if (next != null) {
              onChanged(next);
            }
          },
        ),
      ],
    );
  }
}

String _placeholderForLevelCount(int levelCount) {
  return switch (levelCount) {
    2 => '请选择省 / 市',
    3 => '请选择省 / 市 / 区县',
    _ => '请选择省 / 市 / 区县 / 乡镇',
  };
}

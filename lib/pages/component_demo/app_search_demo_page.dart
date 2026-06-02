import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_search/app_search_types.dart';
import 'package:oolaf_flutted/components/app_search/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class AppSearchDemoPage extends StatefulWidget {
  const AppSearchDemoPage({super.key});

  @override
  State<AppSearchDemoPage> createState() => _AppSearchDemoPageState();
}

class _AppSearchDemoPageState extends State<AppSearchDemoPage> {
  String _keyword = '';
  AppSearchShape _shape = AppSearchShape.round;
  bool _showAction = true;
  bool _error = false;
  bool _readonly = false;
  bool _disabled = false;

  @override
  Widget build(BuildContext context) {
    final errorMessage = _error && _keyword.trim().isEmpty ? '请输入搜索关键词' : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Search，用 Cupertino 语义重做成更接近 iOS 26 的搜索输入。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础示例',
          subtitle: '支持 round / square、取消按钮、格式化、错误态、只读与禁用状态。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSearch(
                value: _keyword,
                label: '搜索',
                placeholder: '搜索球员、文章、城市或组件',
                shape: _shape,
                showAction: _showAction,
                actionText: '取消',
                error: _error,
                errorMessage: errorMessage,
                readOnly: _readonly,
                disabled: _disabled,
                rightIcon: CupertinoIcons.slider_horizontal_3,
                formatter: (value) => value.replaceAll(RegExp(r'\s+'), ' '),
                onChanged: (value) {
                  setState(() {
                    _keyword = value;
                  });
                },
                onSearch: (value) {
                  final message = value.trim().isEmpty ? '当前没有输入内容' : '搜索: $value';
                  AppToast.showText(message);
                },
                onActionTap: () {
                  setState(() {
                    _keyword = '';
                    _error = false;
                  });
                },
                onClear: () {
                  setState(() {
                    _keyword = '';
                    _error = false;
                  });
                },
                onTapRightIcon: () {
                  AppToast.showText('这里可以接筛选面板');
                },
              ),
              const SizedBox(height: 16),
              const _SegmentTitle(label: '搜索框形状'),
              const SizedBox(height: 10),
              CupertinoSlidingSegmentedControl<AppSearchShape>(
                groupValue: _shape,
                children: const {
                  AppSearchShape.round: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('round'),
                  ),
                  AppSearchShape.square: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('square'),
                  ),
                },
                onValueChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _shape = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _SwitchRow(
                label: '显示取消按钮',
                value: _showAction,
                onChanged: (value) {
                  setState(() {
                    _showAction = value;
                  });
                },
              ),
              _SwitchRow(
                label: '错误态',
                value: _error,
                onChanged: (value) {
                  setState(() {
                    _error = value;
                  });
                },
              ),
              _SwitchRow(
                label: '只读',
                value: _readonly,
                onChanged: (value) {
                  setState(() {
                    _readonly = value;
                  });
                },
              ),
              _SwitchRow(
                label: '禁用',
                value: _disabled,
                onChanged: (value) {
                  setState(() {
                    _disabled = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: 'Example',
          subtitle: '一个偏内容流入口的搜索头，适合放在首页、列表页或频道页。',
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF6FAFF),
                  Color(0xFFEFF4FF),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0x12000000)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Discover',
                    style: TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '带一点玻璃质感和轻阴影，适合 iOS 风格首屏搜索入口。',
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppSearch(
                    value: _keyword,
                    placeholder: '搜索今日热点、比赛、城市天气',
                    shape: AppSearchShape.round,
                    showAction: false,
                    background: const Color(0x66FFFFFF),
                    inputAlign: AppSearchTextAlign.left,
                    onChanged: (value) {
                      setState(() {
                        _keyword = value;
                      });
                    },
                    onSearch: (value) {
                      AppToast.showText(value.isEmpty ? '请先输入关键词' : '进入结果页: $value');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '当前状态',
          subtitle: '页面层只消费结构化状态，不直接处理输入框内部实现细节。',
          child: _ResultCard(
            keyword: _keyword,
            shape: _shape,
            showAction: _showAction,
            error: _error,
            readonly: _readonly,
            disabled: _disabled,
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
      '参数命名对齐 Vant Search，覆盖 value、label、shape、clear、action、error 等常用能力。',
      '默认基于 CupertinoTextField，交互、按钮和层次更偏 iOS，而不是 Material 搜索栏。',
      '支持 formatter、focus 清除策略、左右图标、只读/禁用、搜索提交和取消动作。',
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

class _SegmentTitle extends StatelessWidget {
  const _SegmentTitle({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF667085),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF202127),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CupertinoSwitch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.keyword,
    required this.shape,
    required this.showAction,
    required this.error,
    required this.readonly,
    required this.disabled,
  });

  final String keyword;
  final AppSearchShape shape;
  final bool showAction;
  final bool error;
  final bool readonly;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('keyword', keyword.isEmpty ? '-' : keyword),
      ('shape', shape.name),
      ('showAction', '$showAction'),
      ('error', '$error'),
      ('readonly', '$readonly'),
      ('disabled', '$disabled'),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 88,
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
                            height: 1.4,
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

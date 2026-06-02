import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_stepper/index.dart';

class AppStepperDemoPage extends StatefulWidget {
  const AppStepperDemoPage({super.key});

  @override
  State<AppStepperDemoPage> createState() => _AppStepperDemoPageState();
}

class _AppStepperDemoPageState extends State<AppStepperDemoPage> {
  num _value = 2;
  num _decimalValue = 1.5;
  bool _disableInput = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Stepper，支持最小值、最大值、步长、整数和小数精度。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础示例',
          subtitle: '支持 min/max/step/integer/disable-input，适合购物车和表单数量选择。',
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '商品数量',
                      style: TextStyle(
                        color: Color(0xFF202127),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AppStepper(
                    value: _value,
                    min: 1,
                    max: 9,
                    integer: true,
                    disableInput: _disableInput,
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '配送重量',
                      style: TextStyle(
                        color: Color(0xFF202127),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AppStepper(
                    value: _decimalValue,
                    min: 0.5,
                    max: 5,
                    step: 0.5,
                    decimalLength: 1,
                    themeColor: const Color(0xFF0EA5E9),
                    onChanged: (value) {
                      setState(() {
                        _decimalValue = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'disable-input',
                      style: TextStyle(
                        color: Color(0xFF202127),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CupertinoSwitch(
                    value: _disableInput,
                    onChanged: (value) {
                      setState(() {
                        _disableInput = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: 'Example',
          subtitle: '更像电商结算卡片里的数量编辑场景。',
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cold Brew',
                          style: TextStyle(
                            color: Color(0xFF202127),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '瓶装冷萃咖啡，适合早晨和通勤场景',
                          style: TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppStepper(
                    value: _value,
                    min: 1,
                    max: 9,
                    integer: true,
                    themeColor: const Color(0xFF7C3AED),
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                      });
                    },
                  ),
                ],
              ),
            ),
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
      '支持 value、min、max、step、integer、decimalLength、disableInput。',
      '既能点按加减，也支持直接输入，失焦后会自动归一化到合法范围。',
      '适合购物车、库存数量、重量和规格类表单输入。',
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

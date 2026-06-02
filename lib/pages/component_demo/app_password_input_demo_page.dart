import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_password_input/index.dart';

class AppPasswordInputDemoPage extends StatefulWidget {
  const AppPasswordInputDemoPage({super.key});

  @override
  State<AppPasswordInputDemoPage> createState() => _AppPasswordInputDemoPageState();
}

class _AppPasswordInputDemoPageState extends State<AppPasswordInputDemoPage> {
  String _value = '12';
  bool _mask = true;
  bool _focused = true;
  bool _error = false;

  void _appendDigit(String digit) {
    if (_value.length >= 6) {
      return;
    }
    setState(() {
      _value = '$_value$digit';
      _error = false;
    });
  }

  void _removeDigit() {
    if (_value.isEmpty) {
      return;
    }
    setState(() {
      _value = _value.substring(0, _value.length - 1);
      _error = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final errorInfo = _error ? '请输入完整的 6 位支付密码' : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant PasswordInput，适合支付密码、验证码或 PIN 输入场景。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础示例',
          subtitle: '支持 length、gutter、mask、focused、info、errorInfo。',
          child: Column(
            children: [
              AppPasswordInput(
                value: _value,
                length: 6,
                mask: _mask,
                focused: _focused,
                info: '密码为 6 位数字',
                errorInfo: errorInfo,
                onTap: () {
                  setState(() {
                    _focused = true;
                  });
                },
              ),
              const SizedBox(height: 16),
              _SwitchRow(
                label: 'mask',
                value: _mask,
                onChanged: (value) {
                  setState(() {
                    _mask = value;
                  });
                },
              ),
              _SwitchRow(
                label: 'focused',
                value: _focused,
                onChanged: (value) {
                  setState(() {
                    _focused = value;
                  });
                },
              ),
              _SwitchRow(
                label: 'error',
                value: _error,
                onChanged: (value) {
                  setState(() {
                    _error = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: 'Example',
          subtitle: '附带一个简化数字键盘，用来模拟支付密码输入流程。',
          child: Column(
            children: [
              AppPasswordInput(
                value: _value,
                length: 6,
                mask: true,
                focused: true,
                info: '点击下方数字键盘输入',
                errorInfo: errorInfo,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final digit in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'])
                    _KeyButton(
                      label: digit,
                      onTap: () => _appendDigit(digit),
                    ),
                  _KeyButton(
                    label: '退格',
                    onTap: _removeDigit,
                  ),
                  _KeyButton(
                    label: '校验',
                    onTap: () {
                      setState(() {
                        _error = _value.length != 6;
                      });
                    },
                  ),
                ],
              ),
            ],
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
      '支持 value、length、gutter、mask、focused、info、errorInfo。',
      '组件本身只负责展示密码格子，不内置键盘，符合 Vant PasswordInput 的职责边界。',
      '适合支付密码、短信验证码、PIN 码等强结构输入。',
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
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(18),
        ),
        child: SizedBox(
          width: 76,
          height: 46,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_field/app_field_controller.dart';
import 'package:oolaf_flutted/components/app_field/app_field_types.dart';
import 'package:oolaf_flutted/components/app_field/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class AppFieldDemoPage extends StatefulWidget {
  const AppFieldDemoPage({super.key});

  @override
  State<AppFieldDemoPage> createState() => _AppFieldDemoPageState();
}

class _AppFieldDemoPageState extends State<AppFieldDemoPage> {
  final AppFieldController _nameController = AppFieldController();
  final AppFieldController _amountController = AppFieldController();
  final AppFieldController _bioController = AppFieldController();

  String _name = '';
  String _phone = '';
  String _amount = '';
  String _bio = '';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Field，做成 iOS 风格表单输入组件。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础表单',
          subtitle:
              '覆盖 label、placeholder、clear、error、word limit、readonly、is-link 等高频能力。',
          child: Column(
            children: [
              AppField(
                controller: _nameController,
                value: _name,
                label: '姓名',
                placeholder: '请输入姓名',
                required: true,
                colon: true,
                clearable: true,
                showWordLimit: true,
                maxLength: 20,
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
                rules: const [
                  AppFieldRule(
                    required: true,
                    message: '姓名不能为空',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppField(
                value: _phone,
                label: '手机号',
                placeholder: '请输入 11 位手机号',
                type: AppFieldType.digit,
                clearable: true,
                maxLength: 11,
                onChanged: (value) {
                  setState(() {
                    _phone = value;
                  });
                },
                rules: [
                  const AppFieldRule(
                    required: true,
                    message: '手机号不能为空',
                  ),
                  AppFieldRule(
                    pattern: RegExp(r'^1\d{10}$'),
                    message: '手机号格式不正确',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppField(
                controller: _amountController,
                value: _amount,
                label: '预算',
                placeholder: '请输入数字',
                type: AppFieldType.number,
                min: 10,
                max: 9999,
                clearable: true,
                formatter: (value) => value.replaceAll('..', '.'),
                onChanged: (value) {
                  setState(() {
                    _amount = value;
                  });
                },
                rightIcon: const Icon(
                  CupertinoIcons.money_yen_circle,
                  size: 18,
                  color: Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 12),
              AppField(
                controller: _bioController,
                value: _bio,
                label: '简介',
                placeholder: '填写一段个人介绍',
                type: AppFieldType.textarea,
                rows: 3,
                autosize: true,
                autosizeConfig: const AppFieldAutosizeConfig(
                  minHeight: 72,
                  maxHeight: 168,
                ),
                labelAlign: AppFieldTextAlign.top,
                clearable: true,
                showWordLimit: true,
                maxLength: 120,
                onChanged: (value) {
                  setState(() {
                    _bio = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              AppField(
                label: '地区',
                value: '上海市 / 徐汇区 / 漕河泾',
                readOnly: true,
                clickable: true,
                isLink: true,
                onTap: () {
                  AppToast.showText('这里只演示 Field 点击态');
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '操作与校验',
          subtitle: '演示 focus / blur 实例方法，以及表单校验结果。',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'focus 姓名',
                      onPressed: () {
                        _nameController.focus();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: 'blur 简介',
                      onPressed: () {
                        _bioController.blur();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: '校验姓名与预算',
                onPressed: () async {
                  final nameResult = await _nameController.validate();
                  final amountResult = await _amountController.validate();
                  if (!context.mounted) {
                    return;
                  }
                  final message =
                      'name=${nameResult.status.name} amount=${amountResult.status.name}';
                  AppToast.showText(message);
                },
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
      '支持 text、number、digit、textarea、password 五种输入类型。',
      '支持 clear、word limit、error message、readonly、is-link、formatter、rules。',
      '通过 AppFieldController 提供 focus、blur、validate 实例能力。',
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(
      padding: const EdgeInsets.symmetric(vertical: 14),
      borderRadius: BorderRadius.circular(18),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

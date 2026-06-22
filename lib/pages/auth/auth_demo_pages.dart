import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:oolaf_flutted/components/app_button/app_button_types.dart';
import 'package:oolaf_flutted/components/app_button/index.dart';
import 'package:oolaf_flutted/components/app_checkbox/index.dart';
import 'package:oolaf_flutted/components/app_field/app_field_types.dart';
import 'package:oolaf_flutted/components/app_field/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';
import 'package:oolaf_flutted/router/config.dart';
import 'package:oolaf_flutted/router/routes.dart';

const Color _authRed = Color(0xFFE51E2A);
const Color _authText = Color(0xFF202127);
const Color _authSubText = Color(0xFF8A92A0);

class AuthLoginPage extends StatefulWidget {
  const AuthLoginPage({super.key});

  @override
  State<AuthLoginPage> createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends State<AuthLoginPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _agreed = false;
  bool _isSubmitting = false;

  bool get _canSubmit {
    return _accountController.text.trim().isNotEmpty &&
        _passwordController.text.length >= 6 &&
        _agreed &&
        !_isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_refresh);
    _passwordController.addListener(_refresh);
  }

  @override
  void dispose() {
    _accountController
      ..removeListener(_refresh)
      ..dispose();
    _passwordController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      AppToast.showText('请填写账号、密码并同意协议');
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      AppToast.showSuccess('登录成功');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: '登录页',
      subtitle: 'Auth 模块的账号密码登录示例，虎扑业务登录仍走 /hupu/login。',
      children: [
        AuthTextField(
          controller: _accountController,
          label: '账号',
          placeholder: '手机号 / 邮箱',
          keyboardType: TextInputType.emailAddress,
          prefix: CupertinoIcons.person,
        ),
        AuthTextField(
          controller: _passwordController,
          label: '密码',
          placeholder: '请输入密码',
          obscureText: true,
          prefix: CupertinoIcons.lock,
        ),
        const SizedBox(height: 14),
        AuthAgreementRow(
          agreed: _agreed,
          onChanged: (value) {
            setState(() {
              _agreed = value;
            });
          },
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(
          text: '登录',
          loading: _isSubmitting,
          enabled: _canSubmit,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class AuthRegisterPage extends StatefulWidget {
  const AuthRegisterPage({super.key});

  @override
  State<AuthRegisterPage> createState() => _AuthRegisterPageState();
}

class _AuthRegisterPageState extends State<AuthRegisterPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _agreed = false;

  bool get _isPasswordStrong {
    final value = _passwordController.text;
    return value.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(value) &&
        RegExp(r'\d').hasMatch(value);
  }

  bool get _canSubmit {
    return _accountController.text.trim().isNotEmpty &&
        _isPasswordStrong &&
        _passwordController.text == _confirmController.text &&
        _agreed;
  }

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_refresh);
    _passwordController.addListener(_refresh);
    _confirmController.addListener(_refresh);
  }

  @override
  void dispose() {
    _accountController
      ..removeListener(_refresh)
      ..dispose();
    _passwordController
      ..removeListener(_refresh)
      ..dispose();
    _confirmController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: '注册页',
      subtitle: '账号创建、密码规则、手机号/邮箱输入和协议勾选。',
      children: [
        AuthTextField(
          controller: _accountController,
          label: '账号',
          placeholder: '手机号 / 邮箱',
          keyboardType: TextInputType.emailAddress,
          prefix: CupertinoIcons.at,
        ),
        AuthTextField(
          controller: _passwordController,
          label: '密码',
          placeholder: '至少 8 位，包含字母和数字',
          obscureText: true,
          prefix: CupertinoIcons.lock,
        ),
        AuthTextField(
          controller: _confirmController,
          label: '确认',
          placeholder: '再次输入密码',
          obscureText: true,
          prefix: CupertinoIcons.checkmark_shield,
        ),
        const SizedBox(height: 12),
        AuthInfoPanel(
          title: _isPasswordStrong ? '密码强度达标' : '密码强度不足',
          subtitle: '建议至少 8 位，并同时包含字母和数字。',
          icon: _isPasswordStrong
              ? CupertinoIcons.checkmark_seal
              : CupertinoIcons.exclamationmark_circle,
          color: _isPasswordStrong ? const Color(0xFF0B8F4D) : _authRed,
        ),
        const SizedBox(height: 14),
        AuthAgreementRow(
          agreed: _agreed,
          onChanged: (value) {
            setState(() {
              _agreed = value;
            });
          },
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(
          text: '创建账号',
          enabled: _canSubmit,
          onPressed: () => AppToast.showSuccess('账号已创建'),
        ),
      ],
    );
  }
}

class AuthOtpPage extends StatefulWidget {
  const AuthOtpPage({super.key});

  @override
  State<AuthOtpPage> createState() => _AuthOtpPageState();
}

class _AuthOtpPageState extends State<AuthOtpPage> {
  final TextEditingController _codeController = TextEditingController();
  Timer? _timer;
  int _seconds = 45;
  int _errorCount = 0;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_refresh);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 45;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_seconds <= 1) {
        timer.cancel();
        setState(() {
          _seconds = 0;
        });
        return;
      }
      setState(() {
        _seconds -= 1;
      });
    });
  }

  void _verify() {
    if (_codeController.text.length < 6) {
      setState(() {
        _errorCount += 1;
      });
      AppToast.showText('验证码错误');
      return;
    }
    AppToast.showSuccess('验证通过');
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: '验证码页',
      subtitle: '短信验证码、邮箱验证码、倒计时、重发和错误次数限制。',
      children: [
        AuthTextField(
          controller: _codeController,
          label: '验证码',
          placeholder: '请输入 6 位验证码',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          prefix: CupertinoIcons.number,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AuthSecondaryButton(
                text: _seconds > 0 ? '${_seconds}s 后重发' : '重新发送',
                enabled: _seconds == 0,
                onPressed: _startTimer,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AuthSecondaryButton(
                text: '自动填充',
                onPressed: () {
                  _codeController.text = '123456';
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AuthInfoPanel(
          title: '错误次数：$_errorCount / 5',
          subtitle: _errorCount >= 5 ? '已达到限制，请稍后再试。' : '错误次数过多后会临时限制提交。',
          icon: CupertinoIcons.exclamationmark_shield,
          color: _errorCount >= 5 ? _authRed : const Color(0xFF2878FF),
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(
          text: '验证',
          enabled: _errorCount < 5,
          onPressed: _verify,
        ),
      ],
    );
  }
}

class AuthPasswordFlowPage extends StatefulWidget {
  const AuthPasswordFlowPage({
    required this.mode,
    super.key,
  });

  final AuthPasswordFlowMode mode;

  @override
  State<AuthPasswordFlowPage> createState() => _AuthPasswordFlowPageState();
}

enum AuthPasswordFlowMode {
  forgot,
  reset,
  change,
}

class _AuthPasswordFlowPageState extends State<AuthPasswordFlowPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool get _isReset => widget.mode == AuthPasswordFlowMode.reset;
  bool get _isChange => widget.mode == AuthPasswordFlowMode.change;

  String get _title {
    switch (widget.mode) {
      case AuthPasswordFlowMode.forgot:
        return '忘记密码页';
      case AuthPasswordFlowMode.reset:
        return '重置密码页';
      case AuthPasswordFlowMode.change:
        return '修改密码页';
    }
  }

  String get _subtitle {
    switch (widget.mode) {
      case AuthPasswordFlowMode.forgot:
        return '输入邮箱/手机号，发送重置链接或验证码。';
      case AuthPasswordFlowMode.reset:
        return '设置新密码、确认密码，并处理 token/验证码失效。';
      case AuthPasswordFlowMode.change:
        return '已登录用户输入旧密码、新密码和确认新密码。';
    }
  }

  bool get _passwordReady {
    return _newPasswordController.text.length >= 8 &&
        _newPasswordController.text == _confirmPasswordController.text;
  }

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_refresh);
    _oldPasswordController.addListener(_refresh);
    _newPasswordController.addListener(_refresh);
    _confirmPasswordController.addListener(_refresh);
  }

  @override
  void dispose() {
    _accountController
      ..removeListener(_refresh)
      ..dispose();
    _oldPasswordController
      ..removeListener(_refresh)
      ..dispose();
    _newPasswordController
      ..removeListener(_refresh)
      ..dispose();
    _confirmPasswordController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == AuthPasswordFlowMode.forgot) {
      return AuthShell(
        title: _title,
        subtitle: _subtitle,
        children: [
          AuthTextField(
            controller: _accountController,
            label: '账号',
            placeholder: '手机号 / 邮箱',
            keyboardType: TextInputType.emailAddress,
            prefix: CupertinoIcons.at,
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(
            text: '发送重置链接',
            enabled: _accountController.text.trim().isNotEmpty,
            onPressed: () => AppToast.showSuccess('已发送重置链接'),
          ),
        ],
      );
    }

    return AuthShell(
      title: _title,
      subtitle: _subtitle,
      children: [
        if (_isChange)
          AuthTextField(
            controller: _oldPasswordController,
            label: '旧密码',
            placeholder: '请输入旧密码',
            obscureText: true,
            prefix: CupertinoIcons.lock_open,
          ),
        if (_isReset)
          const AuthInfoPanel(
            title: '重置凭证有效',
            subtitle: '当前示例展示 token/验证码有效状态，失效时应重新发起找回密码。',
            icon: CupertinoIcons.checkmark_seal,
            color: Color(0xFF0B8F4D),
          ),
        if (_isReset) const SizedBox(height: 12),
        AuthTextField(
          controller: _newPasswordController,
          label: '新密码',
          placeholder: '至少 8 位',
          obscureText: true,
          prefix: CupertinoIcons.lock,
        ),
        AuthTextField(
          controller: _confirmPasswordController,
          label: '确认',
          placeholder: '再次输入新密码',
          obscureText: true,
          prefix: CupertinoIcons.checkmark_shield,
        ),
        const SizedBox(height: 12),
        AuthInfoPanel(
          title: _passwordReady ? '密码可用' : '密码未通过校验',
          subtitle: '新密码至少 8 位，两次输入必须一致。',
          icon: _passwordReady
              ? CupertinoIcons.check_mark_circled
              : CupertinoIcons.exclamationmark_circle,
          color: _passwordReady ? const Color(0xFF0B8F4D) : _authRed,
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(
          text: _isChange ? '修改密码' : '重置密码',
          enabled: _passwordReady &&
              (!_isChange || _oldPasswordController.text.trim().isNotEmpty),
          onPressed: () => AppToast.showSuccess(_isChange ? '密码已修改' : '密码已重置'),
        ),
      ],
    );
  }
}

class AuthBindingPage extends StatelessWidget {
  const AuthBindingPage({
    required this.unbindMode,
    super.key,
  });

  final bool unbindMode;

  @override
  Widget build(BuildContext context) {
    final items = unbindMode
        ? const <_AuthBindingItem>[
            _AuthBindingItem('手机号', '138****8888', CupertinoIcons.phone),
            _AuthBindingItem('邮箱', 'demo@example.com', CupertinoIcons.mail),
            _AuthBindingItem(
                'Apple', '已绑定', CupertinoIcons.device_phone_portrait),
          ]
        : const <_AuthBindingItem>[
            _AuthBindingItem('手机号', '未绑定', CupertinoIcons.phone),
            _AuthBindingItem('邮箱', '未绑定', CupertinoIcons.mail),
            _AuthBindingItem('Google', '未绑定', CupertinoIcons.globe),
            _AuthBindingItem(
                'Apple', '未绑定', CupertinoIcons.device_phone_portrait),
            _AuthBindingItem('微信', '未绑定', CupertinoIcons.chat_bubble_2),
          ];

    return AuthShell(
      title: unbindMode ? '账号解绑页 / 安全验证页' : '账号绑定页',
      subtitle: unbindMode ? '解绑前需要二次验证，防止误操作或盗号。' : '绑定手机号、邮箱和第三方账号。',
      children: [
        for (final item in items)
          AuthOptionRow(
            title: item.title,
            subtitle: item.subtitle,
            icon: item.icon,
            trailingText: unbindMode ? '解绑' : '绑定',
            onTap: () {
              if (unbindMode) {
                Application.router.navigateTo(context, Routes.authMfa);
                return;
              }
              AppToast.showText('${item.title}绑定流程');
            },
          ),
      ],
    );
  }
}

class _AuthBindingItem {
  const _AuthBindingItem(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}

class AuthProfileCompletionPage extends StatefulWidget {
  const AuthProfileCompletionPage({super.key});

  @override
  State<AuthProfileCompletionPage> createState() =>
      _AuthProfileCompletionPageState();
}

class _AuthProfileCompletionPageState extends State<AuthProfileCompletionPage> {
  final TextEditingController _nicknameController = TextEditingController();
  String _gender = '未选择';
  String _area = '未选择';

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: '补全资料页',
      subtitle: '注册后首次进入时填写昵称、头像、生日、性别和地区。',
      children: [
        Center(
          child: Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEF0),
              borderRadius: BorderRadius.circular(41),
            ),
            child: const Icon(
              CupertinoIcons.camera,
              color: _authRed,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 18),
        AuthTextField(
          controller: _nicknameController,
          label: '昵称',
          placeholder: '请输入昵称',
          prefix: CupertinoIcons.person,
        ),
        AuthOptionRow(
          title: '性别',
          subtitle: _gender,
          icon: CupertinoIcons.person_2,
          onTap: () {
            setState(() {
              _gender = _gender == '男' ? '女' : '男';
            });
          },
        ),
        AuthOptionRow(
          title: '地区',
          subtitle: _area,
          icon: CupertinoIcons.location,
          onTap: () {
            setState(() {
              _area = '陕西 西安';
            });
          },
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(
          text: '保存资料',
          onPressed: () => AppToast.showSuccess('资料已保存'),
        ),
      ],
    );
  }
}

class AuthPermissionIntroPage extends StatelessWidget {
  const AuthPermissionIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _AuthBindingItem('通知', '用于接收安全提醒和互动通知', CupertinoIcons.bell),
      _AuthBindingItem('相册', '用于上传头像和内容图片', CupertinoIcons.photo),
      _AuthBindingItem('定位', '用于展示附近内容和地区资料', CupertinoIcons.location),
      _AuthBindingItem('通讯录', '用于查找可能认识的人', CupertinoIcons.person_2),
    ];
    return AuthShell(
      title: '权限申请说明页',
      subtitle: '先用自定义页面解释用途，不一打开 App 就弹系统权限。',
      children: [
        for (final item in items)
          AuthOptionRow(
            title: item.title,
            subtitle: item.subtitle,
            icon: item.icon,
            trailingText: '了解',
            onTap: () => AppToast.showText('${item.title}权限说明'),
          ),
        const SizedBox(height: 16),
        AuthPrimaryButton(
          text: '继续',
          onPressed: () => AppToast.showText('这里再触发系统权限弹窗'),
        ),
      ],
    );
  }
}

class AuthVerificationStatusPage extends StatelessWidget {
  const AuthVerificationStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: '邮箱/手机号验证状态页',
      subtitle: '提示请验证邮箱、验证链接已发送和重新发送验证邮件。',
      children: [
        const AuthInfoPanel(
          title: '验证链接已发送',
          subtitle: '我们已向 demo@example.com 发送验证邮件，请在 24 小时内完成验证。',
          icon: CupertinoIcons.mail,
          color: Color(0xFF2878FF),
        ),
        const SizedBox(height: 12),
        const AuthSecondaryButton(
          text: '重新发送验证邮件',
          onPressed: null,
        ),
        const SizedBox(height: 8),
        AuthPrimaryButton(
          text: '我已完成验证',
          onPressed: () => AppToast.showSuccess('验证状态已刷新'),
        ),
      ],
    );
  }
}

class AuthMfaPage extends StatefulWidget {
  const AuthMfaPage({super.key});

  @override
  State<AuthMfaPage> createState() => _AuthMfaPageState();
}

class _AuthMfaPageState extends State<AuthMfaPage> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: '二次验证页 / MFA 页',
      subtitle: '用于高风险操作、异地登录、换设备登录、支付和注销账号。',
      children: [
        const AuthInfoPanel(
          title: '检测到高风险操作',
          subtitle: '请输入动态验证码以继续本次操作。',
          icon: CupertinoIcons.shield_lefthalf_fill,
          color: _authRed,
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: _codeController,
          label: '动态码',
          placeholder: '6 位验证码',
          keyboardType: TextInputType.number,
          prefix: CupertinoIcons.number,
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(
          text: '完成验证',
          onPressed: () => AppToast.showSuccess('验证通过'),
        ),
      ],
    );
  }
}

class AuthSessionExpiredPage extends StatelessWidget {
  const AuthSessionExpiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: '会话过期页 / 重新登录页',
      subtitle: 'token 过期、账号在别处登录或密码已修改时使用。',
      children: [
        const AuthInfoPanel(
          title: '登录状态已失效',
          subtitle: '为了保护账号安全，请重新登录后继续使用。',
          icon: CupertinoIcons.clock,
          color: _authRed,
        ),
        const SizedBox(height: 18),
        AuthPrimaryButton(
          text: '重新登录',
          onPressed: () => Application.router.navigateTo(
            context,
            Routes.authLogin,
          ),
        ),
      ],
    );
  }
}

class AuthAccountSecurityPage extends StatelessWidget {
  const AuthAccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: '账号安全页',
      subtitle: '展示绑定方式、登录设备、修改密码、二次验证和注销账号入口。',
      children: [
        AuthOptionRow(
          title: '绑定方式',
          subtitle: '手机号、邮箱、Apple、微信',
          icon: CupertinoIcons.link,
          onTap: () =>
              Application.router.navigateTo(context, Routes.authBinding),
        ),
        AuthOptionRow(
          title: '登录设备',
          subtitle: '查看当前设备和退出其他设备',
          icon: CupertinoIcons.device_laptop,
          onTap: () =>
              Application.router.navigateTo(context, Routes.authDevices),
        ),
        AuthOptionRow(
          title: '修改密码',
          subtitle: '旧密码、新密码、确认新密码',
          icon: CupertinoIcons.lock_rotation,
          onTap: () =>
              Application.router.navigateTo(context, Routes.authChangePassword),
        ),
        AuthOptionRow(
          title: '二次验证',
          subtitle: '用于高风险操作',
          icon: CupertinoIcons.shield,
          onTap: () => Application.router.navigateTo(context, Routes.authMfa),
        ),
        AuthOptionRow(
          title: '注销账号',
          subtitle: '查看注销后果和冷静期',
          icon: CupertinoIcons.delete,
          destructive: true,
          onTap: () =>
              Application.router.navigateTo(context, Routes.authDelete),
        ),
      ],
    );
  }
}

class AuthDeviceManagementPage extends StatelessWidget {
  const AuthDeviceManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    const devices = [
      _AuthBindingItem(
          'iPhone 15 Pro', '当前设备 · 西安', CupertinoIcons.device_phone_portrait),
      _AuthBindingItem('Mac mini', '2 小时前登录', CupertinoIcons.desktopcomputer),
      _AuthBindingItem('Windows', '7 天前登录', CupertinoIcons.device_laptop),
    ];
    return AuthShell(
      title: '登录设备管理页',
      subtitle: '查看当前登录设备，退出其他设备。',
      children: [
        for (final item in devices)
          AuthOptionRow(
            title: item.title,
            subtitle: item.subtitle,
            icon: item.icon,
            trailingText: item.title == 'iPhone 15 Pro' ? '当前' : '退出',
            onTap: () => AppToast.showText('${item.title}设备操作'),
          ),
        const SizedBox(height: 16),
        AuthPrimaryButton(
          text: '退出其他设备',
          onPressed: () => AppToast.showText('已退出其他设备'),
        ),
      ],
    );
  }
}

class AuthDeleteAccountPage extends StatefulWidget {
  const AuthDeleteAccountPage({super.key});

  @override
  State<AuthDeleteAccountPage> createState() => _AuthDeleteAccountPageState();
}

class _AuthDeleteAccountPageState extends State<AuthDeleteAccountPage> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: '注销账号页',
      subtitle: '说明注销后果、冷静期、数据删除范围和最终确认。',
      children: [
        const AuthInfoPanel(
          title: '注销后将进入 15 天冷静期',
          subtitle: '冷静期结束后，账号资料、登录设备和个人数据将按规则删除。',
          icon: CupertinoIcons.exclamationmark_triangle,
          color: _authRed,
        ),
        const SizedBox(height: 14),
        AuthAgreementRow(
          agreed: _confirmed,
          label: '我已了解注销后果和数据删除范围',
          onChanged: (value) {
            setState(() {
              _confirmed = value;
            });
          },
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(
          text: '申请注销账号',
          enabled: _confirmed,
          onPressed: () =>
              Application.router.navigateTo(context, Routes.authMfa),
        ),
      ],
    );
  }
}

class AuthTermsPage extends StatelessWidget {
  const AuthTermsPage({
    this.privacy = false,
    super.key,
  });

  final bool privacy;

  @override
  Widget build(BuildContext context) {
    final title = privacy ? '隐私政策页' : '服务条款页';
    return AuthShell(
      title: '条款和隐私政策页',
      subtitle: '注册、登录、账号注销和权限申请时都可能需要跳转查看。',
      children: [
        AuthArticleCard(
          title: title,
          paragraphs: [
            '这里展示 $title 示例正文，用于说明账号能力相关的权利、义务和数据处理方式。',
            '真实项目中应从服务端或本地合规模板加载正式文本，并保留版本号与生效日期。',
            '用户在注册、登录、注销和权限申请前，可以从对应页面跳转到这里查看完整内容。',
          ],
        ),
      ],
    );
  }
}

class AuthThirdPartyCallbackPage extends StatefulWidget {
  const AuthThirdPartyCallbackPage({super.key});

  @override
  State<AuthThirdPartyCallbackPage> createState() =>
      _AuthThirdPartyCallbackPageState();
}

class _AuthThirdPartyCallbackPageState
    extends State<AuthThirdPartyCallbackPage> {
  String _state = '处理中';

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: '第三方登录回调/中转页',
      subtitle: '处理 Apple、Google、微信登录返回、loading、错误和取消登录。',
      children: [
        AuthInfoPanel(
          title: _state,
          subtitle: 'Flutter 中通常是中转态页面，用来承接 SDK 返回结果。',
          icon: _state == '处理中'
              ? CupertinoIcons.arrow_2_circlepath
              : CupertinoIcons.checkmark_seal,
          color: _state == '失败' || _state == '已取消'
              ? _authRed
              : const Color(0xFF2878FF),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final state in const ['处理中', '成功', '失败', '已取消'])
              AuthSmallPill(
                text: state,
                selected: _state == state,
                onTap: () {
                  setState(() {
                    _state = state;
                  });
                },
              ),
          ],
        ),
      ],
    );
  }
}

class AuthExceptionStatePage extends StatefulWidget {
  const AuthExceptionStatePage({super.key});

  @override
  State<AuthExceptionStatePage> createState() => _AuthExceptionStatePageState();
}

class _AuthExceptionStatePageState extends State<AuthExceptionStatePage> {
  String _state = '账号被冻结';

  @override
  Widget build(BuildContext context) {
    const states = ['账号被冻结', '账号被封禁', '未通过审核', '需要联系客服', '网络异常', '服务维护'];
    return AuthShell(
      title: '异常状态页',
      subtitle: '账号被冻结、被封禁、未通过审核、网络异常和服务维护等。',
      children: [
        AuthInfoPanel(
          title: _state,
          subtitle: _state == '服务维护' ? '服务维护中，请稍后再试。' : '当前账号状态需要处理后才能继续使用。',
          icon: CupertinoIcons.exclamationmark_octagon,
          color: _authRed,
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final state in states)
              AuthSmallPill(
                text: state,
                selected: _state == state,
                onTap: () {
                  setState(() {
                    _state = state;
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 18),
        AuthSecondaryButton(
          text: '联系客服',
          onPressed: () => AppToast.showText('联系客服入口'),
        ),
      ],
    );
  }
}

class AuthSplashGatePage extends StatefulWidget {
  const AuthSplashGatePage({super.key});

  @override
  State<AuthSplashGatePage> createState() => _AuthSplashGatePageState();
}

class _AuthSplashGatePageState extends State<AuthSplashGatePage> {
  String _target = '登录页';

  @override
  Widget build(BuildContext context) {
    final targetRoutes = <String, String>{
      '登录页': Routes.authLogin,
      '首页': Routes.root,
      '补资料页': Routes.authCompleteProfile,
      '强制升级页': Routes.authException,
    };
    return AuthShell(
      title: '启动鉴权页 / Splash Auth Gate',
      subtitle: '模拟判断 token、过期状态和 onboarding 后决定跳转。',
      children: [
        const AuthInfoPanel(
          title: '本地模拟鉴权链路',
          subtitle: '真实项目中这里会读取 token、过期时间、onboarding 状态和版本策略。',
          icon: CupertinoIcons.lock_shield,
          color: Color(0xFF2878FF),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final target in targetRoutes.keys)
              AuthSmallPill(
                text: target,
                selected: _target == target,
                onTap: () {
                  setState(() {
                    _target = target;
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(
          text: '模拟跳转到 $_target',
          onPressed: () {
            final route = targetRoutes[_target] ?? Routes.authLogin;
            Application.router.navigateTo(context, route);
          },
        ),
      ],
    );
  }
}

class AuthShell extends StatelessWidget {
  const AuthShell({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: Stack(
        children: [
          const Positioned.fill(child: _AuthBackground()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _AuthNavigationBar(
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(22, 32, 22, 24 + bottomInset),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: _authText,
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Color(0xFFBBC1CC),
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 34),
                            ...children,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFBFB),
            Color(0xFFFFFFFF),
            Color(0xFFF4F8FF),
          ],
          stops: [0, 0.52, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -76,
            child: _AuthSoftCircle(size: 220, color: Color(0x22E51E2A)),
          ),
          Positioned(
            top: 82,
            left: -100,
            child: _AuthSoftCircle(size: 210, color: Color(0x32E8F3FF)),
          ),
        ],
      ),
    );
  }
}

class _AuthSoftCircle extends StatelessWidget {
  const _AuthSoftCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }
}

class _AuthNavigationBar extends StatelessWidget {
  const _AuthNavigationBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                CupertinoIcons.back,
                size: 28,
                color: _authText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    required this.placeholder,
    this.keyboardType,
    this.obscureText = false,
    this.inputFormatters,
    this.prefix,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String placeholder;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefix;

  @override
  Widget build(BuildContext context) {
    final type = obscureText
        ? AppFieldType.password
        : keyboardType == TextInputType.number
            ? AppFieldType.digit
            : AppFieldType.text;
    return AppField(
      value: controller.text,
      label: label,
      placeholder: placeholder,
      type: type,
      maxLength: _maxLengthFromInputFormatters(inputFormatters),
      clearable: true,
      labelWidth: 56,
      leftIcon: prefix == null
          ? null
          : Icon(
              prefix,
              size: 18,
              color: const Color(0xFFB8BEC8),
            ),
      onChanged: (value) {
        if (controller.text == value) {
          return;
        }
        controller.value = controller.value.copyWith(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
          composing: TextRange.empty,
        );
      },
    );
  }

  int? _maxLengthFromInputFormatters(List<TextInputFormatter>? formatters) {
    if (formatters == null) {
      return null;
    }
    for (final formatter in formatters) {
      if (formatter is LengthLimitingTextInputFormatter) {
        return formatter.maxLength;
      }
    }
    return null;
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      block: true,
      size: AppButtonSize.large,
      type: AppButtonType.danger,
      disabled: !enabled,
      loading: loading,
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
    required this.text,
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      block: true,
      plain: true,
      type: AppButtonType.defaultType,
      disabled: !enabled || onPressed == null,
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class AuthAgreementRow extends StatelessWidget {
  const AuthAgreementRow({
    required this.agreed,
    required this.onChanged,
    this.label = '我已阅读并同意用户协议和隐私政策',
    super.key,
  });

  final bool agreed;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCheckbox<String>(
      name: 'agreement',
      value: agreed,
      checkedColor: _authRed,
      bindGroup: false,
      onChanged: onChanged,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: agreed ? _authRed : CupertinoColors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: agreed ? _authRed : const Color(0xFFB8C0CC),
                width: 1.4,
              ),
            ),
            child: agreed
                ? const Icon(
                    CupertinoIcons.check_mark,
                    color: CupertinoColors.white,
                    size: 12,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7C8491),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthInfoPanel extends StatelessWidget {
  const AuthInfoPanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEEF2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _authText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _authSubText,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthOptionRow extends StatelessWidget {
  const AuthOptionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.trailingText,
    this.destructive = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? trailingText;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? _authRed : _authText;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 13, 12, 13),
          decoration: BoxDecoration(
            color: CupertinoColors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDEEF2)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: destructive
                      ? const Color(0xFFFFEEF0)
                      : const Color(0xFFF1F3F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _authSubText,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: TextStyle(
                    color: destructive ? _authRed : const Color(0xFF2878FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: Color(0xFFADB4C0),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthArticleCard extends StatelessWidget {
  const AuthArticleCard({
    required this.title,
    required this.paragraphs,
    super.key,
  });

  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEEF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _authText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final paragraph in paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                paragraph,
                style: const TextStyle(
                  color: Color(0xFF5C6370),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AuthSmallPill extends StatelessWidget {
  const AuthSmallPill({
    required this.text,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _authRed : CupertinoColors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? _authRed : const Color(0xFFE1E4EA),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? CupertinoColors.white : _authText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

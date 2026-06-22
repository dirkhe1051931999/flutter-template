import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class HupuLoginPage extends StatefulWidget {
  const HupuLoginPage({super.key});

  @override
  State<HupuLoginPage> createState() => _HupuLoginPageState();
}

class _HupuLoginPageState extends State<HupuLoginPage> {
  static const int _smsCountdownSeconds = 60;

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _smsCodeFocusNode = FocusNode();

  Timer? _countdownTimer;
  int _countdownSeconds = 0;
  bool _agreed = false;
  bool _isSendingSms = false;
  bool _isSubmitting = false;
  String _mobile = '';
  String _smsCode = '';

  bool get _isCountingDown => _countdownSeconds > 0;
  bool get _isMobileValid => RegExp(r'^1\d{10}$').hasMatch(_mobile);
  bool get _isSmsCodeValid => RegExp(r'^\d{4,6}$').hasMatch(_smsCode);
  bool get _canSendSms => _isMobileValid && !_isCountingDown && !_isSendingSms;
  bool get _canSubmit =>
      _isMobileValid && _isSmsCodeValid && _agreed && !_isSubmitting;

  @override
  void initState() {
    super.initState();
    _mobileController.addListener(_handleMobileChanged);
    _smsCodeController.addListener(_handleSmsCodeChanged);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _mobileController
      ..removeListener(_handleMobileChanged)
      ..dispose();
    _smsCodeController
      ..removeListener(_handleSmsCodeChanged)
      ..dispose();
    _mobileFocusNode.dispose();
    _smsCodeFocusNode.dispose();
    super.dispose();
  }

  void _handleMobileChanged() {
    final nextValue = _mobileController.text.trim();
    if (nextValue == _mobile) {
      return;
    }
    setState(() {
      _mobile = nextValue;
    });
  }

  void _handleSmsCodeChanged() {
    final nextValue = _smsCodeController.text.trim();
    if (nextValue == _smsCode) {
      return;
    }
    setState(() {
      _smsCode = nextValue;
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _countdownSeconds = _smsCountdownSeconds;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _countdownSeconds = 0;
        });
        return;
      }
      setState(() {
        _countdownSeconds -= 1;
      });
    });
  }

  Future<void> _handleSendSms() async {
    if (!_isMobileValid) {
      AppToast.showText('请输入正确的手机号');
      _mobileFocusNode.requestFocus();
      return;
    }
    if (!_canSendSms) {
      return;
    }
    setState(() {
      _isSendingSms = true;
    });
    try {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) {
        return;
      }
      AppToast.showText('验证码已发送');
      _startCountdown();
      _smsCodeFocusNode.requestFocus();
    } finally {
      if (mounted) {
        setState(() {
          _isSendingSms = false;
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_isMobileValid) {
      AppToast.showText('请输入正确的手机号');
      _mobileFocusNode.requestFocus();
      return;
    }
    if (!_isSmsCodeValid) {
      AppToast.showText('请输入正确的验证码');
      _smsCodeFocusNode.requestFocus();
      return;
    }
    if (!_agreed) {
      AppToast.showText('请先阅读并同意用户协议和隐私条款');
      return;
    }
    if (!_canSubmit) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) {
        return;
      }
      AppToast.showSuccess('登录成功');
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _toggleAgreement() {
    setState(() {
      _agreed = !_agreed;
    });
  }

  void _showAgreement(String title) {
    AppToast.showText(title);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: Stack(
        children: [
          const Positioned.fill(child: _HupuLoginBackground()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _HupuLoginNavigationBar(
                    onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(22, 44, 22, 24 + bottomInset),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '虎扑手机快捷登录',
                              style: TextStyle(
                                color: Color(0xFF202127),
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '用于登录虎扑关注、推荐和互动相关能力',
                              style: TextStyle(
                                color: Color(0xFFBBC1CC),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 44),
                            _MobileInputRow(
                              controller: _mobileController,
                              focusNode: _mobileFocusNode,
                              onSubmitted: (_) => _handleSendSms(),
                            ),
                            const SizedBox(height: 12),
                            _SmsCodeInputRow(
                              controller: _smsCodeController,
                              focusNode: _smsCodeFocusNode,
                              canSendSms: _canSendSms,
                              isSendingSms: _isSendingSms,
                              countdownSeconds: _countdownSeconds,
                              onSendSms: _handleSendSms,
                              onSubmitted: (_) => _handleSubmit(),
                            ),
                            const SizedBox(height: 18),
                            _AgreementRow(
                              agreed: _agreed,
                              onToggle: _toggleAgreement,
                              onTapUserAgreement: () => _showAgreement('用户协议'),
                              onTapPrivacy: () => _showAgreement('隐私条款'),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 49,
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                color: const Color(0xFFF20D28),
                                disabledColor: const Color(0x4DF20D28),
                                borderRadius: BorderRadius.circular(3),
                                onPressed: _canSubmit ? _handleSubmit : null,
                                child: _isSubmitting
                                    ? const CupertinoActivityIndicator(
                                        color: CupertinoColors.white,
                                      )
                                    : const Text(
                                        '登录',
                                        style: TextStyle(
                                          color: CupertinoColors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
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

class _HupuLoginBackground extends StatelessWidget {
  const _HupuLoginBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7FFFC),
            Color(0xFFFFFFFF),
            Color(0xFFF3F8FF),
          ],
          stops: [0, 0.48, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: -72,
            child: _SoftCircle(size: 210, color: Color(0xBFE8F3FF)),
          ),
          Positioned(
            top: 36,
            left: -88,
            child: _SoftCircle(size: 190, color: Color(0x80EDFBF7)),
          ),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({
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

class _HupuLoginNavigationBar extends StatelessWidget {
  const _HupuLoginNavigationBar({required this.onBack});

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
                color: Color(0xFF202127),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileInputRow extends StatelessWidget {
  const _MobileInputRow({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return _AuthInputShell(
      child: Row(
        children: [
          const Text(
            '+86',
            style: TextStyle(
              color: Color(0xFF202127),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            CupertinoIcons.chevron_down,
            size: 14,
            color: Color(0xFFD2D6DD),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoTextField.borderless(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              placeholder: '请输入手机号',
              placeholderStyle: const TextStyle(
                color: Color(0xFFC4CAD3),
                fontSize: 16,
              ),
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              padding: EdgeInsets.zero,
              decoration: null,
              onSubmitted: onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmsCodeInputRow extends StatelessWidget {
  const _SmsCodeInputRow({
    required this.controller,
    required this.focusNode,
    required this.canSendSms,
    required this.isSendingSms,
    required this.countdownSeconds,
    required this.onSendSms,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSendSms;
  final bool isSendingSms;
  final int countdownSeconds;
  final VoidCallback onSendSms;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final isCountingDown = countdownSeconds > 0;
    return _AuthInputShell(
      child: Row(
        children: [
          const Text(
            '验证码',
            style: TextStyle(
              color: Color(0xFF202127),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: CupertinoTextField.borderless(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              placeholder: '请输入验证码',
              placeholderStyle: const TextStyle(
                color: Color(0xFFC4CAD3),
                fontSize: 16,
              ),
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              padding: EdgeInsets.zero,
              decoration: null,
              onSubmitted: onSubmitted,
            ),
          ),
          const SizedBox(width: 12),
          CupertinoButton(
            minimumSize: const Size(0, 28),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            onPressed: canSendSms ? onSendSms : null,
            child: isSendingSms
                ? const CupertinoActivityIndicator(radius: 8)
                : Text(
                    isCountingDown ? '${countdownSeconds}s后重试' : '获取验证码',
                    style: TextStyle(
                      color: canSendSms
                          ? const Color(0xFF2878FF)
                          : const Color(0xFFB8BEC8),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AuthInputShell extends StatelessWidget {
  const _AuthInputShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE6EAF0), width: 1),
        ),
      ),
      child: child,
    );
  }
}

class _AgreementRow extends StatelessWidget {
  const _AgreementRow({
    required this.agreed,
    required this.onToggle,
    required this.onTapUserAgreement,
    required this.onTapPrivacy,
  });

  final bool agreed;
  final VoidCallback onToggle;
  final VoidCallback onTapUserAgreement;
  final VoidCallback onTapPrivacy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _AgreementCheckbox(checked: agreed),
          const SizedBox(width: 6),
          const Text(
            '我已阅读并同意',
            style: TextStyle(
              color: Color(0xFF7C8491),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapUserAgreement,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '用户协议',
                style: TextStyle(
                  color: Color(0xFF2878FF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const Text(
            '和',
            style: TextStyle(
              color: Color(0xFF7C8491),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapPrivacy,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '隐私条款',
                style: TextStyle(
                  color: Color(0xFF2878FF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementCheckbox extends StatelessWidget {
  const _AgreementCheckbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        color: checked ? const Color(0xFF2878FF) : CupertinoColors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: checked ? const Color(0xFF2878FF) : const Color(0xFF9CA3AF),
          width: 1.2,
        ),
      ),
      child: checked
          ? const Icon(
              CupertinoIcons.check_mark,
              color: CupertinoColors.white,
              size: 10,
            )
          : null,
    );
  }
}

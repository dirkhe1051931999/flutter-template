import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oolaf_flutted/utils/ifeng_auth_flow.dart';

class ShortVideoLoginPage extends StatefulWidget {
  const ShortVideoLoginPage({super.key});

  @override
  State<ShortVideoLoginPage> createState() => _ShortVideoLoginPageState();
}

class _ShortVideoLoginPageState extends State<ShortVideoLoginPage>
    with WidgetsBindingObserver {
  static const String _smsCountdownDeadlineKey = 'ifeng_login_sms_countdown_deadline_v1';
  static const int _smsCountdownSeconds = 30;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();

  Timer? _countdownTimer;
  DateTime? _countdownDeadline;
  int _countdownSeconds = 0;
  bool _isSendingSms = false;
  bool _isSubmitting = false;

  bool get _isCountingDown => _countdownSeconds > 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_restoreCountdownState());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _mobileController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_restoreCountdownState());
    }
  }

  String? _validateMobile(String? value) {
    return IfengAuthFlow.validateMobile(value);
  }

  String? _validateSmsCode(String? value) {
    return IfengAuthFlow.validateSmsCode(value);
  }

  Future<void> _restoreCountdownState() async {
    final prefs = await SharedPreferences.getInstance();
    final deadlineMs = prefs.getInt(_smsCountdownDeadlineKey);
    if (deadlineMs == null || deadlineMs <= 0) {
      if (!mounted) {
        return;
      }
      setState(() {
        _countdownDeadline = null;
        _countdownSeconds = 0;
      });
      return;
    }
    final deadline = DateTime.fromMillisecondsSinceEpoch(deadlineMs);
    final remaining = deadline.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) {
      await _clearCountdownState();
      return;
    }
    _countdownDeadline = deadline;
    _restartCountdownTimer();
  }

  Future<void> _persistCountdownDeadline(DateTime deadline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_smsCountdownDeadlineKey, deadline.millisecondsSinceEpoch);
  }

  Future<void> _clearCountdownState() async {
    _countdownTimer?.cancel();
    _countdownDeadline = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_smsCountdownDeadlineKey);
    if (!mounted) {
      return;
    }
    setState(() {
      _countdownSeconds = 0;
    });
  }

  void _restartCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final deadline = _countdownDeadline;
      if (deadline == null) {
        timer.cancel();
        return;
      }
      final remaining = deadline.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        timer.cancel();
        unawaited(_clearCountdownState());
        return;
      }
      setState(() {
        _countdownSeconds = remaining;
      });
    });
  }

  void _startCountdown() {
    final deadline = DateTime.now().add(const Duration(seconds: _smsCountdownSeconds));
    _countdownDeadline = deadline;
    setState(() {
      _countdownSeconds = _smsCountdownSeconds;
    });
    unawaited(_persistCountdownDeadline(deadline));
    _restartCountdownTimer();
  }

  Future<void> _handleSendSms() async {
    final mobileError = _validateMobile(_mobileController.text);
    if (mobileError != null) {
      AppToast.showText(mobileError);
      return;
    }
    if (_isSendingSms || _isCountingDown) {
      return;
    }

    setState(() {
      _isSendingSms = true;
    });

    try {
      final mobile = _mobileController.text.trim();
      await IfengAuthFlow.sendLoginSmsWithCaptchaFallback(
        context: context,
        mobile: mobile,
        onSmsSent: _startCountdown,
      );
    } catch (error) {
      debugPrint('short_video_login send sms fatal error: $error');
      AppToast.showText('发送验证码失败');
    } finally {
      if (mounted) {
        setState(() {
          _isSendingSms = false;
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final mobile = _mobileController.text.trim();
      final smsCode = _smsCodeController.text.trim();
      final success = await IfengAuthFlow.loginWithSmsCode(
        mobile: mobile,
        smsCode: smsCode,
      );
      if (!success) {
        return;
      }
      _smsCodeController.clear();
      await _clearCountdownState();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (_) {
      AppToast.clear();
      AppToast.showText('登录失败');
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
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      resizeToAvoidBottomInset: false,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('登录'),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.12),
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '手机号登录',
                              style: TextStyle(
                                fontSize: 34,
                                height: 1.06,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -0.9,
                                color: Color(0xFF0D253D),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '使用凤凰账号短信验证码登录',
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.45,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF64748D),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _LoginField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              placeholder: '请输入手机号',
                              validator: _validateMobile,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _LoginField(
                                    controller: _smsCodeController,
                                    keyboardType: TextInputType.number,
                                    placeholder: '请输入短信验证码',
                                    validator: _validateSmsCode,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 118,
                                  height: 44,
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    color: _isCountingDown
                                        ? const Color(0xFFEFF2F6)
                                        : const Color(0xFF533AFD),
                                    borderRadius: BorderRadius.circular(999),
                                    onPressed: (_isCountingDown || _isSendingSms)
                                        ? null
                                        : _handleSendSms,
                                    child: _isSendingSms
                                        ? const CupertinoActivityIndicator(
                                            color: CupertinoColors.white,
                                          )
                                        : Text(
                                            _isCountingDown
                                                ? '${_countdownSeconds}s'
                                                : '获取验证码',
                                            style: TextStyle(
                                              color: _isCountingDown
                                                  ? const Color(0xFF61718A)
                                                  : CupertinoColors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 46,
                              width: double.infinity,
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                color: const Color(0xFF533AFD),
                                borderRadius: BorderRadius.circular(999),
                                onPressed: _isSubmitting ? null : _handleSubmit,
                                child: _isSubmitting
                                    ? const CupertinoActivityIndicator(
                                        color: CupertinoColors.white,
                                      )
                                    : const Text(
                                        '登录',
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.placeholder,
    required this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String placeholder;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      scrollPadding: EdgeInsets.zero,
      validator: validator,
      style: const TextStyle(
        color: Color(0xFF0D253D),
        fontSize: 15,
        height: 1.4,
        fontWeight: FontWeight.w300,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        hintStyle: const TextStyle(
          color: Color(0xFF64748D),
          fontSize: 15,
          fontWeight: FontWeight.w300,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFA8C3DE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF533AFD), width: 1.1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFCA5A5)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFCA5A5), width: 1.1),
        ),
      ),
    );
  }
}

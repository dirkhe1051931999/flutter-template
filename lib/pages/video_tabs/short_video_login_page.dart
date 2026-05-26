import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oolaf_flutted/api/ifeng_auth/index.dart';
import 'package:oolaf_flutted/model/ifeng_auth/index.dart';
import 'package:oolaf_flutted/components/short_video/login_captcha_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oolaf_flutted/utils/ifeng_auth_storage.dart';
import 'package:oolaf_flutted/utils/ifeng_request.dart';

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
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return '请输入手机号';
    }
    if (!RegExp(r'^1\d{10}$').hasMatch(text)) {
      return '请输入正确手机号';
    }
    return null;
  }

  String? _validateSmsCode(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return '请输入验证码';
    }
    return null;
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
      EasyLoading.showToast(mobileError);
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
      final smsResult = await sendIfengLoginSms(mobile: mobile);
      if (smsResult.requiresCaptcha) {
        while (mounted) {
          IfengCaptchaModel? captcha;
          try {
            captcha = await getIfengCaptcha();
          } catch (error) {
            debugPrint('short_video_login getCaptcha error: $error');
            EasyLoading.showToast('获取验证码图片失败');
            return;
          }
          if (captcha == null) {
            EasyLoading.showToast('获取验证码图片失败');
            return;
          }
          if (!mounted) {
            return;
          }
          final dialogResult = await showLoginCaptchaDialog(
            context: context,
            payload: LoginCaptchaDialogPayload(
              captchaId: captcha.id,
              imageUrl: captcha.imageUrl,
              words: captcha.words,
            ),
          );
          if (!mounted) {
            return;
          }
          if (dialogResult == null) {
            return;
          }
          final positionsJson = encodeCaptchaPositions(
            dialogResult.positions.map((item) => item.toJson()).toList(growable: false),
          );
          IfengSmsSendResultModel verifyResult;
          try {
            verifyResult = await verifyIfengCaptchaAndSendSms(
              mobile: mobile,
              captchaId: dialogResult.captchaId,
              positionsJson: positionsJson,
            );
          } catch (error) {
            debugPrint('short_video_login verify captcha send sms error: $error');
            EasyLoading.showToast('验证码校验失败，已刷新验证码');
            continue;
          }
          if (verifyResult.likelySmsSent) {
            EasyLoading.showToast('发送验证码成功');
            _startCountdown();
            return;
          }
          EasyLoading.showToast(
            verifyResult.message.isNotEmpty
                ? '${verifyResult.message}，已刷新验证码'
                : '验证码发送失败，已刷新验证码',
          );
        }
        return;
      }
      if (smsResult.likelySmsSent) {
        EasyLoading.showToast('发送验证码成功');
        _startCountdown();
        return;
      }
      EasyLoading.showToast(
        smsResult.message.isNotEmpty ? smsResult.message : '发送验证码失败',
      );
    } catch (error) {
      debugPrint('short_video_login send sms fatal error: $error');
      EasyLoading.showToast('发送验证码失败');
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
    EasyLoading.show(status: '校验手机号...');

    try {
      final mobile = _mobileController.text.trim();
      final smsCode = _smsCodeController.text.trim();
      String ltoken;
      try {
        ltoken = await checkIfengMobileBeforeLogin(mobile: mobile);
      } catch (_) {
        EasyLoading.dismiss();
        EasyLoading.showToast('手机号校验失败，请稍后重试');
        return;
      }
      EasyLoading.show(status: '校验验证码...');
      IfengAuthSessionModel? session;
      try {
        session = await loginIfengBySms(
          mobile: mobile,
          smsCode: smsCode,
          ltoken: ltoken,
        );
      } catch (_) {
        EasyLoading.dismiss();
        EasyLoading.showToast('短信验证码校验失败，请重试');
        return;
      }
      if (session == null) {
        EasyLoading.dismiss();
        EasyLoading.showToast('短信验证码错误或已失效');
        return;
      }
      EasyLoading.show(status: '同步账号资料...');
      IfengUserProfileModel? completedProfile;
      try {
        completedProfile = await completeIfengLogin(session: session);
      } catch (_) {
        EasyLoading.dismiss();
        EasyLoading.showToast('账号登录链路失败，请稍后重试');
        return;
      }
      await IfengAuthStorage.saveSession(
        IfengAuthSession(
          token: session.token,
          guid: session.guid,
          username: session.username,
          nickname: completedProfile?.nickname.isNotEmpty == true
              ? completedProfile!.nickname
              : session.nickname,
          userImage: completedProfile?.userImage.isNotEmpty == true
              ? completedProfile!.userImage
              : session.userImage,
          auth: session.auth.isNotEmpty ? session.auth : '4A24BA8FCD63FF5F',
          smsFastPass: session.smsFastPass,
        ),
      );
      _smsCodeController.clear();
      await _clearCountdownState();
      EasyLoading.dismiss();
      EasyLoading.showToast('登录成功');
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (_) {
      EasyLoading.dismiss();
      EasyLoading.showToast('登录失败');
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


import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oolaf_flutted/utils/ifeng_auth_flow.dart';

Future<bool> showArticleQuickLoginSheet(BuildContext context) async {
  final result = await showCupertinoModalPopup<bool>(
    context: context,
    builder: (sheetContext) {
      return const _ArticleQuickLoginSheet();
    },
  );
  return result == true;
}

class _ArticleQuickLoginSheet extends StatefulWidget {
  const _ArticleQuickLoginSheet();

  @override
  State<_ArticleQuickLoginSheet> createState() => _ArticleQuickLoginSheetState();
}

class _ArticleQuickLoginSheetState extends State<_ArticleQuickLoginSheet> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _smsCodeFocusNode = FocusNode();

  Timer? _countdownTimer;
  int _countdownSeconds = 0;
  bool _isSendingSms = false;
  bool _isSubmitting = false;
  bool _showSmsInput = false;

  bool get _canStartLogin {
    return _mobileController.text.trim().isNotEmpty && !_isSendingSms;
  }

  bool get _canSubmitSms {
    return _smsCodeController.text.trim().isNotEmpty && !_isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _mobileController.addListener(_handleFieldChanged);
    _smsCodeController.addListener(_handleFieldChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mobileFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _mobileController.removeListener(_handleFieldChanged);
    _smsCodeController.removeListener(_handleFieldChanged);
    _mobileController.dispose();
    _smsCodeController.dispose();
    _mobileFocusNode.dispose();
    _smsCodeFocusNode.dispose();
    super.dispose();
  }

  void _handleFieldChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _countdownSeconds = 30;
      _showSmsInput = true;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _smsCodeFocusNode.requestFocus();
      }
    });
  }

  Future<void> _handleStartLogin() async {
    final mobile = _mobileController.text.trim();
    final mobileError = IfengAuthFlow.validateMobile(mobile);
    if (mobileError != null) {
      EasyLoading.showToast(mobileError);
      return;
    }
    if (_isSendingSms) {
      return;
    }
    setState(() {
      _isSendingSms = true;
    });
    try {
      await IfengAuthFlow.sendLoginSmsWithCaptchaFallback(
        context: context,
        mobile: mobile,
        onSmsSent: _startCountdown,
      );
    } catch (_) {
      EasyLoading.showToast('发送验证码失败');
    } finally {
      if (mounted) {
        setState(() {
          _isSendingSms = false;
        });
      }
    }
  }

  Future<void> _handleSubmitSms() async {
    final mobile = _mobileController.text.trim();
    final smsCode = _smsCodeController.text.trim();
    final mobileError = IfengAuthFlow.validateMobile(mobile);
    if (mobileError != null) {
      EasyLoading.showToast(mobileError);
      return;
    }
    final smsError = IfengAuthFlow.validateSmsCode(smsCode);
    if (smsError != null) {
      EasyLoading.showToast(smsError);
      return;
    }
    if (_isSubmitting) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    final success = await IfengAuthFlow.loginWithSmsCode(
      mobile: mobile,
      smsCode: smsCode,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _isSubmitting = false;
    });
    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24, 18, 24, safeBottom > 0 ? safeBottom : 20),
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '当前操作需要登录帐号',
              style: TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E5EA)),
                ),
              ),
              child: CupertinoTextField.borderless(
                controller: _mobileController,
                focusNode: _mobileFocusNode,
                keyboardType: TextInputType.phone,
                placeholder: '请输入手机号',
                style: const TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 17,
                ),
                placeholderStyle: const TextStyle(
                  color: Color(0xFFC7C7CC),
                  fontSize: 17,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            if (_showSmsInput) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE5E5EA)),
                        ),
                      ),
                      child: CupertinoTextField.borderless(
                        controller: _smsCodeController,
                        focusNode: _smsCodeFocusNode,
                        keyboardType: TextInputType.number,
                        placeholder: '请输入验证码',
                        style: const TextStyle(
                          color: Color(0xFF1C1C1E),
                          fontSize: 17,
                        ),
                        placeholderStyle: const TextStyle(
                          color: Color(0xFFC7C7CC),
                          fontSize: 17,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: (_countdownSeconds > 0 || _isSendingSms) ? null : _handleStartLogin,
                    child: Text(
                      _countdownSeconds > 0 ? '${_countdownSeconds}s' : '重新发送',
                      style: TextStyle(
                        color: (_countdownSeconds > 0 || _isSendingSms)
                            ? const Color(0xFFC7C7CC)
                            : CupertinoColors.activeBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _showSmsInput
                  ? (_canSubmitSms ? _handleSubmitSms : null)
                  : (_canStartLogin ? _handleStartLogin : null),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: (_showSmsInput ? _canSubmitSms : _canStartLogin)
                      ? const Color(0xFFF59CA0)
                      : const Color(0xFFF8C7CA),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  _showSmsInput ? '确定' : '登录',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.square, size: 18, color: Color(0xFF8E8E93)),
                SizedBox(width: 6),
                Text(
                  '同意用户协议和隐私政策',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.chat_bubble_2_fill, color: Color(0xFF4CD964), size: 28),
                SizedBox(width: 28),
                Icon(CupertinoIcons.burn, color: Color(0xFFFF3B30), size: 28),
                SizedBox(width: 28),
                Icon(CupertinoIcons.person_2_fill, color: Color(0xFF0A84FF), size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

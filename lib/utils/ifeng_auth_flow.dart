import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oolaf_flutted/api/ifeng_auth/index.dart';
import 'package:oolaf_flutted/components/short_video/login_captcha_dialog.dart';
import 'package:oolaf_flutted/model/ifeng_auth/index.dart';
import 'package:oolaf_flutted/utils/ifeng_auth_storage.dart';
import 'package:oolaf_flutted/utils/ifeng_request.dart';

class IfengAuthFlow {
  IfengAuthFlow._();

  static const String defaultAuth = '4A24BA8FCD63FF5F';

  static String? validateMobile(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return '请输入手机号';
    }
    if (!RegExp(r'^1\d{10}$').hasMatch(text)) {
      return '请输入正确手机号';
    }
    return null;
  }

  static String? validateSmsCode(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return '请输入验证码';
    }
    return null;
  }

  static Future<IfengSmsSendResultModel?> sendLoginSmsWithCaptchaFallback({
    required BuildContext context,
    required String mobile,
    void Function()? onSmsSent,
  }) async {
    final smsResult = await sendIfengLoginSms(mobile: mobile);
    if (!context.mounted) {
      return null;
    }
    if (smsResult.requiresCaptcha) {
      return _sendSmsViaCaptcha(
        context: context,
        mobile: mobile,
        onSmsSent: onSmsSent,
      );
    }
    if (smsResult.likelySmsSent) {
      EasyLoading.showToast('发送验证码成功');
      onSmsSent?.call();
      return smsResult;
    }
    EasyLoading.showToast(
      smsResult.message.isNotEmpty ? smsResult.message : '发送验证码失败',
    );
    return smsResult;
  }

  static Future<IfengSmsSendResultModel?> _sendSmsViaCaptcha({
    required BuildContext context,
    required String mobile,
    void Function()? onSmsSent,
  }) async {
    while (context.mounted) {
      IfengCaptchaModel? captcha;
      try {
        captcha = await getIfengCaptcha();
      } catch (error) {
        debugPrint('ifeng_auth_flow getCaptcha error: $error');
        EasyLoading.showToast('获取验证码图片失败');
        return null;
      }
      if (captcha == null) {
        EasyLoading.showToast('获取验证码图片失败');
        return null;
      }
      if (!context.mounted) {
        return null;
      }
      final dialogResult = await showLoginCaptchaDialog(
        context: context,
        payload: LoginCaptchaDialogPayload(
          captchaId: captcha.id,
          imageUrl: captcha.imageUrl,
          words: captcha.words,
        ),
      );
      if (!context.mounted || dialogResult == null) {
        return null;
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
        debugPrint('ifeng_auth_flow verify captcha send sms error: $error');
        EasyLoading.showToast('验证码校验失败，已刷新验证码');
        continue;
      }
      if (verifyResult.likelySmsSent) {
        EasyLoading.showToast('发送验证码成功');
        onSmsSent?.call();
        return verifyResult;
      }
      EasyLoading.showToast(
        verifyResult.message.isNotEmpty
            ? '${verifyResult.message}，已刷新验证码'
            : '验证码发送失败，已刷新验证码',
      );
    }
    return null;
  }

  static Future<bool> loginWithSmsCode({
    required String mobile,
    required String smsCode,
  }) async {
    EasyLoading.show(status: '校验手机号...');
    try {
      String ltoken;
      try {
        ltoken = await checkIfengMobileBeforeLogin(mobile: mobile);
      } catch (_) {
        EasyLoading.dismiss();
        EasyLoading.showToast('手机号校验失败，请稍后重试');
        return false;
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
        return false;
      }
      if (session == null) {
        EasyLoading.dismiss();
        EasyLoading.showToast('短信验证码错误或已失效');
        return false;
      }
      EasyLoading.show(status: '同步账号资料...');
      IfengUserProfileModel? completedProfile;
      try {
        completedProfile = await completeIfengLogin(session: session);
      } catch (_) {
        EasyLoading.dismiss();
        EasyLoading.showToast('账号登录链路失败，请稍后重试');
        return false;
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
          auth: session.auth.isNotEmpty ? session.auth : defaultAuth,
          smsFastPass: session.smsFastPass,
        ),
      );
      EasyLoading.dismiss();
      EasyLoading.showToast('登录成功');
      return true;
    } catch (_) {
      EasyLoading.dismiss();
      EasyLoading.showToast('登录失败');
      return false;
    }
  }
}

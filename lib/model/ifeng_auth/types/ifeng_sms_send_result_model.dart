class IfengSmsSendResultModel {
  const IfengSmsSendResultModel({
    required this.code,
    required this.message,
    required this.requiresCaptcha,
    required this.smsSent,
    required this.authCode,
    required this.cooldownToken,
    required this.rawData,
  });

  final int code;
  final String message;
  final bool requiresCaptcha;
  final bool smsSent;
  final String authCode;
  final String cooldownToken;
  final Map<String, dynamic> rawData;

  bool get likelySmsSent {
    if (smsSent) {
      return true;
    }
    if (requiresCaptcha) {
      return false;
    }
    if (rawData.isNotEmpty && code == 1) {
      return true;
    }
    final normalizedMessage = message.trim();
    if (normalizedMessage.contains('发送成功') ||
        normalizedMessage.contains('验证码已发送') ||
        normalizedMessage.contains('发送验证码成功')) {
      return true;
    }
    return false;
  }

  factory IfengSmsSendResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map<String, dynamic>
        ? data
        : data is Map
            ? data.map((key, value) => MapEntry(key.toString(), value))
            : <String, dynamic>{};
    final authCodeValue = dataMap['authcode'];
    final authCode = switch (authCodeValue) {
      true => 'true',
      false || null => '',
      _ => authCodeValue.toString(),
    };
    final cooldownValue = dataMap['ccl'];
    final cooldownToken = switch (cooldownValue) {
      null => '',
      _ => cooldownValue.toString(),
    };
    final code = int.tryParse(json['code']?.toString() ?? '') ?? -1;
    final message = json['message']?.toString() ?? '';
    final requiresCaptcha = authCodeValue == true || authCode == '1';
    final smsSent = !requiresCaptcha &&
        (cooldownToken.isNotEmpty ||
            (dataMap.isNotEmpty && code == 1) ||
            message.contains('发送成功') ||
            message.contains('验证码已发送') ||
            message.contains('发送验证码成功'));

    return IfengSmsSendResultModel(
      code: code,
      message: message,
      requiresCaptcha: requiresCaptcha,
      smsSent: smsSent,
      authCode: authCode,
      cooldownToken: cooldownToken,
      rawData: dataMap,
    );
  }
}

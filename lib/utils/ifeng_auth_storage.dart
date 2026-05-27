import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IfengAuthSession {
  const IfengAuthSession({
    required this.token,
    required this.guid,
    required this.username,
    required this.nickname,
    required this.userImage,
    required this.auth,
    required this.smsFastPass,
  });

  final String token;
  final String guid;
  final String username;
  final String nickname;
  final String userImage;
  final String auth;
  final Map<String, dynamic> smsFastPass;

  bool get isLoggedIn {
    return token.trim().isNotEmpty &&
        guid.trim().isNotEmpty &&
        username.trim().isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'token': token,
      'guid': guid,
      'username': username,
      'nickname': nickname,
      'userImage': userImage,
      'auth': auth,
      'smsFastPass': smsFastPass,
    };
  }

  factory IfengAuthSession.fromJson(Map<String, dynamic> json) {
    final smsFastPass = json['smsFastPass'];
    return IfengAuthSession(
      token: json['token']?.toString() ?? '',
      guid: json['guid']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      userImage: json['userImage']?.toString() ?? '',
      auth: json['auth']?.toString() ?? '',
      smsFastPass: smsFastPass is Map<String, dynamic>
          ? smsFastPass
          : smsFastPass is Map
              ? smsFastPass.map((key, value) => MapEntry(key.toString(), value))
              : <String, dynamic>{},
    );
  }

  static const empty = IfengAuthSession(
    token: '',
    guid: '',
    username: '',
    nickname: '',
    userImage: '',
    auth: '',
    smsFastPass: <String, dynamic>{},
  );
}

class IfengAuthStorage {
  IfengAuthStorage._();

  static const String _sessionKey = 'ifeng_auth_session_v1';
  static final ValueNotifier<IfengAuthSession> sessionNotifier =
      ValueNotifier<IfengAuthSession>(IfengAuthSession.empty);

  static Future<IfengAuthSession> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) {
      sessionNotifier.value = IfengAuthSession.empty;
      return IfengAuthSession.empty;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        sessionNotifier.value = IfengAuthSession.empty;
        return IfengAuthSession.empty;
      }
      final session = IfengAuthSession.fromJson(decoded);
      sessionNotifier.value = session;
      return session;
    } catch (_) {
      sessionNotifier.value = IfengAuthSession.empty;
      return IfengAuthSession.empty;
    }
  }

  static Future<void> saveSession(IfengAuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
    sessionNotifier.value = session;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    sessionNotifier.value = IfengAuthSession.empty;
  }
}

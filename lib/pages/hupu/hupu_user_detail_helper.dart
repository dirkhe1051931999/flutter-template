import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_user_detail_page.dart';

Future<void> openHupuUserDetail(
  BuildContext context, {
  required String puid,
  String initialNickname = '',
  String initialAvatar = '',
}) async {
  if (puid.trim().isEmpty) {
    return;
  }
  await Navigator.of(context).push<void>(
    CupertinoPageRoute<void>(
      builder: (_) => HupuUserDetailPage(
        puid: puid,
        initialNickname: initialNickname,
        initialAvatar: initialAvatar,
      ),
    ),
  );
}

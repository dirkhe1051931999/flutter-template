import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/short_video/real_comment_sheet.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';

Future<void> showShortVideoCommentSheet(
  BuildContext context, {
  required ShortVideoItem item,
}) async {
  await showRealShortVideoCommentSheet(
    context,
    item: item,
  );
}

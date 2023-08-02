import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template_start/utils/helper.dart';
// 你可能还需要导入其他依赖，例如你的ColorHelpers类

class AppTheme {
  static final ThemeData light = ThemeData(
    primarySwatch: Colors.blue,
    fontFamily: 'NotoSansSC',
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        color: Color(ColorHelpers.fromHexString("#323232")),
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    ),
  );
}

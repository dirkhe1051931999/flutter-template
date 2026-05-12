import 'package:flutter/material.dart';
import 'package:oolaf_flutted/utils/helper.dart';

class AppTheme {
  ThemeData get light => ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSansSC',
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(ColorHelpers.fromHexString("#323232")),
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      );
}

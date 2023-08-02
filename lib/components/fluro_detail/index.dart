import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_template_start/utils/helper.dart';

class PathDetail extends StatelessWidget {
  const PathDetail({
    Key? key,
    this.message = 'Testing',
    this.color = const Color(0xFFFFFFFF),
    this.result,
  }) : super(key: key);

  final String message;
  final Color color;
  final String? result;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 50.0, top: 15.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorHelpers.blackOrWhiteContrastColor(color),
                height: 2.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 42.0),
              child: TextButton(
                onPressed: () {
                  // 这俩返回都可以
                  if (result == null) {
                    Navigator.pop(context);
                  } else {
                    FluroRouter.appRouter.pop(context, result);
                  }
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: ColorHelpers.blackOrWhiteContrastColor(color),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

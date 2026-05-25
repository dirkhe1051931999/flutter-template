import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/pages/developer/developer_tools_page.dart';

class DeveloperToolsEntry {
  DeveloperToolsEntry._();

  static const String triggerKeyword = 'OLAF';

  static bool matchesTrigger(String input) {
    return input.trim().toUpperCase() == triggerKeyword;
  }

  static Future<bool> maybeOpenFromInput(
    BuildContext context,
    String input,
  ) async {
    if (!matchesTrigger(input)) {
      return false;
    }
    await open(context);
    return true;
  }

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => const DeveloperToolsPage(),
      ),
    );
  }
}

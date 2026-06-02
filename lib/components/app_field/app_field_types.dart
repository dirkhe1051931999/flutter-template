import 'package:flutter/cupertino.dart';

enum AppFieldType { text, number, digit, textarea, password }

enum AppFieldSize { large, normal }

enum AppFieldTextAlign { left, center, right, top }

enum AppFieldClearTrigger { always, focus }

enum AppFieldFormatTrigger { onChange, onBlur }

enum AppFieldValidateTrigger { onChange, onBlur, onSubmit }

enum AppFieldValidationStatus { passed, failed }

enum AppFieldArrowDirection { left, up, right, down }

typedef AppFieldFormatter = String Function(String value);

typedef AppFieldRuleValidator = String? Function(String value);

class AppFieldAutosizeConfig {
  const AppFieldAutosizeConfig({
    this.minHeight,
    this.maxHeight,
  });

  final double? minHeight;
  final double? maxHeight;
}

class AppFieldRule {
  const AppFieldRule({
    this.required = false,
    this.pattern,
    this.validator,
    required this.message,
    this.trigger = AppFieldValidateTrigger.onBlur,
  });

  final bool required;
  final RegExp? pattern;
  final AppFieldRuleValidator? validator;
  final String message;
  final AppFieldValidateTrigger trigger;
}

class AppFieldValidateResult {
  const AppFieldValidateResult({
    required this.status,
    required this.message,
  });

  final AppFieldValidationStatus status;
  final String message;
}

TextAlign appFieldTextAlignToTextAlign(AppFieldTextAlign value) {
  return switch (value) {
    AppFieldTextAlign.left => TextAlign.left,
    AppFieldTextAlign.center => TextAlign.center,
    AppFieldTextAlign.right => TextAlign.right,
    AppFieldTextAlign.top => TextAlign.left,
  };
}

CrossAxisAlignment appFieldLabelCrossAxisAlignment(AppFieldTextAlign value) {
  return switch (value) {
    AppFieldTextAlign.top => CrossAxisAlignment.start,
    _ => CrossAxisAlignment.center,
  };
}

Alignment appFieldErrorAlignment(AppFieldTextAlign value) {
  return switch (value) {
    AppFieldTextAlign.center => Alignment.center,
    AppFieldTextAlign.right => Alignment.centerRight,
    _ => Alignment.centerLeft,
  };
}

IconData appFieldArrowIcon(AppFieldArrowDirection value) {
  return switch (value) {
    AppFieldArrowDirection.left => CupertinoIcons.chevron_left,
    AppFieldArrowDirection.up => CupertinoIcons.chevron_up,
    AppFieldArrowDirection.right => CupertinoIcons.chevron_right,
    AppFieldArrowDirection.down => CupertinoIcons.chevron_down,
  };
}

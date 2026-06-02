import 'package:flutter/cupertino.dart';

enum AppSearchShape {
  square,
  round,
}

enum AppSearchClearTrigger {
  always,
  focus,
}

enum AppSearchFormatTrigger {
  onChange,
  onBlur,
}

enum AppSearchTextAlign {
  left,
  center,
  right,
}

typedef AppSearchFormatter = String Function(String value);

TextAlign appSearchTextAlignToTextAlign(AppSearchTextAlign align) {
  return switch (align) {
    AppSearchTextAlign.left => TextAlign.left,
    AppSearchTextAlign.center => TextAlign.center,
    AppSearchTextAlign.right => TextAlign.right,
  };
}

Alignment appSearchAlignment(AppSearchTextAlign align) {
  return switch (align) {
    AppSearchTextAlign.left => Alignment.centerLeft,
    AppSearchTextAlign.center => Alignment.center,
    AppSearchTextAlign.right => Alignment.centerRight,
  };
}

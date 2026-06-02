import 'package:flutter/cupertino.dart';

enum AppCheckShape {
  round,
  square,
}

enum AppCheckLabelPosition {
  left,
  right,
}

enum AppCheckDirection {
  horizontal,
  vertical,
}

double appCheckRadius(
  AppCheckShape shape,
  double size,
) {
  return switch (shape) {
    AppCheckShape.round => size / 2,
    AppCheckShape.square => size * 0.3,
  };
}

MainAxisAlignment appCheckMainAxisAlignment(
  AppCheckLabelPosition position,
) {
  return switch (position) {
    AppCheckLabelPosition.left => MainAxisAlignment.spaceBetween,
    AppCheckLabelPosition.right => MainAxisAlignment.start,
  };
}

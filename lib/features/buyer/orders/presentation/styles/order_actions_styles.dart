import 'package:flutter/material.dart';

abstract final class OrderActionsStyles {
  static BoxDecoration containerDecoration(
    ({Color background, Color text}) colors,
  ) => BoxDecoration(
    color: colors.background,
    borderRadius: BorderRadius.circular(999),
  );

  static TextStyle labelText(({Color background, Color text}) colors) =>
      TextStyle(
        color: colors.text,
        fontSize: 12,
        height: 1,
        fontWeight: FontWeight.w800,
      );
}

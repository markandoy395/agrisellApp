import 'package:flutter/material.dart';

abstract final class RiderProfileComponentsStyles {
  static const valueText = TextStyle(
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  static TextStyle labelText(Color color) =>
      TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700);
}

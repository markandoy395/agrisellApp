import 'package:flutter/material.dart';

abstract final class RiderMapOptionsStyles {
  static BoxDecoration iconBadge(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: const BorderRadius.all(Radius.circular(8)),
  );
}

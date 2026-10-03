import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';

abstract final class RiderEarningsHistoryStyles {
  static TextStyle textStyle(RiderEarningEntry entry) => TextStyle(
    color: entry.netAmount < 0
        ? AgrisellColors.statusRedText
        : AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  static BoxDecoration decoratedBoxDecoration(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(10),
  );
}

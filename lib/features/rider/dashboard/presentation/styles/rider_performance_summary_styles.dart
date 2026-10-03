import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderPerformanceSummaryStyles {
  static const performanceSummaryText = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w900,
  );

  static const performanceDataIsNotAvailableText = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.pageBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    height: 1.1,
    fontWeight: FontWeight.w800,
  );
}

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class TrackingOrderCardStyles {
  static double imageSize(double screenWidth) =>
      screenWidth < 380 ? 72.0 : 82.0;

  static const _compactCardPadding = EdgeInsets.all(11);
  static const _regularCardPadding = EdgeInsets.all(13);
  static const _compactStatusChipConstraints = BoxConstraints(maxWidth: 190);
  static const _regularStatusChipConstraints = BoxConstraints(maxWidth: 250);

  static EdgeInsets cardPadding(double screenWidth) =>
      screenWidth < 380 ? _compactCardPadding : _regularCardPadding;

  static BoxConstraints statusChipConstraints(double screenWidth) =>
      screenWidth < 380
      ? _compactStatusChipConstraints
      : _regularStatusChipConstraints;

  static final BoxDecoration cardDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.09),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static const TextStyle orderIdStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const RoundedRectangleBorder sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
  );
}

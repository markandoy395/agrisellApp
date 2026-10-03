import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerVerificationFeedbackStyles {
  static const actionColor = Color(0xFFE65100);
  static const wrapAlignment = WrapAlignment.spaceBetween;
  static const wrapCrossAlignment = WrapCrossAlignment.center;
  static const feedbackPadding = EdgeInsets.all(16);
  static const badgePadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  static const notePadding = EdgeInsets.all(12);
  static const itemPadding = EdgeInsets.only(bottom: 6);
  static const itemIconSize = 18.0;
  static final feedbackPanel = BoxDecoration(
    color: const Color(0xFFFFF8E1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: actionColor.withValues(alpha: 0.06),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
  static final actionBadge = BoxDecoration(
    color: actionColor,
    borderRadius: BorderRadius.circular(6),
  );
  static final notePanel = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: const Color(0xFFFFE082)),
  );
  static const badgeLabel = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );
  static const requestedDate = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
    fontWeight: FontWeight.w500,
  );
  static const heading = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: Color(0xFFBF360C),
    letterSpacing: 0.5,
  );
  static const message = TextStyle(
    fontSize: 13,
    color: AgrisellColors.brandBlack,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );
  static const missingItem = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.brandBlack,
  );
}

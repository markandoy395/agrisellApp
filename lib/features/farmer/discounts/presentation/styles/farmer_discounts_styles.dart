import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerDiscountsStyles {
  static const appBarTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
  static const activeSummaryBackground = Color(0xFFE8F5E9);
  static const scheduledSummaryBackground = Color(0xFFFFF3E0);
  static const scheduledColor = Color(0xFFE65100);

  static Color statusColor(String status) => switch (status) {
    'Active' => AgrisellColors.authGreen,
    'Scheduled' => scheduledColor,
    'Ended' => AgrisellColors.mutedText,
    _ => AgrisellColors.statusRedText,
  };

  static final promotionDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AgrisellColors.borderLine),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static const promotionPadding = EdgeInsets.all(14);

  static const discountBadgePadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );

  static final discountBadgeDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(6),
  );

  static const discountBadgeText = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  static const statusBadgePadding = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 3,
  );

  static BoxDecoration statusBadgeDecoration(Color statusColor) =>
      BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      );

  static TextStyle statusBadgeText(Color statusColor) => TextStyle(
    color: statusColor,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static const promotionTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.brandBlack,
  );

  static const codeText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AgrisellColors.authGreen,
  );

  static const datesText = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
    fontWeight: FontWeight.w500,
  );

  static const commodityText = TextStyle(fontSize: 12);

  static final editButton = TextButton.styleFrom(
    foregroundColor: AgrisellColors.brandBlack,
    visualDensity: VisualDensity.compact,
  );

  static final deleteButton = TextButton.styleFrom(
    foregroundColor: AgrisellColors.statusRedText,
    visualDensity: VisualDensity.compact,
  );

  static const summaryPadding = EdgeInsets.symmetric(
    vertical: 12,
    horizontal: 10,
  );

  static BoxDecoration summaryDecoration(Color bg) => BoxDecoration(
    color: bg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static TextStyle summaryCount(Color textColor) =>
      TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor);

  static const summaryLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.mutedText,
  );

  static const loadError = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 14,
  );

  static final retryButton = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: Colors.white,
  );

  static const summarySectionPadding = EdgeInsets.fromLTRB(16, 16, 16, 8);

  static const emptyDescriptionPadding = EdgeInsets.symmetric(horizontal: 40);

  static const emptyDescription = TextStyle(
    fontSize: 13,
    color: AgrisellColors.mutedText,
  );

  static final createFirstButton = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  static const boldButtonText = TextStyle(fontWeight: FontWeight.w700);

  static const listPadding = EdgeInsets.fromLTRB(16, 8, 16, 80);

  static const listItemPadding = EdgeInsets.only(bottom: 12);

  static final confirmDeleteButton = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.statusRedText,
    foregroundColor: Colors.white,
  );
}

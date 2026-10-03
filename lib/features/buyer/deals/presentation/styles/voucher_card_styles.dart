import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined styles and variants for VoucherCard.
abstract final class VoucherCardStyles {
  // Card
  static final cardRadius = BorderRadius.circular(16);
  static const cardShadow = [
    BoxShadow(
      color: Color(0x0F000000), // brandBlack with 0.06 alpha
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static Border cardBorder({required bool isEligibleActive}) => Border.all(
    color: isEligibleActive ? AgrisellColors.authGreen : AgrisellColors.borderLine,
    width: isEligibleActive ? 1.5 : 1,
  );

  static BoxDecoration cardDecoration({required bool isEligibleActive}) =>
      BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: cardRadius,
        border: cardBorder(isEligibleActive: isEligibleActive),
        boxShadow: cardShadow,
      );

  // Header banner
  static const headerPadding = EdgeInsets.symmetric(horizontal: 14, vertical: 10);
  static const farmerHeaderColor = Color(0xFFE8F5E9);
  static const standardHeaderColor = AgrisellColors.forestSoft;

  static Color headerColor({required bool isFarmer}) =>
      isFarmer ? farmerHeaderColor : standardHeaderColor;

  static final headerBorder = Border(
    bottom: BorderSide(
      color: AgrisellColors.borderLine.withValues(alpha: 0.5),
    ),
  );

  // Discount badge
  static const discountBadgePadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );
  static final discountBadgeRadius = BorderRadius.circular(6);
  static final discountBadgeDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: discountBadgeRadius,
  );
  static const discountBadgeTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );

  // New users badge
  static const newUsersBadgePadding = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 3,
  );
  static final newUsersBadgeRadius = BorderRadius.circular(4);
  static final newUsersBadgeDecoration = BoxDecoration(
    color: const Color(0x26FF9800), // 0.15 alpha
    borderRadius: newUsersBadgeRadius,
    border: Border.all(
      color: const Color(0x66FF9800), // 0.4 alpha
    ),
  );
  static const newUsersBadgeTextStyle = TextStyle(
    color: Color(0xFFE65100),
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  // Farm info
  static const farmIconSize = 14.0;
  static const farmIconColor = AgrisellColors.authGreen;
  static const farmNameTextStyle = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  // Body
  static const bodyPadding = EdgeInsets.all(14);
  static const titleTextStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const expiryIconSize = 13.0;
  static const expiryIconColor = AgrisellColors.mutedText;
  static const expiryTextStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const bulletTextStyle = TextStyle(color: AgrisellColors.mutedText);
  static const productCountTextStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Eligible savings badge
  static const eligibleBadgePadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );
  static final eligibleBadgeRadius = BorderRadius.circular(6);
  static final eligibleBadgeDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: eligibleBadgeRadius,
  );
  static const eligibleBadgeTextStyle = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  // Ineligible reason
  static const ineligibleTextStyle = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Code pill
  static const codeBoxPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );
  static final codeBoxRadius = BorderRadius.circular(8);
  static final codeBoxDecoration = BoxDecoration(
    color: AgrisellColors.homeBackground,
    borderRadius: codeBoxRadius,
    border: Border.all(color: AgrisellColors.borderLine),
  );
  static const codeTextStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
  );
  static const copyIconSize = 13.0;
  static const copyIconColor = AgrisellColors.authGreen;

  // Buttons
  static final shopItemsButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.authGreen),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
  static const shopItemsButtonTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static final applyButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 0,
  );
  static const applyButtonTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
}

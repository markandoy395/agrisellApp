import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Centralized styles, dimensions, and typography for the delivery waybill sheet.
abstract final class DeliveryWaybillStyles {
  // Dimensions & Insets
  static const double sheetMaxHeightFactor = 0.9;
  static const double sheetCornerRadius = 20.0;
  static const double handleWidth = 38.0;
  static const double handleHeight = 4.0;
  static const double handleRadius = 2.0;
  static const EdgeInsets handleMargin = EdgeInsets.only(top: 10, bottom: 4);

  static const EdgeInsets headerPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsets scrollPadding = EdgeInsets.all(16);
  static const EdgeInsets previewPadding = EdgeInsets.all(14);
  static const EdgeInsets actionsPadding =
      EdgeInsets.fromLTRB(16, 12, 16, 12);

  static const double previewBorderRadius = 12.0;
  static const double previewBorderWidth = 1.5;

  static const EdgeInsets badgePadding =
      EdgeInsets.symmetric(horizontal: 9, vertical: 4);
  static const EdgeInsets barcodePadding =
      EdgeInsets.symmetric(vertical: 6);
  static const EdgeInsets infoBoxPadding =
      EdgeInsets.symmetric(horizontal: 10, vertical: 8);
  static const EdgeInsets itemRowPadding =
      EdgeInsets.symmetric(vertical: 2);

  static const double primaryActionHeight = 44.0;
  static const double secondaryActionHeight = 40.0;
  static const double primaryButtonRadius = 10.0;
  static const double secondaryButtonRadius = 8.0;

  // Sheet & Container Decorations
  static const BoxDecoration sheetDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(sheetCornerRadius),
    ),
  );

  static final BoxDecoration handleDecoration = BoxDecoration(
    color: AgrisellColors.borderLine,
    borderRadius: BorderRadius.circular(handleRadius),
  );

  static final BoxDecoration previewCardDecoration = BoxDecoration(
    color: AgrisellColors.pageBackground,
    borderRadius: BorderRadius.circular(previewBorderRadius),
    border: Border.all(
      color: AgrisellColors.borderLine,
      width: previewBorderWidth,
    ),
  );

  static final BoxDecoration codBadgeDecoration = BoxDecoration(
    color: AgrisellColors.statusOrangeBackground,
    borderRadius: BorderRadius.circular(999),
  );

  static final BoxDecoration prepaidBadgeDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(999),
  );

  static BoxDecoration badgeDecoration({required bool isCod}) =>
      isCod ? codBadgeDecoration : prepaidBadgeDecoration;

  static final BoxDecoration barcodeDecoration = BoxDecoration(
    color: AgrisellColors.limeSoft,
    borderRadius: BorderRadius.circular(6),
    border: Border.all(
      color: AgrisellColors.forestGreen.withValues(alpha: 0.3),
      style: BorderStyle.solid,
    ),
  );

  static final BoxDecoration infoBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  // Typography
  static const TextStyle headerTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle headerSubtitle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );
  static const TextStyle waybillNumber = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );
  static const TextStyle orderNumber = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle codBadgeText = TextStyle(
    color: AgrisellColors.statusOrangeText,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle prepaidBadgeText = TextStyle(
    color: AgrisellColors.forestGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  static TextStyle badgeTextStyle({required bool isCod}) =>
      isCod ? codBadgeText : prepaidBadgeText;

  static const TextStyle barcodeText = TextStyle(
    fontFamily: 'monospace',
    fontSize: 15,
    fontWeight: FontWeight.bold,
    letterSpacing: 4,
    color: AgrisellColors.forestGreen,
  );
  static const TextStyle packageItemsHeading = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle itemName = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
  );
  static const TextStyle itemTotal = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle totalAmountLabel = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle totalAmountValue = TextStyle(
    color: AgrisellColors.forestGreen,
    fontSize: 15,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle infoBoxTitle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle infoBoxLine = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.25,
  );

  static const TextStyle primaryButtonText = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 14,
  );
  static const TextStyle secondaryButtonText = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
  );

  // Button Styles
  static final ButtonStyle printButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(primaryButtonRadius),
    ),
  );

  static final ButtonStyle secondaryActionButtonStyle =
      OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.borderLine),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(secondaryButtonRadius),
    ),
  );
}

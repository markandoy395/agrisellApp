import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderCashOutDialogStyles {
  // Dimensions & Sizes
  static const double dialogRadius = 16.0;
  static const double dialogMaxWidth = 460.0;
  static const double headerIconSize = 22.0;
  static const double headerIconRadius = 10.0;
  static const double headerCloseSize = 20.0;
  static const double balanceRadius = 12.0;
  static const double errorRadius = 8.0;
  static const double errorIconSize = 18.0;
  static const double controlRadius = 10.0;
  static const double emptyMethodIconSize = 18.0;
  static const double buttonRadius = 10.0;
  static const double spinnerSize = 20.0;
  static const double spinnerStroke = 2.0;

  // Gaps & Spacing
  static const double headerGap = 12.0;
  static const double subtitleGap = 6.0;
  static const double sectionGap = 16.0;
  static const double balanceContentGap = 8.0;
  static const double errorContentGap = 8.0;
  static const double errorSectionGap = 14.0;
  static const double labelGap = 8.0;
  static const double inputLabelGap = 6.0;
  static const double emptyMethodGap = 8.0;
  static const double quickChipsSpacing = 8.0;
  static const double notesSectionGap = 14.0;
  static const double actionsGap = 22.0;
  static const double buttonSpacing = 12.0;
  static const double buttonVerticalPadding = 12.0;

  // Paddings
  static const EdgeInsets dialogPadding = EdgeInsets.all(22);
  static const EdgeInsets headerIconPadding = EdgeInsets.all(8);
  static const EdgeInsets balancePadding = EdgeInsets.all(14);
  static const EdgeInsets errorPadding = EdgeInsets.all(10);
  static const EdgeInsets emptyMethodPadding = EdgeInsets.all(12);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );
  static const EdgeInsets quickChipsMargin = EdgeInsets.only(top: 8);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    vertical: buttonVerticalPadding,
  );

  // Text Styles
  static const TextStyle headerTitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.headingGreen,
  );

  static const TextStyle headerSubtitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    color: AgrisellColors.mutedText,
  );

  static const TextStyle balanceLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    color: AgrisellColors.brandBlack,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle balanceSubtitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    color: AgrisellColors.mutedText,
  );

  static const TextStyle balanceValue = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w900,
    color: AgrisellColors.authGreen,
  );

  static const TextStyle errorText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.brandBlack,
  );

  static const TextStyle emptyMethodText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle methodDropdownText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 13,
  );

  static const TextStyle amountPrefix = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.headingGreen,
  );

  static const TextStyle quickChipLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle quickChipAllLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.authGreen,
  );

  static const TextStyle cancelButtonText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.brandBlack,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle submitButtonText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.surface,
    fontWeight: FontWeight.w700,
  );

  // Decorations & Shapes
  static final RoundedRectangleBorder dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(dialogRadius),
  );

  static final BoxDecoration headerIconDecoration = BoxDecoration(
    color: AgrisellColors.statusGreenBackground,
    borderRadius: BorderRadius.circular(headerIconRadius),
  );

  static final BoxDecoration balanceCardDecoration = BoxDecoration(
    color: AgrisellColors.statusGreenBackground,
    borderRadius: BorderRadius.circular(balanceRadius),
  );

  static final BoxDecoration errorBannerDecoration = BoxDecoration(
    color: AgrisellColors.statusRedBackground,
    borderRadius: BorderRadius.circular(errorRadius),
  );

  static final BoxDecoration emptyMethodDecoration = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: BorderRadius.circular(controlRadius),
  );

  static InputDecoration inputDecoration({
    String? hintText,
    String? prefixText,
    TextStyle? prefixStyle,
  }) => InputDecoration(
    hintText: hintText,
    prefixText: prefixText,
    prefixStyle: prefixStyle,
    filled: true,
    fillColor: AgrisellColors.searchBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(controlRadius),
      borderSide: BorderSide.none,
    ),
    contentPadding: inputPadding,
  );

  static final ButtonStyle cancelButtonStyle = OutlinedButton.styleFrom(
    padding: buttonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
    side: const BorderSide(color: AgrisellColors.borderLine),
  );

  static final ButtonStyle submitButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    padding: buttonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
  );
}

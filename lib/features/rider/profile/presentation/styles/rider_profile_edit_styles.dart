import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'rider_profile_design_styles.dart';

abstract final class RiderProfileEditStyles {
  // Drag Handle
  static const double dragHandleWidth = 36.0;
  static const double dragHandleHeight = 4.0;
  static final BoxDecoration dragHandleDecoration = BoxDecoration(
    color: AgrisellColors.borderLine,
    borderRadius: BorderRadius.circular(8),
  );

  // Paddings
  static EdgeInsets sheetPadding(BuildContext context) => EdgeInsets.fromLTRB(
    16,
    12,
    16,
    16 +
        (MediaQuery.viewInsetsOf(context).bottom >
                MediaQuery.paddingOf(context).bottom
            ? MediaQuery.viewInsetsOf(context).bottom
            : MediaQuery.paddingOf(context).bottom),
  );

  static const EdgeInsets fieldBottomPadding = EdgeInsets.only(bottom: 8);
  static const EdgeInsets errorPadding = EdgeInsets.only(top: 8);

  // Typography
  static const TextStyle titleStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    color: AgrisellColors.mutedText,
  );

  static const TextStyle sectionHeaderStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle errorTextStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.statusRedText,
    fontSize: 12,
  );

  // Buttons
  static final ButtonStyle actionButtonStyle = OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(38),
  ).merge(RiderProfileDesignStyles.secondary);

  static final ButtonStyle saveButtonStyle = FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(38),
  ).merge(RiderProfileDesignStyles.primary);

  // Spacings
  static const SizedBox spacingSmall = SizedBox(height: 4);
  static const SizedBox spacingMedium = SizedBox(height: 8);
  static const SizedBox spacingLarge = SizedBox(height: 12);
  static const SizedBox buttonRowSpacing = SizedBox(width: 12);
}

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

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
    16 + MediaQuery.viewInsetsOf(context).bottom,
  );

  static const EdgeInsets fieldBottomPadding = EdgeInsets.only(bottom: 8);
  static const EdgeInsets errorPadding = EdgeInsets.only(top: 8);

  // Typography
  static const TextStyle titleStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
  );

  static const TextStyle sectionHeaderStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle errorTextStyle = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
  );

  // Buttons
  static final ButtonStyle actionButtonStyle = OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(38),
  );

  static final ButtonStyle saveButtonStyle = FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(38),
  );

  // Spacings
  static const SizedBox spacingSmall = SizedBox(height: 4);
  static const SizedBox spacingMedium = SizedBox(height: 8);
  static const SizedBox spacingLarge = SizedBox(height: 12);
  static const SizedBox buttonRowSpacing = SizedBox(width: 12);
}

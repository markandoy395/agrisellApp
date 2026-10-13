import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

import '../widgets/farmer_profile_style.dart';

abstract final class FarmerFarmEditStyles {
  static const cardPadding = EdgeInsets.all(22);

  static const titleColor = AgrisellColors.authGreen;
  static const subtitleColor = AgrisellColors.mutedText;
  static const errorColor = Color(0xFFAB342D);
  static const primaryGreen = AgrisellColors.authGreen;

  static const titleStyle = TextStyle(
    color: titleColor,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const subtitleStyle = TextStyle(color: subtitleColor, fontSize: 14);

  static const capturingTextStyle = TextStyle(
    color: FarmerProfileStyle.muted,
    fontSize: 12,
  );

  static const errorTextStyle = TextStyle(color: errorColor, fontSize: 13);

  static final cancelButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryGreen,
    minimumSize: const Size(125, 56),
    maximumSize: Size.infinite,
    side: const BorderSide(color: primaryGreen),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static const cancelButtonTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
  );

  static final saveButtonStyle = FilledButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: AgrisellColors.surface,
    minimumSize: const Size(140, 56),
    maximumSize: Size.infinite,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static const saveButtonTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
  );

  static const spacingTitleSubtitle = SizedBox(height: 2);
  static const spacingHeaderBottom = SizedBox(height: 20);
  static const spacingProgressText = SizedBox(height: 8);
  static const spacingCapturingBottom = SizedBox(height: 16);
  static const spacingErrorBottom = SizedBox(height: 8);
  static const spacingFields = SizedBox(height: 16);
  static const spacingActionsTop = SizedBox(height: 12);
  static const spacingBetweenButtons = SizedBox(width: 12);
}

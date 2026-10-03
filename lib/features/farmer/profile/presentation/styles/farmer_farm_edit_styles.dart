import 'package:flutter/material.dart';

import '../widgets/farmer_profile_style.dart';

abstract final class FarmerFarmEditStyles {
  static const cardPadding = EdgeInsets.all(22);

  static const titleColor = Color(0xFF14763D);
  static const subtitleColor = Color(0xFF677999);
  static const errorColor = Color(0xFFAB342D);
  static const primaryGreen = Color(0xFF14763D);

  static const titleStyle = TextStyle(
    color: titleColor,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const subtitleStyle = TextStyle(
    color: subtitleColor,
    fontSize: 14,
  );

  static const capturingTextStyle = TextStyle(
    color: FarmerProfileStyle.muted,
    fontSize: 12,
  );

  static const errorTextStyle = TextStyle(
    color: errorColor,
    fontSize: 13,
  );

  static final cancelButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: FarmerProfileStyle.green,
    minimumSize: const Size(125, 48),
    side: const BorderSide(color: FarmerProfileStyle.green),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  static const cancelButtonTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
  );

  static final saveButtonStyle = FilledButton.styleFrom(
    backgroundColor: primaryGreen,
    minimumSize: const Size(140, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
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
  static const psgcLabelPadding = EdgeInsets.only(top: 8);
}

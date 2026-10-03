import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerInformationRequestStyles {
  static const white = Colors.white;
  static const background = AgrisellColors.homeBackground;
  static const green = AgrisellColors.authGreen;
  static const alignStart = CrossAxisAlignment.start;
  static const centeredText = TextAlign.center;
  static const fullWidth = double.infinity;
  static const smallGap = 4.0;
  static const labelGap = 6.0;
  static const inlineGap = 8.0;
  static const sectionGap = 12.0;
  static const fieldGap = 14.0;
  static const formHeaderGap = 18.0;
  static const feedbackGap = 20.0;
  static const submitGap = 24.0;
  static const submitHeight = 48.0;
  static const spinnerSize = 22.0;
  static const spinnerStrokeWidth = 2.5;
  static const uploadImageHeight = 60.0;
  static const uploadIconSize = 32.0;
  static const fieldIconSize = 18.0;
  static const notesLines = 3;
  static const uploadImageFit = BoxFit.cover;
  static const contentPadding = EdgeInsets.fromLTRB(16, 16, 16, 40);
  static const formPadding = EdgeInsets.all(18);
  static const uploadPadding = EdgeInsets.all(12);
  static final uploadRadius = BorderRadius.circular(12);
  static final previewRadius = BorderRadius.circular(8);
  static const title = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
  static const formTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.brandBlack,
  );
  static const subtitle = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
  );
  static const sectionTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.brandBlack,
  );
  static const fieldLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.brandBlack,
  );
  static const uploadTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.brandBlack,
  );
  static final submitButton = ElevatedButton.styleFrom(
    backgroundColor: green,
    foregroundColor: white,
    shape: RoundedRectangleBorder(borderRadius: uploadRadius),
    elevation: 0,
  );
  static const flatElevation = 0.0;
}

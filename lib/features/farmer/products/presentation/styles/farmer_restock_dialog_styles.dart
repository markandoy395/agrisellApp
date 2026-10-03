import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerRestockDialogStyles {
  // Dialog container
  static const dialogBackground = AgrisellColors.surface;
  static final dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  );
  static const dialogTitlePadding = EdgeInsets.fromLTRB(22, 22, 22, 0);
  static const dialogContentPadding = EdgeInsets.fromLTRB(22, 16, 22, 4);
  static const dialogActionsPadding = EdgeInsets.fromLTRB(14, 8, 14, 14);

  // Header
  static const headerIconBoxSize = 40.0;
  static final headerIconBoxDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(12),
  );
  static const headerIconColor = AgrisellColors.authGreen;
  static const headerIconSize = 21.0;
  static const headerTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );
  static const headerSubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static const spacingHeaderIcon = SizedBox(width: 11);
  static const spacingHeaderTitle = SizedBox(height: 2);

  // Stock summary
  static const stockSummaryPadding = EdgeInsets.all(13);
  static final stockSummaryDecoration = BoxDecoration(
    color: AgrisellColors.limeSoft,
    borderRadius: BorderRadius.circular(14),
  );
  static const stockSummaryArrowColor = AgrisellColors.authGreen;
  static const stockSummaryArrowSize = 20.0;
  static const stockSummaryLabelStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static const stockSummaryValueStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );
  static const spacingStockValue = SizedBox(height: 3);

  // Form fields & labels
  static const fieldLabelStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  );
  static const fieldFocusedBorderSide = BorderSide(
    color: AgrisellColors.authGreen,
    width: 1.4,
  );
  static final fieldFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: fieldFocusedBorderSide,
  );

  static InputDecoration quantityDecoration({required String unit}) =>
      InputDecoration(
        hintText: '0',
        suffixText: unit,
        filled: true,
        fillColor: AgrisellColors.searchBackground,
        border: fieldBorder,
        focusedBorder: fieldFocusedBorder,
      );

  static final notesDecoration = InputDecoration(
    labelText: 'Notes (optional)',
    hintText: 'Example: New supplier delivery',
    filled: true,
    fillColor: AgrisellColors.searchBackground,
    border: fieldBorder,
  );

  // Action buttons
  static final confirmButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
  );

  // Layout spacings
  static const spacingSummary = SizedBox(height: 16);
  static const spacingQuantityLabel = SizedBox(height: 7);
  static const spacingField = SizedBox(height: 13);
}

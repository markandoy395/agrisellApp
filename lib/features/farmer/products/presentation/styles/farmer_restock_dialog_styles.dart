import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerRestockDialogStyles {
  static const dialogBackground = AgrisellColors.surface;
  static const sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  );
  static final handleDecoration = BoxDecoration(
    color: AgrisellColors.dividerLine.withValues(alpha: .65),
    borderRadius: BorderRadius.circular(8),
  );
  static const headerIconBoxSize = 48.0;
  static final headerIconBoxDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(14),
  );
  static const headerIconColor = AgrisellColors.authGreen;
  static const headerIconSize = 26.0;
  static const headerTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );
  static const headerSubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static const spacingHeaderIcon = SizedBox(width: 16);
  static const spacingHeaderTitle = SizedBox(height: 2);
  static const stockSummaryPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 16,
  );
  static final stockSummaryDecoration = BoxDecoration(
    color: AgrisellColors.limeSoft,
    borderRadius: BorderRadius.circular(16),
  );
  static const stockSummaryArrowColor = AgrisellColors.authGreen;
  static const stockSummaryArrowSize = 24.0;
  static const stockSummaryLabelStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static const stockSummaryValueStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );
  static const spacingStockValue = SizedBox(height: 4);
  static const fieldLabelStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
  static const noteLabelStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );
  static const inputTextStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 16,
  );
  static final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AgrisellColors.borderLine),
  );
  static final fieldFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AgrisellColors.authGreen, width: 1.4),
  );
  static InputDecoration quantityDecoration({required String unit}) =>
      InputDecoration(
        hintText: '0',
        hintStyle: headerSubtitleStyle,
        suffixText: unit,
        suffixStyle: headerSubtitleStyle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: AgrisellColors.searchBackground,
        border: fieldFocusedBorder,
        enabledBorder: fieldFocusedBorder,
        focusedBorder: fieldFocusedBorder,
      );
  static final notesDecoration = InputDecoration(
    hintText: 'Example: New supplier delivery',
    filled: true,
    fillColor: AgrisellColors.searchBackground,
    border: fieldBorder,
    enabledBorder: fieldBorder,
    focusedBorder: fieldFocusedBorder,
  );
  // Retain the compact shared style used by farm creation.
  static final confirmButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
  );
  static final restockButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    minimumSize: const Size(0, 48),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
  );
  static final cancelButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.authGreen),
    minimumSize: const Size(0, 48),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
  );
  static const spacingSummary = SizedBox(height: 18);
  static const spacingQuantityLabel = SizedBox(height: 8);
  static const spacingField = SizedBox(height: 16);
}

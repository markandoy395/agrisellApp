import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Design tokens and pre-computed styles for the GCash payment sheet.
abstract final class GcashPaymentSheetStyles {
  // Dimensions & Sizes
  static const double sheetTopRadius = 20.0;
  static const double headerGap = 14.0;
  static const double headerSubtitleGap = 2.0;
  static const double sectionGap = 12.0;
  static const double fieldGap = 10.0;
  static const double previewInfoGap = 10.0;
  static const double infoButtonGap = 8.0;
  static const double errorGap = 7.0;

  static const double previewSize = 46.0;
  static const double previewRadius = 8.0;
  static const double previewPlaceholderIconSize = 20.0;

  static const double referenceRadius = 10.0;
  static const double prefixIconSize = 19.0;

  static const double submitButtonHeight = 38.0;
  static const double submitButtonRadius = 8.0;
  static const double submitIconSize = 17.0;

  static const double uploadButtonHeight = 36.0;
  static const double uploadButtonRadius = 8.0;
  static const double uploadIconSize = 16.0;

  static const double closeIconSize = 20.0;

  // Paddings
  static const EdgeInsets sheetBasePadding = EdgeInsets.fromLTRB(
    16,
    10,
    16,
    16,
  );
  static const EdgeInsets receiptPickerPadding = EdgeInsets.all(11);
  static const EdgeInsets uploadButtonPadding = EdgeInsets.symmetric(
    horizontal: 10,
  );

  static EdgeInsets sheetPadding(double bottomInset) =>
      EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset);

  // Colors
  static const Color sheetBackgroundColor = AgrisellColors.surface;
  static const Color previewBackgroundColor = AgrisellColors.surface;
  static const Color previewPlaceholderIconColor = AgrisellColors.mutedText;
  static const Color referenceFillColor = AgrisellColors.searchBackground;

  // Text Styles
  static const TextStyle headerTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle headerSubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const TextStyle referenceInputTextStyle = TextStyle(fontSize: 13);

  static const TextStyle receiptTitleStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle receiptSubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const TextStyle receiptErrorTextStyle = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle uploadButtonTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle submitButtonTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  // Borders & Shapes
  static const RoundedRectangleBorder sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(sheetTopRadius)),
  );

  static final BorderRadius previewBorderRadius = BorderRadius.circular(
    previewRadius,
  );
  static final BorderRadius receiptPickerBorderRadius = BorderRadius.circular(
    10,
  );
  static final BorderRadius referenceInputBorderRadius = BorderRadius.circular(
    referenceRadius,
  );
  static final BorderRadius submitButtonBorderRadius = BorderRadius.circular(
    submitButtonRadius,
  );
  static final BorderRadius uploadButtonBorderRadius = BorderRadius.circular(
    uploadButtonRadius,
  );

  // Predefined BoxDecorations
  static final BoxDecoration receiptPickerDefaultDecoration = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: receiptPickerBorderRadius,
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static final BoxDecoration receiptPickerSelectedDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: receiptPickerBorderRadius,
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static final BoxDecoration receiptPickerErrorDecoration = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: receiptPickerBorderRadius,
    border: Border.all(color: AgrisellColors.statusRedText),
  );

  static final BoxDecoration receiptPickerSelectedErrorDecoration =
      BoxDecoration(
        color: AgrisellColors.forestSoft,
        borderRadius: receiptPickerBorderRadius,
        border: Border.all(color: AgrisellColors.statusRedText),
      );

  static BoxDecoration receiptPickerDecoration({
    required bool hasSelected,
    required bool hasError,
  }) {
    if (hasError) {
      return hasSelected
          ? receiptPickerSelectedErrorDecoration
          : receiptPickerErrorDecoration;
    }
    return hasSelected
        ? receiptPickerSelectedDecoration
        : receiptPickerDefaultDecoration;
  }

  // Input Decorations
  static final InputDecoration referenceInputDecoration = InputDecoration(
    labelText: 'GCash reference number',
    hintText: 'Example: 1234 567 890123',
    helperText: 'Enter the 13-digit number printed on your receipt.',
    helperMaxLines: 2,
    prefixIcon: const Icon(Icons.receipt_long_outlined, size: prefixIconSize),
    filled: true,
    fillColor: referenceFillColor,
    border: OutlineInputBorder(
      borderRadius: referenceInputBorderRadius,
      borderSide: BorderSide.none,
    ),
  );

  // Button Styles
  static final ButtonStyle submitButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    minimumSize: const Size(0, 48),
    maximumSize: Size.infinite,
    shape: RoundedRectangleBorder(borderRadius: submitButtonBorderRadius),
  );

  static final ButtonStyle uploadButtonStyle = OutlinedButton.styleFrom(
    maximumSize: Size.infinite,
    padding: uploadButtonPadding,
    foregroundColor: AgrisellColors.authGreen,
    shape: RoundedRectangleBorder(borderRadius: uploadButtonBorderRadius),
  );
}

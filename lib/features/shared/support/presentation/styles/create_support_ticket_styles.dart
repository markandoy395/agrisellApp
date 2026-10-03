import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Centralized styles, colors, dimensions, and decorations for the Create Support Ticket screen.
abstract final class CreateSupportTicketStyles {
  // Colors
  static const Color backgroundColor = AgrisellColors.homeBackground;
  static const Color surfaceColor = AgrisellColors.surface;
  static const Color appBarTitleColor = AgrisellColors.headingGreen;
  static const Color primaryGreen = AgrisellColors.forestGreen;
  static const Color headingTextColor = AgrisellColors.headingGreen;
  static const Color mutedTextColor = AgrisellColors.mutedText;
  static const Color borderLineColor = AgrisellColors.borderLine;
  static const Color infoBackgroundColor = AgrisellColors.limeSoft;
  static final Color infoBorderColor = AgrisellColors.limeGreen.withValues(alpha: 0.3);
  static const Color errorColor = AgrisellColors.unavailableRed;

  // Dimensions & Spacings
  static const EdgeInsets screenPadding = EdgeInsets.all(16);
  static const double sectionSpacing = 18.0;
  static const double fieldLabelSpacing = 6.0;
  static const double chipSpacing = 8.0;
  static const double chipRunSpacing = 8.0;
  static const double chipRightMargin = 8.0;
  static const double submitSpacing = 24.0;
  static const double submitButtonHeight = 50.0;
  static const double submitIndicatorSize = 24.0;
  static const double submitIndicatorStroke = 2.5;

  static const EdgeInsets infoCardPadding = EdgeInsets.all(14);
  static const double infoIconSize = 24.0;
  static const double infoContentSpacing = 12.0;
  static const double chipAvatarSize = 16.0;

  static const EdgeInsets subjectContentPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );

  static const EdgeInsets messageContentPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 14,
  );

  // Border Radii
  static const double cardRadius = 12.0;
  static const double chipBorderRadius = 10.0;

  // Text Styles
  static const TextStyle appBarTitle = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 15,
  );

  static final TextStyle infoText = TextStyle(
    fontSize: 13,
    color: headingTextColor.withValues(alpha: 0.9),
    height: 1.35,
  );

  static const TextStyle sectionHeading = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: headingTextColor,
  );

  static TextStyle categoryChipLabel(bool isSelected) => TextStyle(
    color: isSelected ? Colors.white : headingTextColor,
    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
    fontSize: 13,
  );

  static TextStyle priorityChipLabel({
    required bool isSelected,
    required Color textColor,
  }) => TextStyle(
    color: isSelected ? textColor : mutedTextColor,
    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
    fontSize: 13,
  );

  static const TextStyle inputHint = TextStyle(
    color: mutedTextColor,
    fontSize: 14,
  );

  static const TextStyle submitButtonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  // Box Decorations
  static final BoxDecoration infoCardDecoration = BoxDecoration(
    color: infoBackgroundColor,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: infoBorderColor),
  );

  // Chip Shapes
  static OutlinedBorder categoryChipShape(bool isSelected) =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(chipBorderRadius),
        side: BorderSide(
          color: isSelected ? primaryGreen : borderLineColor,
        ),
      );

  static OutlinedBorder priorityChipShape({
    required bool isSelected,
    required Color activeColor,
  }) =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(chipBorderRadius),
        side: BorderSide(
          color: isSelected
              ? activeColor.withValues(alpha: 0.5)
              : borderLineColor,
        ),
      );

  // Input Decorations
  static InputDecoration inputDecoration({
    required String hintText,
    bool hasCounter = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: inputHint,
      filled: true,
      fillColor: surfaceColor,
      contentPadding: hasCounter ? subjectContentPadding : messageContentPadding,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: borderLineColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: borderLineColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 1.5,
        ),
      ),
      counterText: hasCounter ? '' : null,
    );
  }

  // Button Style
  static final ButtonStyle submitButtonStyle = FilledButton.styleFrom(
    backgroundColor: primaryGreen,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(cardRadius),
    ),
  );

  // SnackBars
  static SnackBar successSnackBar(String ticketNumber) {
    return SnackBar(
      content: Text('Support ticket $ticketNumber created successfully!'),
      backgroundColor: primaryGreen,
    );
  }

  static SnackBar errorSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: errorColor,
    );
  }
}

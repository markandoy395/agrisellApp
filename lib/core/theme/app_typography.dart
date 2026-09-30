import 'package:flutter/material.dart';

/// Centralized typography scale for AgriSell conforming to agent rules:
/// UI font sizes from 12 to 15 only, with headers larger than body copy.
///
/// Standard token hierarchy:
/// - Display: 15sp / 800
/// - Headline: 15sp / 700
/// - Title: 15sp / 700
/// - Subtitle: 14sp / 700
/// - Body large: 14sp / 500
/// - Body: 13sp / 400
/// - Body small: 13sp / 400
/// - Button: 13sp / 600
/// - Caption: 12sp / 500
/// - Badge: 12sp / 700
abstract final class AppTypography {
  static const String fontFamily = 'Poppins';

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: 0.3,
  );

  /// Generates the Material 3 [TextTheme] mapped to AgriSell tokens within [12, 15].
  static TextTheme createTextTheme({
    Color? displayColor,
    Color? bodyColor,
  }) {
    final dColor = displayColor;
    final bColor = bodyColor;

    return TextTheme(
      displayLarge: display.copyWith(color: dColor),
      displayMedium: display.copyWith(color: dColor),
      displaySmall: display.copyWith(color: dColor),
      headlineLarge: headline.copyWith(color: dColor),
      headlineMedium: headline.copyWith(color: dColor),
      headlineSmall: headline.copyWith(color: dColor),
      titleLarge: title.copyWith(color: dColor),
      titleMedium: subtitle.copyWith(color: dColor),
      titleSmall: bodyLarge.copyWith(color: dColor, fontWeight: FontWeight.w600),
      bodyLarge: bodyLarge.copyWith(color: bColor),
      bodyMedium: body.copyWith(color: bColor),
      bodySmall: bodySmall.copyWith(color: bColor),
      labelLarge: button.copyWith(color: bColor),
      labelMedium: caption.copyWith(color: bColor),
      labelSmall: badge.copyWith(color: bColor),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

void main() {
  group('AppTypography Token Scale', () {
    test('verifies standard token sizes within 12-15 range and weights', () {
      expect(AppTypography.display.fontSize, 15);
      expect(AppTypography.display.fontWeight, FontWeight.w800);

      expect(AppTypography.headline.fontSize, 15);
      expect(AppTypography.headline.fontWeight, FontWeight.w700);

      expect(AppTypography.title.fontSize, 15);
      expect(AppTypography.title.fontWeight, FontWeight.w700);

      expect(AppTypography.subtitle.fontSize, 14);
      expect(AppTypography.subtitle.fontWeight, FontWeight.w700);
      expect(AppTypography.subtitle.fontFamily, 'Poppins');

      expect(AppTypography.bodyLarge.fontSize, 14);
      expect(AppTypography.bodyLarge.fontWeight, FontWeight.w500);

      expect(AppTypography.body.fontSize, 13);
      expect(AppTypography.body.fontWeight, FontWeight.w400);

      expect(AppTypography.bodySmall.fontSize, 13);
      expect(AppTypography.bodySmall.fontWeight, FontWeight.w400);

      expect(AppTypography.button.fontSize, 13);
      expect(AppTypography.button.fontWeight, FontWeight.w600);

      expect(AppTypography.caption.fontSize, 12);
      expect(AppTypography.caption.fontWeight, FontWeight.w500);

      expect(AppTypography.badge.fontSize, 12);
      expect(AppTypography.badge.fontWeight, FontWeight.w700);

      expect(AppTypography.fontFamily, 'Poppins');
    });

    test('verifies createTextTheme integration conforms to 12-15 limits', () {
      final textTheme = AppTypography.createTextTheme(
        displayColor: Colors.black,
        bodyColor: Colors.grey,
      );

      expect(textTheme.displayLarge?.fontSize, 15);
      expect(textTheme.headlineMedium?.fontSize, 15);
      expect(textTheme.titleLarge?.fontSize, 15);
      expect(textTheme.titleMedium?.fontSize, 14);
      expect(textTheme.bodyLarge?.fontSize, 14);
      expect(textTheme.bodyMedium?.fontSize, 13);
      expect(textTheme.bodySmall?.fontSize, 13);
      expect(textTheme.labelLarge?.fontSize, 13);
      expect(textTheme.labelMedium?.fontSize, 12);
      expect(textTheme.labelSmall?.fontSize, 12);
    });

    test('verifies AgrisellTheme light text theme and button theme', () {
      final theme = AgrisellTheme.light;
      expect(theme.textTheme.titleLarge?.fontSize, 15);
      expect(theme.textTheme.bodyMedium?.fontSize, 13);
      expect(theme.textTheme.bodySmall?.fontSize, 13);
      expect(theme.textTheme.labelLarge?.fontSize, 13);

      final buttonStyle = theme.filledButtonTheme.style;
      expect(buttonStyle?.textStyle?.resolve({})?.fontSize, 13);
    });
  });
}

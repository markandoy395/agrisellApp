import 'package:flutter/material.dart';

abstract final class AgrisellColors {
  static const limeGreen = Color(0xFF93CF3C);
  static const forestGreen = Color(0xFF0F743B);
  static const authGreen = Color(0xFF1F7A3F);
  static const brandBlack = Color(0xFF0B0B0B);
  static const forestDark = Color(0xFF0E6434);
  static const forestSoft = Color(0xFFE5F0E9);
  static const limeSoft = Color(0xFFEEF7E0);

  static const pageBackground = Color(0xFFF7F9F7);
  static const homeBackground = Color(0xFFEEF0F5);
  static const searchBackground = Color(0xFFF5F5F5);
  static const authBackground = Color(0xFFFBFDF8);
  static const surface = Color(0xFFFFFFFF);
  static const mutedText = Color(0xFF77817D);
  static const borderLine = Color(0xFFE8EDE9);
  static const fieldFill = Color(0xFFE5E5ED);
  static const checkboxBorder = Color(0xFF656565);
  static const dividerLine = Color(0xFF8B8B8B);
  static const headingGreen = Color(0xFF213C2E);
  static const headingGreenAlt = Color(0xFF263B30);

  static const primaryButton = authGreen;
  static const loginGradientStart = forestGreen;
  static const loginGradientMiddle = Color(0xFF0E8A42);
  static const loginGradientEnd = Color(0xFF91CB28);
  static const hoverGradientStart = Color(0xFF0B6330);
  static const hoverGradientMiddle = forestGreen;
  static const hoverGradientEnd = Color(0xFF78AA35);

  static const accentGreen = limeGreen;
  static const accentOrange = Color(0xFFEDAC68);
  static const accentLilac = Color(0xFFA795C0);
  static const accentBlue = Color(0xFF70AAC0);
  static const deliveryGreen = Color(0xFF71A972);
  static const deliveryOrange = Color(0xFFF0B678);
  static const deliveryGray = Color(0xFFD9DFDA);
  static const facebookBlue = Color(0xFF1877F2);
  static const googleBlue = Color(0xFF4285F4);

  static const statusGreenText = forestGreen;
  static const statusGreenBackground = forestSoft;
  static const statusOrangeText = Color(0xFFA15D13);
  static const statusOrangeBackground = Color(0xFFFFF3E0);
  static const statusBlueText = Color(0xFF245F8F);
  static const statusBlueBackground = Color(0xFFEDF6FB);
  static const statusRedText = Color(0xFFA33A2F);
  static const statusRedBackground = Color(0xFFFFF0EE);
  static const unavailableRed = Color(0xFFE50000);
  static const statusPurpleText = Color(0xFF6A4A8F);
  static const statusPurpleBackground = Color(0xFFF4EEF9);

  // Translucent effects derived from the brand and semantic palette above.
  static const shadowStrong = Color(0x330B0B0B);
  static const shadowMedium = Color(0x240B0B0B);
  static const shadowButton = Color(0x260B0B0B);
  static const shadowLight = Color(0x0A0B0B0B);
  static const greenGlow = Color(0x331F7A3F);
  static const greenGlowSoft = Color(0x1F1F7A3F);
  static const surfaceOverlay = Color(0x33FFFFFF);
  static const routeRadar = Color(0x33245F8F);

  // Navigation follows the app's light appearance on every device theme.
  static Color systemNavigationBar(Brightness _) => surface;
}

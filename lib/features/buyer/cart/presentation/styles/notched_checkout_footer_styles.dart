import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class NotchedCheckoutFooterStyles {
  static final _elevatedButtonStyleActive = ElevatedButton.styleFrom(
    elevation: 2,
    shadowColor: AgrisellColors.forestDark.withValues(alpha: 0.24),
    backgroundColor: AgrisellColors.authGreen,
    disabledBackgroundColor: AgrisellColors.deliveryGray,
    foregroundColor: AgrisellColors.surface,
    disabledForegroundColor: AgrisellColors.mutedText,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
  static final _elevatedButtonStyleInactive = ElevatedButton.styleFrom(
    elevation: 0,
    shadowColor: AgrisellColors.forestDark.withValues(alpha: 0.24),
    backgroundColor: AgrisellColors.authGreen,
    disabledBackgroundColor: AgrisellColors.deliveryGray,
    foregroundColor: AgrisellColors.surface,
    disabledForegroundColor: AgrisellColors.mutedText,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
  static ButtonStyle elevatedButtonStyle(bool enabled) =>
      enabled ? _elevatedButtonStyleActive : _elevatedButtonStyleInactive;
}

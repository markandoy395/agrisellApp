import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductEditFormActionsStyles {
  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.authGreen, width: 1.2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static TextStyle labelText(Color color, FontWeight fontWeight) =>
      TextStyle(color: color, fontSize: 13, height: 1, fontWeight: fontWeight);
}

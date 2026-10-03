import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderWithdrawalControlStyles {
  static final controlRadius = BorderRadius.circular(10);
  static const selectedIconColor = AgrisellColors.authGreen;
  static const unselectedIconColor = AgrisellColors.mutedText;
  static const selectedTypeLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.authGreen,
  );
  static const unselectedTypeLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.brandBlack,
  );
  static final selectedType = _typeDecoration(
    AgrisellColors.statusGreenBackground,
    AgrisellColors.authGreen,
  );
  static final unselectedType = _typeDecoration(
    AgrisellColors.searchBackground,
    Colors.transparent,
  );
  static final defaultMethod = _methodDecoration(AgrisellColors.authGreen, 1.5);
  static final regularMethod = _methodDecoration(AgrisellColors.borderLine, 1);
  static final defaultMethodIcon = _iconDecoration(
    AgrisellColors.statusGreenBackground,
  );
  static final regularMethodIcon = _iconDecoration(
    AgrisellColors.searchBackground,
  );
  static final addButton = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.authGreen, width: 1.5),
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: controlRadius),
  );
  static final cancelButton = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: controlRadius),
  );
  static final saveButton = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: controlRadius),
  );

  static InputDecoration accountInput(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AgrisellColors.searchBackground,
    border: OutlineInputBorder(
      borderRadius: controlRadius,
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  static BoxDecoration _typeDecoration(Color background, Color border) =>
      BoxDecoration(
        color: background,
        borderRadius: controlRadius,
        border: Border.all(color: border, width: 1.5),
      );

  static BoxDecoration _methodDecoration(Color border, double width) =>
      BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: width),
      );

  static BoxDecoration _iconDecoration(Color background) =>
      BoxDecoration(color: background, borderRadius: controlRadius);
}

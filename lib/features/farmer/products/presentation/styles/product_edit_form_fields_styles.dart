import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductEditFormFieldsStyles {
  static const labelText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w500,
  );

  static const textStyle = TextStyle(fontSize: 12, height: 1);

  static InputDecoration inputDecoration(
    String? prefixText,
    String? suffixText,
  ) => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: AgrisellColors.fieldFill,
    prefixText: prefixText,
    suffixText: suffixText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AgrisellColors.authGreen),
    ),
  );

  static final dropdownButtonFormFieldStyle = AppDropdownStyle.textStyle
      .copyWith(fontSize: 12);

  static final inputDecoration2 = InputDecoration(
    isDense: true,
    filled: true,
    fillColor: AgrisellColors.surface,
    contentPadding: const EdgeInsets.fromLTRB(11, 4, 5, 4),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: const BorderSide(color: AgrisellColors.authGreen),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: const BorderSide(color: AgrisellColors.authGreen),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: const BorderSide(color: AgrisellColors.authGreen, width: 1.4),
    ),
  );
}

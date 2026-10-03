import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductEditSaleStatusRowStyles {
  static final dropdownButtonFormFieldStyle = AppDropdownStyle.textStyle
      .copyWith(fontSize: 12);

  static final inputDecoration = InputDecoration(
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

  static const textStyle = TextStyle(fontSize: 12, height: 1);

  static InputDecoration inputDecoration2(
    OutlineInputBorder value1,
    OutlineInputBorder value2,
  ) => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: AgrisellColors.surface,
    contentPadding: const EdgeInsets.fromLTRB(11, 4, 5, 4),
    border: value1,
    enabledBorder: value1,
    focusedBorder: value2,
  );
}

import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class AddProductFormFieldsStyles {
  static const labelText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.15,
    fontWeight: FontWeight.w600,
  );

  static InputDecoration inputDecoration(
    String? prefixText,
    String? suffixText,
    String? hintText,
    String? errorText,
    OutlineInputBorder value5,
    OutlineInputBorder value6,
    OutlineInputBorder value7,
    OutlineInputBorder value8,
  ) => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: AgrisellColors.searchBackground,
    prefixText: prefixText,
    suffixText: suffixText,
    hintText: hintText,
    errorText: errorText,
    counterText: '',
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    border: value5,
    enabledBorder: value5,
    focusedBorder: value6,
    errorBorder: value7,
    focusedErrorBorder: value8,
  );

  static final dropdownButtonFormFieldStyle = AppDropdownStyle.textStyle
      .copyWith(fontSize: 12);

  static InputDecoration inputDecoration2(
    String? errorText,
    OutlineInputBorder value2,
    OutlineInputBorder value3,
    OutlineInputBorder value4,
    OutlineInputBorder value5,
  ) => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: AgrisellColors.searchBackground,
    errorText: errorText,
    contentPadding: const EdgeInsets.fromLTRB(11, 9, 7, 9),
    border: value2,
    enabledBorder: value2,
    focusedBorder: value3,
    errorBorder: value4,
    focusedErrorBorder: value5,
  );
}

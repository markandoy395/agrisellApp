import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_style.dart';

abstract final class FarmerProfileEditFieldsStyles {
  // Colors & Input Decoration
  static const hintColor = Color(0xFFA3AFB4);
  static const fillColor = Color(0xFFF3F7F7);
  static const borderColor = Color(0xFFC7D3D7);
  static const focusedBorderColor = FarmerProfileStyle.green;
  static const prefixIconColor = FarmerProfileStyle.ink;
  static const dropdownIconColor = Color(0xFF244752);

  static const hintStyle = TextStyle(color: hintColor, fontSize: 14);
  static const inputStyle = TextStyle(
    color: FarmerProfileStyle.ink,
    fontSize: 14,
  );
  static const dropdownItemStyle = TextStyle(
    color: FarmerProfileStyle.ink,
    fontSize: 13,
  );

  static const labelStyle = TextStyle(
    color: FarmerProfileStyle.ink,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const optionalStyle = TextStyle(
    color: FarmerProfileStyle.muted,
    fontSize: 12,
  );

  static const buttonTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  // Spacing
  static const fieldSpacing = SizedBox(height: 16);
  static const smallSpacing = SizedBox(height: 8);
  static const sectionSpacing = SizedBox(height: 12);
  static const actionsSpacing = SizedBox(height: 22);

  // Buttons
  static final cancelButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: FarmerProfileStyle.green,
    side: const BorderSide(color: FarmerProfileStyle.green),
    minimumSize: const Size(0, 38),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final saveButtonStyle = FilledButton.styleFrom(
    backgroundColor: const Color(0xFF197A48),
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 38),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static InputDecoration decoration({
    String? hint,
    IconData? icon,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: hintStyle,
    filled: true,
    fillColor: fillColor,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    prefixIcon: icon == null
        ? null
        : Icon(icon, color: prefixIconColor, size: 22),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: focusedBorderColor, width: 1.5),
    ),
  );

  static InputDecoration dateDropdownDecoration() => decoration().copyWith(
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
  );
}

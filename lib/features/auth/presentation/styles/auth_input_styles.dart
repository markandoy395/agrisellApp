import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';

abstract final class AuthInputStyle {
  static const height = 56.0;
  static const fillColor = AgrisellColors.pageBackground;
  static const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AgrisellColors.borderLine),
  );
  static const focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AgrisellColors.authGreen, width: 1.5),
  );
  static const errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AgrisellColors.statusRedText),
  );

  static Widget iconBadge(IconData icon) => Padding(
    padding: const EdgeInsets.only(left: 8, right: 8),
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AgrisellColors.forestSoft,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: AgrisellColors.authGreen, size: 21),
    ),
  );

  static IconData iconFor(String label) {
    final value = label.toLowerCase();
    if (value.contains('email')) return Icons.mail_outline;
    if (value.contains('password')) return Icons.lock_outline;
    if (value.contains('phone') || value.contains('mobile')) {
      return Icons.phone_outlined;
    }
    if (value.contains('date') || value.contains('birth')) {
      return Icons.calendar_month_outlined;
    }
    if (value.contains('province')) return Icons.map_outlined;
    if (value.contains('city') || value.contains('municipality')) {
      return Icons.location_city_outlined;
    }
    if (value.contains('barangay')) return Icons.home_outlined;
    if (value.contains('address') ||
        value.contains('street') ||
        value.contains('location')) {
      return Icons.location_on_outlined;
    }
    if (value.contains('gender')) return Icons.people_outline;
    if (value.contains('vehicle') || value.contains('plate')) {
      return Icons.local_shipping_outlined;
    }
    if (value.contains('license')) return Icons.badge_outlined;
    if (value.contains('farm') ||
        value.contains('crop') ||
        value.contains('irrigation')) {
      return Icons.agriculture_outlined;
    }
    if (value.contains('name') || value.contains('person')) {
      return Icons.person_outline;
    }
    if (value.contains('postal')) return Icons.markunread_mailbox_outlined;
    return Icons.edit_outlined;
  }

  static InputDecoration decoration({
    required String label,
    IconData? icon,
    String? errorText,
    String? helperText,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AgrisellColors.mutedText, fontSize: 13),
    floatingLabelStyle: AgrisellTheme.floatingInputLabelStyle,
    errorText: errorText,
    helperText: helperText,
    suffixIcon: suffixIcon,
    prefixIcon: iconBadge(icon ?? iconFor(label)),
    prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 40),
    contentPadding: contentPadding,
    filled: true,
    fillColor: fillColor,
    border: border,
    enabledBorder: border,
    focusedBorder: focusedBorder,
    errorBorder: errorBorder,
    focusedErrorBorder: errorBorder,
  );

  static const dropdownTheme = InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: fillColor,
    constraints: BoxConstraints.tightFor(height: height),
    contentPadding: EdgeInsets.symmetric(horizontal: 8),
    border: border,
    enabledBorder: border,
    focusedBorder: focusedBorder,
    floatingLabelStyle: AgrisellTheme.floatingInputLabelStyle,
  );
}

import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerGcashSettingsWidgetsStyles {
  static InputDecoration inputDecoration(
    String label,
    IconData icon,
    bool isPhone,
    bool obscured,
    VoidCallback onToggleObscured,
  ) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 19),
    suffixIcon: isPhone
        ? IconButton(
            tooltip: obscured ? 'Show GCash number' : 'Hide GCash number',
            onPressed: onToggleObscured,
            icon: Icon(
              obscured
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 19,
            ),
          )
        : null,
    filled: true,
    fillColor: AgrisellColors.searchBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}

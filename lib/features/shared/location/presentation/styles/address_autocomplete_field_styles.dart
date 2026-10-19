import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';

abstract final class AddressAutocompleteFieldStyles {
  static const compactText = TextStyle(fontSize: 12);
  static const externalLabelText = TextStyle(fontSize: 14);
  static TextStyle textStyle(Widget? externalLabel) =>
      externalLabel == null ? compactText : externalLabelText;

  static final inputTheme = InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: AgrisellColors.fieldFill,
    floatingLabelStyle: AgrisellTheme.floatingInputLabelStyle,
    constraints: const BoxConstraints.tightFor(height: 56),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  static InputDecoration decoration({
    required String label,
    required Widget? externalLabel,
    required Widget? leadingIcon,
    required InputDecorationTheme? theme,
    required VoidCallback? onToggle,
  }) => InputDecoration(
    label: externalLabel == null
        ? Text('$label (select or type)', style: compactText)
        : null,
    prefixIcon: leadingIcon,
    suffixIcon: IconButton(
      tooltip: 'Show suggestions',
      onPressed: onToggle,
      icon: const Icon(Icons.arrow_drop_down),
    ),
  ).applyDefaults(theme ?? inputTheme);
}

import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class LocationSelectorControlsStyles {
  static const containerDecoration = BoxDecoration(
    border: Border(bottom: BorderSide(color: AgrisellColors.borderLine)),
  );

  static final containerDecoration2 = BoxDecoration(
    color: AgrisellColors.deliveryGray,
    borderRadius: BorderRadius.circular(4),
  );

  static const buttonStyle = ButtonStyle(
    textStyle: WidgetStatePropertyAll(
      TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    ),
    visualDensity: VisualDensity.compact,
  );

  static final _inputDecorationActive = InputDecoration(
    labelText: 'Written address',
    hintText: 'Purok 5, Lianga, Surigao del Sur',
    helperText: 'Required. Use a place name, not latitude and longitude.',
    helperMaxLines: 3,
    filled: true,
    fillColor: AgrisellColors.searchBackground,
  );
  static final _inputDecorationInactive = InputDecoration(
    labelText: 'Address',
    hintText: null,
    helperText: 'Optional',
    filled: true,
    fillColor: AgrisellColors.searchBackground,
  );
  static InputDecoration inputDecoration(bool requiresWrittenAddress) =>
      requiresWrittenAddress
      ? _inputDecorationActive
      : _inputDecorationInactive;

  static const inputDecoration2 = InputDecoration(
    labelText: 'Landmark or notes',
    hintText: 'Farm entrance, gate, roadside',
    filled: true,
    fillColor: AgrisellColors.searchBackground,
  );

  static final confirmButton = FilledButton.styleFrom(
    minimumSize: const Size(0, 48),
    maximumSize: Size.infinite,
  );
}

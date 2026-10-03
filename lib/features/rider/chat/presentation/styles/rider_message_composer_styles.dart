import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderMessageComposerStyles {
  static final inputDecoration = InputDecoration(
    hintText: 'Write a delivery message',
    hintStyle: const TextStyle(fontSize: 12),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    filled: true,
    fillColor: AgrisellColors.fieldFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  static final iconButtonStyle = IconButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
  );
}
